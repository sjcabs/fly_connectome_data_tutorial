# Helper Functions for Fly Connectome Data Access
# ================================================
# These functions provide unified access to connectome data from both
# Google Cloud Storage and local file systems, with support for lazy
# loading and filtering of large Parquet datasets.

#' Setup GCS Filesystem
#'
#' Creates an authenticated Google Cloud Storage filesystem object using gcsfs.
#' This is required for accessing data from GCS buckets.
#'
#' @param token Authentication method. Use "google_default" for gcloud auth,
#'   or "anon" for public buckets (default: "google_default")
#'
#' @return A Python gcsfs.GCSFileSystem object
#'
#' @details
#' Before using this function with authenticated buckets, run:
#' \code{gcloud auth application-default login}
#'
#' @examples
#' \dontrun{
#' fs <- setup_gcs_filesystem()
#' }
#'
#' @export
setup_gcs_filesystem <- function(token = "google_default") {
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop("Package 'reticulate' is required for GCS access. Install with: install.packages('reticulate')")
  }

  gcsfs <- reticulate::import("gcsfs")
  cat("Authenticating with Google Cloud Storage...\n")
  fs <- gcsfs$GCSFileSystem(token = token)

  return(fs)
}

#' Query Parquet from GCS with Server-Side Filtering
#'
#' Reads Parquet from GCS with filters applied on the server before downloading.
#' Only matching rows and selected columns are transferred. Uses DuckDB for
#' robust Parquet handling and efficient predicate pushdown.
#'
#' @param path GCS path to Parquet file (gs://bucket/file.parquet)
#' @param gcs_filesystem GCS filesystem object (not used with DuckDB, kept for compatibility)
#' @param filters SQL WHERE clause as string (e.g., "neuropil LIKE 'MB%'")
#' @param columns Character vector of column names to load (NULL = all)
#'
#' @return Tibble with filtered results
#'
#' @details
#' Uses DuckDB with httpfs extension to read Parquet from GCS with server-side
#' filtering via predicate pushdown. Only the filtered subset is downloaded,
#' making this efficient for large files. DuckDB handles various Parquet formats
#' robustly and uses gcloud credentials automatically.
#'
#' Requires: gcloud auth application-default login
#'
#' @examples
#' \dontrun{
#' fs <- setup_gcs_filesystem()
#'
#' # Read with SQL filter and column selection
#' mb_synapses <- query_parquet_gcs(
#'   "gs://bucket/synapses.parquet",
#'   gcs_filesystem = fs,
#'   filters = "neuropil LIKE 'MB%'",  # SQL WHERE clause
#'   columns = c("id", "pre", "post", "neuropil")
#' )
#'
#' # Complex filters
#' filtered <- query_parquet_gcs(
#'   path,
#'   fs,
#'   filters = "neuropil LIKE 'MB%' AND cleft_score > 50",
#'   columns = c("id", "pre", "post")
#' )
#' }
#'
#' @export
query_parquet_gcs <- function(path, gcs_filesystem, filters = NULL, columns = NULL) {
  if (!grepl("^gs://", path)) {
    stop("This function is for GCS paths. Use open_dataset_lazy() for local files.")
  }

  cat("Reading Parquet from GCS using Python backend...\n")

  # Find the Python script - try multiple locations
  this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)

  possible_paths <- c(
    "setup/gcs_parquet_reader.py",                    # From R/ directory
    "R/setup/gcs_parquet_reader.py",                  # From tutorial root
    "gcs_parquet_reader.py",                          # Legacy fallback
    file.path(getwd(), "setup", "gcs_parquet_reader.py")  # Absolute from working dir
  )

  # Add path relative to functions.R if we can find it
  if (!is.null(this_file) && is.character(this_file)) {
    possible_paths <- c(possible_paths,
                       file.path(dirname(this_file), "gcs_parquet_reader.py"))
  }

  python_script <- NULL
  for (script_path in possible_paths) {
    if (!is.null(script_path) && file.exists(script_path)) {
      python_script <- script_path
      break
    }
  }

  if (is.null(python_script)) {
    stop("Cannot find gcs_parquet_reader.py. Tried:\n  ",
         paste(possible_paths, collapse = "\n  "))
  }

  cat("Using Python script:", python_script, "\n")
  reticulate::source_python(python_script)

  # Parse filter to extract column and prefix
  filter_column <- NULL
  filter_prefix <- NULL

  if (!is.null(filters) && is.character(filters)) {
    # Parse SQL LIKE 'pattern%' filter
    if (grepl("LIKE\\s+'([^']+)'", filters, ignore.case = TRUE)) {
      pattern <- sub(".*LIKE\\s+'([^']+)'.*", "\\1", filters, ignore.case = TRUE)
      filter_column <- sub("(.+)\\s+LIKE.*", "\\1", filters, ignore.case = TRUE)
      filter_column <- trimws(filter_column)

      # Extract prefix (remove trailing %)
      if (grepl("%$", pattern)) {
        filter_prefix <- sub("%$", "", pattern)
      }
    }
  }

  # Call Python function
  tryCatch({
    # Write debug info to log file
    logfile <- "/tmp/gcs_parquet_debug.log"
    writeLines(c(
      paste("=== GCS Parquet Query Debug ==="),
      paste("Time:", Sys.time()),
      paste("Python script:", python_script),
      paste("GCS path:", path),
      paste("Columns:", if(is.null(columns)) "NULL" else paste(columns, collapse=", ")),
      paste("Filter column:", if(is.null(filter_column)) "NULL" else filter_column),
      paste("Filter prefix:", if(is.null(filter_prefix)) "NULL" else filter_prefix),
      ""
    ), logfile)

    result_df <- query_parquet_gcs(
      gcs_path = path,
      columns = columns,
      filter_column = filter_column,
      filter_prefix = filter_prefix,
      show_progress = TRUE
    )

    # Convert to tibble
    result <- tibble::as_tibble(result_df)

    return(result)

  }, error = function(e) {
    # Log the error
    logfile <- "/tmp/gcs_parquet_debug.log"
    cat(file = logfile, append = TRUE,
      "\n=== ERROR ===\n",
      "Error type:", paste(class(e), collapse=", "), "\n",
      "Error message:", conditionMessage(e), "\n",
      "Full error:\n",
      paste(capture.output(print(e)), collapse="\n"), "\n"
    )

    # Also write to stderr for immediate visibility
    message("\n⚠️  GCS PARQUET ERROR ⚠️")
    message("Error: ", conditionMessage(e))
    message("See details in: /tmp/gcs_parquet_debug.log")
    message("")

    # Check for common issues
    if (grepl("gcsfs|pyarrow|ModuleNotFoundError|ImportError", conditionMessage(e), ignore.case = TRUE)) {
      message("Possible cause: Python packages not installed")
      message("Run: python3 -m pip install --user gcsfs pyarrow pandas")
    }

    if (grepl("FileNotFoundError|No such file", conditionMessage(e), ignore.case = TRUE)) {
      message("Possible cause: GCS authentication or file not found")
      message("Run: gcloud auth application-default login")
    }

    stop("Cannot read Parquet from GCS. See /tmp/gcs_parquet_debug.log for details.", call. = FALSE)
  })
}

