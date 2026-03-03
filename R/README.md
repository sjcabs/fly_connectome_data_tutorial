# R Tutorials for Fly Connectome Data

This directory contains R markdown tutorials for analyzing Drosophila connectome datasets.

## Quick Links

- [Tutorials](#tutorials)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Setup Environment](#setup-environment)
  - [Data Access](#data-access)
  - [Running Tutorials](#running-tutorials)
- [Tutorial Structure](#tutorial-structure)
- [Template Code for Common Analyses](#template-code-for-common-analyses)
  - [Data Preparation](#data-preparation)
  - [Clustering & Dimensionality Reduction](#clustering--dimensionality-reduction)
  - [Network Analysis](#network-analysis)
  - [Visualization](#visualization)
  - [Helper Functions](#helper-functions)
- [Key Packages](#key-packages)
- [Help & Support](#help--support)

---

## Tutorials

1. **[01_data_access.Rmd](01_data_access.Rmd)** - Loading and exploring connectome metadata and synapses
2. **[02_neuron_morphology.Rmd](02_neuron_morphology.Rmd)** - 3D neuron visualization and morphological analysis
3. **[03_connectivity_analyses.Rmd](03_connectivity_analyses.Rmd)** - Network analysis and connectivity patterns
4. **[04_indirect_connectivity.Rmd](04_indirect_connectivity.Rmd)** - Influence scores and multi-hop connectivity

## Getting Started

### Installation

Install R (≥4.0) and the required packages:

```r
# Install natmanager
install.packages("natmanager")

# Install core natverse packages
natmanager::install(pkgs = "core")

# Install additional packages
install.packages(c("tidyverse", "arrow", "reticulate"))

# Install Python dependencies for fafbseg
library(fafbseg)
simple_python()
```

### Setup Environment

Run the setup script to create a conda environment with all dependencies:

```bash
bash inst/fly_connectome_data_tutorial_sjcabs_env.sh
```

Then activate the environment:

```bash
conda activate sjcabs
```

### Data Access

Tutorials access data from Google Cloud Storage: `gs://brain-and-nerve-cord_exports/processed_data/`

**Authentication:**
```bash
gcloud auth application-default login
```

**Or download data locally:**
```bash
# Download specific dataset
gsutil -m cp -r gs://brain-and-nerve-cord_exports/processed_data/banc/ ~/data/sjcabs_data/
```

### Running Tutorials

Open tutorials in RStudio:

```r
# Set working directory
setwd("R/")

# Open first tutorial
file.edit("01_data_access.Rmd")
```

Or use command line:

```bash
# Render to HTML
Rscript -e "rmarkdown::render('R/01_data_access.Rmd')"
```

## Tutorial Structure

Each tutorial follows the same pattern:
- **Core Tutorial**: Essential concepts and analyses (~15-30 minutes)
- **Your Turn**: Exercises to apply concepts to new datasets
- **Extensions**: Advanced analyses and methods (optional)
- **Summary**: Key takeaways and next steps

---

## Template Code for Common Analyses

This section provides reusable code patterns for common connectome analyses. All examples assume the data structures from `gs://brain-and-nerve-cord_exports/processed_data/`:

**Data files:**
- `*_meta.feather` - Neuron metadata (columns: root_id, flow, super_class, cell_class, cell_sub_class, cell_type, neurotransmitter_predicted, etc.)
- `*_simple_edgelist.feather` - Connectivity (columns: pre, post, count, norm)
- `*_synapses.feather` - Individual synapses (columns: pre_root_id, post_root_id, x, y, z, etc.)

### Data Preparation

#### Loading Connectome Data

```r
library(arrow)
library(dplyr)

# Load metadata
meta <- read_feather("banc_746_meta.feather")

# Load edgelist
edgelist <- read_feather("banc_746_simple_edgelist.feather")

# Join with metadata to get cell type annotations
edgelist_annotated <- edgelist %>%
  left_join(meta %>% select(root_id, cell_type, super_class, cell_class,
                            neurotransmitter_predicted),
            by = c("pre" = "root_id")) %>%
  rename(pre_cell_type = cell_type,
         pre_super_class = super_class,
         pre_cell_class = cell_class,
         pre_nt = neurotransmitter_predicted) %>%
  left_join(meta %>% select(root_id, cell_type, super_class, cell_class),
            by = c("post" = "root_id")) %>%
  rename(post_cell_type = cell_type,
         post_super_class = super_class,
         post_cell_class = cell_class)
```

#### Creating Connectivity Matrices

```r
library(Matrix)
library(data.table)

# Filter and aggregate edgelist
setDT(edgelist_annotated)
edgelist_filtered <- edgelist_annotated[
  norm >= 0.005 & count > 10 & pre != post,
  .(count = sum(count, na.rm = TRUE),
    norm = mean(norm, na.rm = TRUE)),
  by = .(pre, post)
]

# Create sparse matrix
pre_index <- as.integer(factor(edgelist_filtered$pre))
post_index <- as.integer(factor(edgelist_filtered$post))

conn_matrix <- sparseMatrix(
  i = pre_index,
  j = post_index,
  x = edgelist_filtered$norm,
  dims = c(length(unique(edgelist_filtered$pre)),
           length(unique(edgelist_filtered$post))),
  dimnames = list(unique(edgelist_filtered$pre),
                  unique(edgelist_filtered$post))
)

# Symmetrize for undirected analysis
A_sym <- conn_matrix + t(conn_matrix)
diag(A_sym) <- 0
```

#### Aggregating by Cell Type

```r
# Collapse connections by cell type
collapsed_edgelist <- edgelist_annotated %>%
  group_by(pre_cell_type, post_cell_type,
           pre_super_class, post_super_class) %>%
  summarise(
    weight = sum(count, na.rm = TRUE),
    mean_norm = mean(norm, na.rm = TRUE),
    n_connections = n()
  ) %>%
  filter(pre_cell_type != post_cell_type,
         weight >= 10)
```

### Clustering & Dimensionality Reduction

#### Cosine Similarity & Hierarchical Clustering

```r
library(lsa)

# Calculate cosine similarity
cosine_sim_matrix <- lsa::cosine(as.matrix(conn_matrix))
cosine_sim_matrix[is.na(cosine_sim_matrix)] <- 0

# Hierarchical clustering
hclust_result <- hclust(as.dist(1 - cosine_sim_matrix),
                        method = "ward.D2")

# Cut tree to get clusters
n_clusters <- 12
clusters <- cutree(hclust_result, k = n_clusters)
```

#### Spectral Clustering

```r
library(reticulate)

# Import Python modules
scipy_csgraph <- import("scipy.sparse.csgraph")
scipy_sparse_linalg <- import("scipy.sparse.linalg")
sklearn <- import("sklearn")

# Convert to Python
A_py <- r_to_py(as(A_sym, "dgCMatrix"))

# Compute normalized Laplacian
laplacian <- scipy_csgraph$laplacian(A_py, normed = TRUE)

# Compute eigenvectors
num_clusters <- 12
eig_result <- scipy_sparse_linalg$eigsh(
  laplacian,
  k = as.integer(num_clusters),
  which = "SM"  # smallest magnitude
)

eigvec <- eig_result[[2]]

# Normalize eigenvectors
normalize_py <- sklearn$preprocessing$normalize
embedding <- normalize_py(eigvec)

# K-means on embedding
KMeans <- sklearn$cluster$KMeans
kmeans <- KMeans(
  n_clusters = as.integer(num_clusters),
  n_init = 10L,
  random_state = 42L
)
labels <- kmeans$fit_predict(embedding)

# Convert back to R
spectral_clusters <- py_to_r(labels) + 1
```

#### UMAP Dimensionality Reduction

```r
library(uwot)

# Create connectivity matrix (rows = neurons, cols = partners)
influence_matrix <- reshape2::acast(
  data = connectivity_data,
  formula = pre ~ post,
  value.var = "norm",
  fun.aggregate = mean,
  fill = 0
)

# Clean matrix
influence_matrix[is.na(influence_matrix)] <- 0
influence_matrix[is.infinite(influence_matrix)] <- 0

# Run UMAP with cosine metric
set.seed(42)
umap_result <- uwot::umap(
  influence_matrix,
  metric = "cosine",
  n_epochs = 500,
  n_neighbors = 30,
  min_dist = 0.05,
  n_components = 2
)

# Create data frame
umap_df <- data.frame(
  UMAP1 = umap_result[,1],
  UMAP2 = umap_result[,2],
  root_id = rownames(umap_result)
)
```

### Network Analysis

#### Creating igraph from Edgelist

```r
library(igraph)
library(ggraph)
library(tidygraph)

# Prepare vertices (nodes)
vertices <- bind_rows(
  edgelist_annotated %>% select(cell_type = pre_cell_type,
                                super_class = pre_super_class),
  edgelist_annotated %>% select(cell_type = post_cell_type,
                                super_class = post_super_class)
) %>%
  distinct(cell_type, .keep_all = TRUE)

# Create graph
g <- graph_from_data_frame(
  d = edgelist_annotated %>% select(pre_cell_type, post_cell_type,
                                    weight = count, pre_nt),
  directed = TRUE,
  vertices = vertices
)
```

#### Community Detection

```r
# Infomap algorithm
communities <- cluster_infomap(g)

# Leiden algorithm (via Python)
library(reticulate)
leidenalg <- import("leidenalg")
py_igraph <- import("igraph")

# Convert to Python igraph
g_py <- py_igraph$Graph$Adjacency(
  as.matrix(conn_matrix > 0),
  mode = "DIRECTED"
)

# Add weights
g_py$es$set_attribute_values("weight", edgelist_filtered$norm)

# Run Leiden
partition <- leidenalg$find_partition(
  g_py,
  leidenalg$RBConfigurationVertexPartition,
  weights = g_py$es['weight'],
  seed = 42L
)

leiden_clusters <- py_to_r(partition$membership) + 1
```

### Visualization

#### UMAP Plot with ggplot2

```r
library(ggplot2)
library(ggrepel)

# Calculate centroids for labels
cluster_centroids <- umap_df %>%
  group_by(cluster) %>%
  summarise(
    UMAP1 = mean(UMAP1),
    UMAP2 = mean(UMAP2)
  )

# Plot
p <- ggplot(umap_df, aes(x = UMAP1, y = UMAP2, color = cluster)) +
  geom_density_2d(col = "grey70", alpha = 0.5) +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_manual(values = cluster_colors) +
  theme_void() +
  geom_text_repel(
    data = cluster_centroids,
    aes(label = cluster),
    colour = "black",
    size = 6,
    fontface = "bold"
  ) +
  theme(legend.position = "none")
```

#### Heatmap with pheatmap

```r
library(pheatmap)

# Prepare matrix
heatmap_matrix <- connectivity_data %>%
  reshape2::dcast(
    pre_cell_class ~ post_cell_class,
    fun.aggregate = sum,
    value.var = "count",
    fill = 0
  )

# Set row names
rownames(heatmap_matrix) <- heatmap_matrix$pre_cell_class
heatmap_matrix$pre_cell_class <- NULL
heatmap_matrix <- as.matrix(heatmap_matrix)

# Min-max normalization
minmax_normalize <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}
normalized_matrix <- apply(heatmap_matrix, 2, minmax_normalize)

# Cluster using cosine similarity
cosine_sim_cols <- lsa::cosine(normalized_matrix)
cosine_sim_cols[is.na(cosine_sim_cols)] <- 0
hclust_cols <- hclust(as.dist(1 - cosine_sim_cols), method = "ward.D2")

cosine_sim_rows <- lsa::cosine(t(normalized_matrix))
cosine_sim_rows[is.na(cosine_sim_rows)] <- 0
hclust_rows <- hclust(as.dist(1 - cosine_sim_rows), method = "ward.D2")

# Create heatmap
pheatmap(
  normalized_matrix,
  cluster_rows = hclust_cols,
  cluster_cols = hclust_rows,
  color = colorRampPalette(c("white", "red"))(100),
  show_rownames = TRUE,
  show_colnames = TRUE,
  treeheight_row = 20,
  treeheight_col = 20,
  fontsize_col = 10,
  fontsize_row = 8,
  cellwidth = 12,
  cellheight = 12,
  border_color = NA
)
```

#### Network Graph with ggraph

```r
# Convert to tbl_graph
g <- as_tbl_graph(g, directed = TRUE) %>%
  activate(nodes) %>%
  mutate(
    degree = centrality_degree(mode = "total"),
    community = as.factor(communities$membership)
  )

# Create layout
layout <- create_layout(g, layout = "sugiyama")  # hierarchical
# Other options: "fr" (force-directed), "kk", "drl", "graphopt"

# Plot network
ggraph(layout) +
  geom_edge_bend(
    aes(width = weight, color = pre_nt),
    alpha = 0.5,
    arrow = arrow(length = unit(2, 'mm'), type = "closed"),
    start_cap = circle(3, 'mm'),
    end_cap = circle(3, 'mm')
  ) +
  geom_node_point(
    aes(color = super_class, size = degree)
  ) +
  geom_node_text(
    aes(label = name),
    repel = TRUE,
    size = 3
  ) +
  scale_edge_width(range = c(0.1, 1)) +
  scale_size_continuous(range = c(2, 7)) +
  theme_graph() +
  theme(legend.position = "right")
```

### Helper Functions

```r
# Min-max normalization
minmax_normalize <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

# Z-score normalization
zscore_normalize <- function(x) {
  (x - mean(x)) / sd(x)
}

# MAD (Median Absolute Deviation) normalization
mad_normalize <- function(x) {
  (x - median(x)) / mad(x)
}

# Symmetrize adjacency matrix
symmetrize <- function(A) {
  A_sym <- A + t(A)
  diag(A_sym) <- 0
  return(A_sym)
}

# Convert edgelist to matrix
edgelist_to_matrix <- function(el, value_col = "norm") {
  reshape2::acast(
    data = el,
    formula = pre ~ post,
    value.var = value_col,
    fun.aggregate = sum,
    fill = 0
  )
}
```

---

## Key Packages

**Core Analysis:**
- **nat/natverse**: NeuroAnatomy Toolbox for neuron analysis
- **neuprintr**: Query neuPrint connectome databases
- **nat.flybrains**: Coordinate transforms between template brains
- **bancr**: BANC-specific functions
- **fafbseg**: FlyWire/FAFB tools
- **influencer**: Influence score calculations

**Data Manipulation:**
- **dplyr**: Data wrangling
- **data.table**: Fast operations on large data
- **reshape2**: Wide ↔ long format conversion
- **arrow**: Reading Feather/Parquet files

**Network Analysis:**
- **Matrix**: Sparse matrix operations
- **igraph**: Graph creation, metrics, community detection
- **tidygraph**: Tidy graph manipulation
- **ggraph**: Graph visualization

**Clustering & Dimensionality Reduction:**
- **uwot**: UMAP implementation
- **lsa**: Cosine similarity calculations
- **kernlab**: Spectral clustering
- **reticulate**: Python integration for sklearn, scipy, leiden

**Visualization:**
- **pheatmap**: Heatmaps with dendrograms
- **ggplot2**: General plotting
- **ggrepel**: Non-overlapping text labels

## Help & Support

- **Package docs**: http://natverse.org/
- **GitHub issues**: https://github.com/sjcabs/fly_connectome_data_tutorial/issues
- **Workshop**: Contact instructors (Sven Dorkenwald, Alexander Bates)