#' Open Dataset with Lazy Evaluation (Local Files)
#'
#' Opens a local Parquet dataset for lazy evaluation with dplyr.
#' For GCS files, use query_parquet_gcs() instead.
#'
#' @param path Local path to dataset
#' @param format File format: "parquet" or "feather" (default: "parquet")
#'
#' @return An Arrow Dataset object for lazy evaluation
#'
#' @details
#' For local files, Arrow's lazy evaluation allows:
#' - filter() - Filter rows (pushed down to Parquet)
#' - select() - Select columns (only loads selected columns)
#' - collect() - Execute and load into memory
#'
#' For GCS files, use query_parquet_gcs() which applies filters server-side.
#'
#' @examples
#' \dontrun{
#' # Local lazy loading
#' ds <- open_dataset_lazy("~/data/synapses.parquet")
#' mb <- ds %>%
#'   filter(str_detect(neuropil, "^MB")) %>%
#'   select(id, pre, post) %>%
#'   collect()
#' }
#'
#' @export
open_dataset_lazy <- function(path, format = "parquet") {
  is_gcs <- grepl("^gs://", path)

  if (is_gcs) {
    stop(
      "For GCS Parquet files, use query_parquet_gcs() instead.\n",
      "Example:\n",
      "  result <- query_parquet_gcs(\n",
      "    path = '", path, "',\n",
      "    gcs_filesystem = gcs_fs,\n",
      "    filters = \"neuropil LIKE 'MB%'\",\n",
      "    columns = c('id', 'pre', 'post', 'neuropil')\n",
      "  )"
    )
  }

  cat("Opening dataset from local path (lazy evaluation):", path, "\n")

  # Local path - use Arrow's native filesystem with lazy evaluation
  ds <- arrow::open_dataset(path, format = format)

  cat("✓ Dataset opened for lazy evaluation\n")
  cat("  Use filter() and select() to define your query, then collect() to execute\n")
  cat("  Arrow will only load filtered rows and selected columns into RAM\n")

  return(ds)
}

#' Read Feather File (Eager Loading)
#'
#' Reads a Feather file into memory immediately. Works with both GCS and local paths.
#' For large files with Parquet format, prefer \code{open_dataset_lazy()} instead.
#'
#' @param path Full path to feather file (can be gs:// for GCS or local path)
#' @param gcs_filesystem Optional GCS filesystem object (required for GCS paths)
#' @param show_progress Show progress messages (default: TRUE)
#'
#' @return A tibble with the file contents
#'
#' @details
#' This function loads the ENTIRE file into memory. For large synapse files,
#' consider using Parquet format with \code{open_dataset_lazy()} for better
#' performance and memory efficiency.
#'
#' For GCS access, the file is streamed from GCS, written to a temporary file,
#' then read by Arrow.
#'
#' @examples
#' \dontrun{
#' # GCS access
#' fs <- setup_gcs_filesystem()
#' data <- read_feather_smart("gs://bucket/data.feather", gcs_filesystem = fs)
#'
#' # Local access
#' data <- read_feather_smart("~/data/data.feather")
#' }
#'
#' @export
read_feather_smart <- function(path, gcs_filesystem = NULL, show_progress = TRUE) {
  is_gcs <- grepl("^gs://", path)

  if (is_gcs) {
    if (is.null(gcs_filesystem)) {
      stop("gcs_filesystem argument required for GCS paths. Create with setup_gcs_filesystem()")
    }

    if (show_progress) cat("Reading from GCS:", path, "\n")

    # Get Python builtins for file operations
    builtins <- reticulate::import_builtins()

    # Create temporary file
    tmp <- tempfile(fileext = ".feather")
    on.exit(unlink(tmp), add = TRUE)

    if (show_progress) {
      cat("Downloading from GCS... (this may take several minutes for large files)\n")
    }

    # Strip gs:// prefix for gcsfs
    gcs_path_clean <- sub("^gs://", "", path)

    # Stream from GCS and write to temp file
    gcs_file <- gcs_filesystem$open(gcs_path_clean, "rb")
    py_bytes <- gcs_file$read()
    gcs_file$close()

    if (show_progress) {
      cat("Downloaded", round(length(py_bytes) / 1024^2, 2), "MB from GCS\n")
      cat("Loading into memory with Arrow...\n")
    }

    # Write bytes to temp file
    out_file <- builtins$open(tmp, "wb")
    out_file$write(py_bytes)
    out_file$close()

    # Read with Arrow
    result <- arrow::read_feather(tmp)
    if (show_progress) cat("✓ Done! Loaded", nrow(result), "rows\n")

    return(result)

  } else {
    # Local path
    if (show_progress) cat("Reading from local path:", path, "\n")
    result <- arrow::read_feather(path)
    if (show_progress) cat("✓ Done! Loaded", nrow(result), "rows\n")

    return(result)
  }
}

#' Construct Dataset Paths
#'
#' Helper function to construct file paths for metadata and data files.
#' Note: Skeleton files do not include version numbers in their filenames.
#'
#' @param data_root Root data directory (can be gs:// or local path)
#' @param dataset Dataset name with version (e.g., "banc_746")
#' @param file_type Type of file: "meta", "synapses", "edgelist", "edgelist_simple", or "skeletons"
#' @param space_suffix Optional space name for skeletons (defaults to native space, e.g., "banc_space")
#'
#' @return Full path to the requested file
#'
#' @details
#' For skeleton files, the naming pattern is: {dataset}_{space}_[l2_]swc (directory)
#' - BANC uses l2 skeletons: banc_banc_space_l2_swc/
#' - Other datasets: fafb_fafb_space_swc/
#'
#' @examples
#' \dontrun{
#' meta_path <- construct_path("gs://bucket/data", "banc_746", "meta")
#' # Returns: gs://bucket/data/banc/banc_746_meta.feather
#'
#' skeleton_path <- construct_path("gs://bucket/data", "banc_746", "skeletons")
#' # Returns: gs://bucket/data/banc/banc_banc_space_l2_swc (directory)
#' }
#'
#' @export
construct_path <- function(data_root, dataset, file_type = "meta", space_suffix = NULL) {
  # Extract dataset name (e.g., "banc" from "banc_746")
  dataset_name <- strsplit(dataset, "_")[[1]][1]

  # Determine file extension based on type
  # Note: skeletons are now directories, not .zip files
  extension <- switch(file_type,
    "meta" = ".feather",
    "synapses" = ".parquet",
    "edgelist" = ".feather",
    "edgelist_simple" = ".feather",
    "skeletons" = "",  # No extension - it's a directory
    stop("Unknown file_type. Choose: meta, synapses, edgelist, edgelist_simple, or skeletons")
  )

  # Construct filename
  if (file_type == "skeletons") {
    # Skeleton files don't include version number and have specific naming
    # Pattern: {dataset_name}_{space_name}_[l2_]swc.zip
    # e.g., banc_banc_space_l2_swc.zip, fafb_fafb_space_swc.zip

    # Default space is the native space for the dataset
    if (is.null(space_suffix)) {
      space_suffix <- paste0(dataset_name, "_space")
    }

    # BANC uses l2 skeletons, others don't
    if (dataset_name == "banc") {
      filename <- paste0(dataset_name, "_", space_suffix, "_l2_swc", extension)
    } else {
      filename <- paste0(dataset_name, "_", space_suffix, "_swc", extension)
    }
  } else {
    # Other file types include the full dataset name with version
    filename <- paste0(dataset, "_", file_type, extension)
  }

  # Combine into full path
  full_path <- file.path(data_root, dataset_name, filename)

  return(full_path)
}

#' List SWC Files in Directory or ZIP Archive
#'
#' Lists all SWC files contained in a directory or ZIP archive.
#' Supports both local and GCS paths.
#'
#' @param zip_path Path to directory or ZIP file (can be gs:// for GCS or local path)
#' @param gcs_filesystem Optional GCS filesystem object (required for GCS paths)
#'
#' @return Character vector of SWC filenames
#'
#' @details
#' Automatically detects whether path is a directory or ZIP file.
#' For GCS paths to directories, uses gcsfs to list files.
#' For GCS paths to ZIPs, downloads temporarily to read file list.
#'
#' @examples
#' \dontrun{
#' # Local directory
#' swc_files <- list_swc_in_zip("~/data/skeletons/")
#'
#' # GCS directory
#' fs <- setup_gcs_filesystem()
#' swc_files <- list_swc_in_zip("gs://bucket/skeletons/", gcs_filesystem = fs)
#' }
#'
#' @export
list_swc_in_zip <- function(zip_path, gcs_filesystem = NULL) {
  is_gcs <- grepl("^gs://", zip_path)
  is_zip <- grepl("\\.zip$", zip_path, ignore.case = TRUE)

  if (is_gcs) {
    if (is.null(gcs_filesystem)) {
      stop("gcs_filesystem argument required for GCS paths")
    }

    # Strip gs:// prefix for gcsfs
    gcs_path_clean <- sub("^gs://", "", zip_path)

    if (is_zip) {
      # Handle ZIP file from GCS
      tmp_zip <- tempfile(fileext = ".zip")
      on.exit(unlink(tmp_zip), add = TRUE)

      cat("Downloading ZIP from GCS to read file list:", zip_path, "\n")
      builtins <- reticulate::import_builtins()

      gcs_file <- gcs_filesystem$open(gcs_path_clean, "rb")
      py_bytes <- gcs_file$read()
      gcs_file$close()

      out_file <- builtins$open(tmp_zip, "wb")
      out_file$write(py_bytes)
      out_file$close()

      # List files in ZIP
      file_list <- unzip(tmp_zip, list = TRUE)$Name
      swc_files <- file_list[grepl("\\.swc$", file_list, ignore.case = TRUE)]
    } else {
      # Handle directory from GCS
      cat("Listing SWC files from GCS directory:", zip_path, "\n")

      # List files in GCS directory
      file_list <- gcs_filesystem$ls(gcs_path_clean)

      # Filter for .swc files (basename only)
      swc_files <- basename(file_list[grepl("\\.swc$", file_list, ignore.case = TRUE)])
    }
  } else {
    # Local path
    if (is_zip) {
      # Handle local ZIP
      file_list <- unzip(zip_path, list = TRUE)$Name
      swc_files <- file_list[grepl("\\.swc$", file_list, ignore.case = TRUE)]
    } else {
      # Handle local directory
      swc_files <- list.files(zip_path, pattern = "\\.swc$", ignore.case = TRUE)
    }
  }

  cat("Found", length(swc_files), "SWC files\n")

  return(swc_files)
}

#' Read Neurons from Directory (Simplified)
#'
#' Simplified function to read SWC files using nat::read.neurons.
#' Supports both local and GCS directories.
#'
#' @param dir_path Path to directory containing SWC files (can be gs:// for GCS)
#' @param neuron_ids Vector of neuron IDs (SWC files will be named {id}.swc)
#' @param gcs_filesystem Optional GCS filesystem object (required for GCS paths)
#'
#' @return neuronlist object from nat package
#'
#' @details
#' This is a simple wrapper around nat::read.neurons that handles GCS paths.
#' For GCS paths, files are downloaded to a temporary directory first, then
#' read with nat::read.neurons.
#'
#' @examples
#' \dontrun{
#' # Local directory
#' neurons <- read_neurons_dir("/path/to/skeletons/", c("123", "456", "789"))
#'
#' # GCS access
#' fs <- setup_gcs_filesystem()
#' neurons <- read_neurons_dir("gs://bucket/skeletons/",
#'                            c("123", "456", "789"),
#'                            gcs_filesystem = fs)
#' }
#'
#' @export
read_neurons_dir <- function(dir_path, neuron_ids, gcs_filesystem = NULL) {
  is_gcs <- grepl("^gs://", dir_path)

  if (is_gcs) {
    if (is.null(gcs_filesystem)) {
      stop("gcs_filesystem argument required for GCS paths")
    }

    # Download files to temp directory
    tmp_dir <- tempfile()
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

    cat("Downloading", length(neuron_ids), "SWC files from GCS...\n")

    # Strip gs:// prefix for gcsfs
    gcs_path_clean <- sub("^gs://", "", dir_path)

    # Download each file
    builtins <- reticulate::import_builtins()
    downloaded <- 0
    for (id in neuron_ids) {
      swc_filename <- paste0(id, ".swc")
      swc_path_gcs <- paste(gcs_path_clean, swc_filename, sep = "/")
      swc_path_local <- file.path(tmp_dir, swc_filename)

      tryCatch({
        gcs_file <- gcs_filesystem$open(swc_path_gcs, "rb")
        py_bytes <- gcs_file$read()
        gcs_file$close()

        # Decode and write to temp file
        text_content <- py_bytes$decode("utf-8")
        writeLines(text_content, swc_path_local)
        downloaded <- downloaded + 1
      }, error = function(e) {
        warning("Could not download ", swc_filename, ": ", e$message)
      })
    }

    cat("✓ Downloaded", downloaded, "files\n")

    # Use nat::read.neurons on temp directory with parallelization
    cat("Reading neurons with nat::read.neurons (parallel)...\n")
    neurons <- nat::read.neurons(tmp_dir, pattern = "\\.swc$", format = "swc", .parallel = TRUE)

  } else {
    # Local path - use nat::read.neurons directly with parallelization
    swc_files <- paste0(neuron_ids, ".swc")
    cat("Reading", length(swc_files), "neurons with nat::read.neurons (parallel)...\n")
    neurons <- nat::read.neurons(dir_path, files = swc_files, format = "swc", .parallel = TRUE)
  }

  cat("✓ Loaded", length(neurons), "neurons\n")
  return(neurons)
}

#' Read Single SWC File from Directory or ZIP Archive
#'
#' Reads one SWC file from a directory or ZIP archive.
#' Returns parsed SWC data as a nat neuron object or data frame.
#'
#' @param zip_path Path to directory or ZIP file (can be gs:// for GCS or local path)
#' @param swc_filename Name of the SWC file (e.g., "neuron_123.swc")
#' @param gcs_filesystem Optional GCS filesystem object (required for GCS paths)
#' @param format Return format: "nat" (default), "dataframe", or "raw"
#'
#' @return
#' - If format="nat": A nat::neuron object with methods for plotting and analysis
#' - If format="dataframe": A data frame with columns: PointNo, Label, X, Y, Z, R, Parent
#' - If format="raw": Raw character vector of file lines
#'
#' @details
#' Automatically detects whether path is a directory or ZIP file.
#' For GCS directories, reads files directly without downloading.
#' For GCS ZIPs, downloads entire ZIP to temporary file first.
#'
#' The nat::neuron object provides many useful methods:
#' - plot3d() / plot() for visualization
#' - summary() for morphology statistics
#' - Cable length, Strahler analysis, etc.
#'
#' SWC format specification:
#' - PointNo: Point identifier (positive integer)
#' - Label: Type (0=undefined, 1=soma, 2=axon, 3=dendrite, etc.)
#' - X, Y, Z: 3D coordinates in nanometers
#' - R: Radius in nanometers
#' - Parent: Parent point identifier (-1 for root)
#'
#' @examples
#' \dontrun{
#' # Read as nat neuron object (recommended)
#' neuron <- read_swc_from_zip("~/data/skeletons.zip", "neuron_123.swc")
#' plot3d(neuron)
#' summary(neuron)
#'
#' # Read as data frame for custom analysis
#' neuron_df <- read_swc_from_zip("~/data/skeletons.zip",
#'                                "neuron_123.swc",
#'                                format = "dataframe")
#' ggplot(neuron_df, aes(X, Y)) + geom_path()
#'
#' # GCS access
#' fs <- setup_gcs_filesystem()
#' neuron <- read_swc_from_zip("gs://bucket/skeletons.zip",
#'                             "neuron_123.swc",
#'                             gcs_filesystem = fs)
#' }
#'
#' @export
read_swc_from_zip <- function(zip_path, swc_filename,
                               gcs_filesystem = NULL,
                               format = c("nat", "dataframe", "raw")) {
  format <- match.arg(format)
  is_gcs <- grepl("^gs://", zip_path)
  is_zip <- grepl("\\.zip$", zip_path, ignore.case = TRUE)

  # Read file content based on source type
  if (is_gcs) {
    if (is.null(gcs_filesystem)) {
      stop("gcs_filesystem argument required for GCS paths")
    }

    # Strip gs:// prefix for gcsfs
    gcs_path_clean <- sub("^gs://", "", zip_path)

    if (is_zip) {
      # Handle ZIP file from GCS
      tmp_zip <- tempfile(fileext = ".zip")
      on.exit(unlink(tmp_zip), add = TRUE)

      cat("Downloading ZIP from GCS:", zip_path, "\n")
      builtins <- reticulate::import_builtins()

      gcs_file <- gcs_filesystem$open(gcs_path_clean, "rb")
      py_bytes <- gcs_file$read()
      gcs_file$close()

      out_file <- builtins$open(tmp_zip, "wb")
      out_file$write(py_bytes)
      out_file$close()

      # Extract file from ZIP
      cat("Reading", swc_filename, "from ZIP...\n")
      con <- unz(tmp_zip, swc_filename)
      lines <- readLines(con)
      close(con)
    } else {
      # Handle directory from GCS
      cat("Reading", swc_filename, "from GCS directory:", zip_path, "\n")
      builtins <- reticulate::import_builtins()

      # Construct full path to SWC file
      # Use paste with forward slashes for GCS (not file.path which uses system separator)
      swc_path <- paste(gcs_path_clean, swc_filename, sep = "/")

      # Read file directly from GCS
      gcs_file <- gcs_filesystem$open(swc_path, "rb")
      py_bytes <- gcs_file$read()
      gcs_file$close()

      # Decode bytes to string in Python, then split in R
      text_content <- py_bytes$decode("utf-8")
      lines <- strsplit(text_content, "\n")[[1]]
    }
  } else {
    # Local path
    if (is_zip) {
      # Handle local ZIP
      cat("Reading", swc_filename, "from ZIP...\n")
      con <- unz(zip_path, swc_filename)
      lines <- readLines(con)
      close(con)
    } else {
      # Handle local directory
      cat("Reading", swc_filename, "from directory:", zip_path, "\n")
      swc_path <- file.path(zip_path, swc_filename)
      lines <- readLines(swc_path)
    }
  }

  # Return raw if requested
  if (format == "raw") {
    return(lines)
  }

  # Write to temp file for parsing
  tmp_swc <- tempfile(fileext = ".swc")
  on.exit(unlink(tmp_swc), add = TRUE)
  writeLines(lines, tmp_swc)

  # Parse with nat or as data frame
  if (format == "nat") {
    neuron <- nat::read.neuron(tmp_swc)
    cat("✓ Loaded neuron:", nrow(neuron$d), "points\n")
    return(neuron)
  } else {
    # Parse as data frame
    neuron_df <- parse_swc(lines)
    return(neuron_df)
  }
}

#' Parse SWC File Content
#'
#' Parses SWC format data into a structured data frame.
#'
#' @param lines Character vector of SWC file lines
#'
#' @return Data frame with columns: PointNo, Label, X, Y, Z, R, Parent
#'
#' @details
#' SWC format:
#' - Lines starting with # are comments (skipped)
#' - Data lines: PointNo Label X Y Z R Parent
#' - Label types: -1=root, 0=undefined, 1=soma, 2=axon, 3=dendrite,
#'   4=apical dendrite, 5-6=custom, 7=primary dendrite, 9=primary neurite
#'
#' @examples
#' \dontrun{
#' lines <- readLines("neuron.swc")
#' neuron_df <- parse_swc(lines)
#' }
#'
#' @export
parse_swc <- function(lines) {
  # Remove comments and empty lines
  data_lines <- lines[!grepl("^#", lines) & nchar(trimws(lines)) > 0]

  if (length(data_lines) == 0) {
    warning("No data found in SWC file")
    return(data.frame())
  }

  # Parse into data frame
  # Expected format: PointNo Label X Y Z R Parent
  swc_df <- read.table(text = data_lines,
                       col.names = c("PointNo", "Label", "X", "Y", "Z", "R", "Parent"),
                       colClasses = c("integer", "integer", "numeric", "numeric",
                                     "numeric", "numeric", "integer"))

  cat("✓ Parsed SWC:", nrow(swc_df), "points\n")

  return(swc_df)
}

#' Batch Read Multiple SWC Files from ZIP
#'
#' Efficiently reads multiple SWC files from a ZIP archive.
#' Useful for loading a set of neurons at once.
#'
#' @param zip_path Path to ZIP file (can be gs:// for GCS or local path)
#' @param swc_filenames Character vector of SWC filenames to read
#' @param gcs_filesystem Optional GCS filesystem object (required for GCS paths)
#' @param format Return format: "nat" (default), "dataframe", or "neuronlist"
#' @param show_progress Show progress messages (default: TRUE)
#'
#' @return
#' - If format="nat": Named list of nat::neuron objects
#' - If format="dataframe": Named list of data frames
#' - If format="neuronlist": A nat::neuronlist object (for batch operations)
#'
#' @details
#' For GCS paths, the ZIP is downloaded once, then all requested files are
#' extracted. This is much faster than calling read_swc_from_zip() repeatedly.
#'
#' The "neuronlist" format returns a nat::neuronlist object which supports:
#' - Batch plotting: plot3d(neurons)
#' - Batch operations: nlapply()
#' - Summary statistics across neurons
#'
#' @examples
#' \dontrun{
#' # Read as neuronlist (recommended for multiple neurons)
#' neurons <- batch_read_swc_from_zip("skeletons.zip",
#'                                    c("n1.swc", "n2.swc"),
#'                                    format = "neuronlist")
#' plot3d(neurons)
#' summary(neurons)
#'
#' # Read as list of neurons
#' neurons <- batch_read_swc_from_zip("skeletons.zip",
#'                                    c("n1.swc", "n2.swc"))
#' plot3d(neurons[[1]])
#' }
#'
#' @export
batch_read_swc_from_zip <- function(zip_path, swc_filenames,
                                    gcs_filesystem = NULL,
                                    format = c("nat", "dataframe", "neuronlist"),
                                    show_progress = TRUE) {
  format <- match.arg(format)
  is_gcs <- grepl("^gs://", zip_path)
  is_zip <- grepl("\\.zip$", zip_path, ignore.case = TRUE)

  # Setup for reading
  local_zip_path <- NULL
  if (is_gcs && is_zip) {
    # Download ZIP from GCS only if it's a ZIP file
    if (is.null(gcs_filesystem)) {
      stop("gcs_filesystem argument required for GCS paths")
    }

    tmp_zip <- tempfile(fileext = ".zip")
    on.exit(unlink(tmp_zip), add = TRUE)

    if (show_progress) cat("Downloading ZIP from GCS:", zip_path, "\n")
    builtins <- reticulate::import_builtins()

    # Strip gs:// prefix for gcsfs
    gcs_path_clean <- sub("^gs://", "", zip_path)

    gcs_file <- gcs_filesystem$open(gcs_path_clean, "rb")
    py_bytes <- gcs_file$read()
    gcs_file$close()

    out_file <- builtins$open(tmp_zip, "wb")
    out_file$write(py_bytes)
    out_file$close()

    local_zip_path <- tmp_zip
  }

  # Read all requested files
  result <- list()
  n_files <- length(swc_filenames)

  for (i in seq_along(swc_filenames)) {
    filename <- swc_filenames[i]

    if (show_progress) {
      cat(sprintf("[%d/%d] Reading %s...\n", i, n_files, filename))
    }

    # Read file based on source type
    if (is_gcs) {
      if (is_zip) {
        # Read from downloaded ZIP
        con <- unz(local_zip_path, filename)
        lines <- readLines(con)
        close(con)
      } else {
        # Read directly from GCS directory
        gcs_path_clean <- sub("^gs://", "", zip_path)
        # Use paste with forward slashes for GCS (not file.path which uses system separator)
        swc_path <- paste(gcs_path_clean, filename, sep = "/")

        builtins <- reticulate::import_builtins()
        gcs_file <- gcs_filesystem$open(swc_path, "rb")
        py_bytes <- gcs_file$read()
        gcs_file$close()

        # Decode bytes to string in Python, then split in R
        text_content <- py_bytes$decode("utf-8")
        lines <- strsplit(text_content, "\n")[[1]]
      }
    } else {
      # Local path
      if (is_zip) {
        # Read from local ZIP
        con <- unz(zip_path, filename)
        lines <- readLines(con)
        close(con)
      } else {
        # Read from local directory
        swc_path <- file.path(zip_path, filename)
        lines <- readLines(swc_path)
      }
    }

    # Parse based on format
    if (format == "dataframe") {
      result[[filename]] <- parse_swc(lines)
    } else {
      # Parse with nat (for both "nat" and "neuronlist")
      tmp_swc <- tempfile(fileext = ".swc")
      writeLines(lines, tmp_swc)
      result[[filename]] <- nat::read.neuron(tmp_swc)
      unlink(tmp_swc)
    }
  }

  if (show_progress) cat("✓ Loaded", n_files, "SWC files\n")

  # Convert to neuronlist if requested
  if (format == "neuronlist") {
    result <- nat::as.neuronlist(result)
  }

  return(result)
}
