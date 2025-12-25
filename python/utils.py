"""
Utility Functions for Python Fly Connectome Tutorials
======================================================

This module provides:
- Common package imports
- Warning suppression
- Helper functions for data access (GCS and local)
- Plotting utilities

Import this at the start of each tutorial notebook:
    from utils import *
"""

# ==============================================================================
# Package Imports
# ==============================================================================

# Core data manipulation
import pandas as pd
import numpy as np

# File I/O
import pyarrow.feather as feather
import pyarrow.parquet as pq
import gcsfs
import io
import os
import re
import tempfile
from pathlib import Path

# Visualization
import matplotlib.pyplot as plt
import seaborn as sns
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots

# Network analysis
import networkx as nx

# Scientific computing
from scipy.cluster.hierarchy import linkage, dendrogram, cut_tree
from scipy.spatial.distance import pdist, squareform
from scipy.stats import pearsonr, spearmanr
import umap

# Progress bars
from tqdm.auto import tqdm

# Collections
from collections import Counter

# Neuron analysis
import navis

# Trimesh for 3D meshes
import trimesh

# ==============================================================================
# Configuration and Warning Suppression
# ==============================================================================

# Suppress warnings for cleaner output
import warnings
warnings.filterwarnings('ignore', category=FutureWarning)
warnings.filterwarnings('ignore', category=DeprecationWarning)
warnings.filterwarnings('ignore', category=UserWarning, module='plotly')

# Pandas display settings
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', 20)
pd.set_option('display.width', None)

# Matplotlib settings
plt.rcParams['figure.dpi'] = 100
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['savefig.bbox'] = 'tight'

# Seaborn style
sns.set_style("whitegrid")

# Navis settings
navis.config.pbar_hide = True

print("✓ Packages loaded successfully")

# ==============================================================================
# Helper Functions
# ==============================================================================

def setup_gcs(token='google_default'):
    """
    Setup Google Cloud Storage filesystem.

    Parameters
    ----------
    token : str
        Authentication token ('google_default' or 'anon')

    Returns
    -------
    gcsfs.GCSFileSystem
        Authenticated GCS filesystem object

    Notes
    -----
    Before using with authenticated buckets:
        gcloud auth application-default login
    """
    gcs = gcsfs.GCSFileSystem(token=token)
    return gcs


def construct_path(data_root, dataset, file_type="meta", space_suffix=None):
    """
    Construct file paths for dataset files.

    Parameters
    ----------
    data_root : str
        Root data directory (can be gs:// or local path)
    dataset : str
        Dataset name with version (e.g., "banc_746")
    file_type : str
        Type of file: "meta", "edgelist", "edgelist_simple", "synapses", "skeletons"
    space_suffix : str, optional
        Space name for skeletons (defaults to native space)

    Returns
    -------
    str
        Full path to the file

    Examples
    --------
    >>> path = construct_path("gs://bucket/data", "banc_746", "meta")
    >>> # Returns: gs://bucket/data/banc/banc_746_meta.feather
    """
    dataset_name = dataset.split("_")[0]

    extensions = {
        "meta": ".feather",
        "edgelist": ".feather",
        "edgelist_simple": ".feather",
        "synapses": ".parquet",
        "skeletons": ""  # Directory
    }

    if file_type not in extensions:
        raise ValueError(f"Unknown file_type: {file_type}. Choose: {', '.join(extensions.keys())}")

    extension = extensions[file_type]

    if file_type == "skeletons":
        if space_suffix is None:
            space_suffix = f"{dataset_name}_space"

        # BANC uses l2 skeletons
        if dataset_name == "banc":
            filename = f"{dataset_name}_{space_suffix}_l2_swc{extension}"
        else:
            filename = f"{dataset_name}_{space_suffix}_swc{extension}"
    elif file_type == "edgelist_simple":
        # Note: "simple" comes before "edgelist" in filename
        filename = f"{dataset}_simple_edgelist{extension}"
    else:
        filename = f"{dataset}_{file_type}{extension}"

    full_path = f"{data_root}/{dataset_name}/{filename}"
    return full_path


def read_feather_gcs(path, gcs_fs=None, cache_dir=".cache", use_cache=True):
    """
    Read Feather file from GCS or local path with caching support.

    Parameters
    ----------
    path : str
        Path to feather file (can start with gs:// for GCS)
    gcs_fs : gcsfs.GCSFileSystem, optional
        GCS filesystem object (required for GCS paths)
    cache_dir : str
        Local directory for caching downloaded files (default: .cache)
    use_cache : bool
        Whether to use local caching (default: True)

    Returns
    -------
    pd.DataFrame
        Loaded data

    Notes
    -----
    When use_cache=True and path is a GCS path:
    - First run: downloads from GCS and saves to cache_dir
    - Subsequent runs: loads from cache (much faster!)
    """
    if path.startswith("gs://"):
        if gcs_fs is None:
            raise ValueError("gcs_fs required for GCS paths")

        # Generate cache filename
        cache_filename = path.replace("gs://", "").replace("/", "_")
        cache_path = os.path.join(cache_dir, cache_filename)

        # Check if cached version exists
        if use_cache and os.path.exists(cache_path):
            print(f"📦 Loading from cache: {cache_filename}")
            df = pd.read_feather(cache_path)
            print(f"✓ Loaded {len(df):,} rows (cached)")
            return df

        # Download from GCS with progress
        gcs_path = path.replace("gs://", "")

        print(f"📥 Downloading from GCS: {os.path.basename(gcs_path)}")

        # Get file size for progress bar
        try:
            file_info = gcs_fs.info(gcs_path)
            file_size = file_info.get('size', 0)
            file_size_mb = file_size / (1024 * 1024)
            print(f"   Size: {file_size_mb:.1f} MB")
        except:
            file_size = None

        # Read with progress indication
        with gcs_fs.open(gcs_path, 'rb') as f:
            if file_size:
                # Wrap file object with tqdm for progress
                with tqdm(total=file_size, unit='B', unit_scale=True, desc="Downloading") as pbar:
                    # Read in chunks to show progress
                    chunks = []
                    chunk_size = 1024 * 1024  # 1MB chunks
                    while True:
                        chunk = f.read(chunk_size)
                        if not chunk:
                            break
                        chunks.append(chunk)
                        pbar.update(len(chunk))

                    # Combine chunks and parse
                    content = b''.join(chunks)
                    df = feather.read_feather(io.BytesIO(content))
            else:
                # Fallback without progress
                df = feather.read_feather(f)

        print(f"✓ Loaded {len(df):,} rows from GCS")

        # Cache for future use
        if use_cache:
            os.makedirs(cache_dir, exist_ok=True)
            df.to_feather(cache_path)
            print(f"💾 Cached to: {cache_path}")

        return df
    else:
        # Local file
        df = pd.read_feather(path)
        print(f"✓ Loaded {len(df):,} rows")
        return df


def read_parquet_gcs(path, gcs_fs=None, columns=None, cache_dir=".cache", use_cache=True):
    """
    Read Parquet file from GCS or local path with caching support.

    Parameters
    ----------
    path : str
        Path to parquet file
    gcs_fs : gcsfs.GCSFileSystem, optional
        GCS filesystem object (required for GCS paths)
    columns : list, optional
        List of columns to load (None = all)
    cache_dir : str
        Local directory for caching downloaded files (default: .cache)
    use_cache : bool
        Whether to use local caching (default: True)

    Returns
    -------
    pd.DataFrame
        Loaded data

    Notes
    -----
    When use_cache=True and path is a GCS path:
    - First run: downloads from GCS and saves to cache_dir
    - Subsequent runs: loads from cache (much faster!)
    """
    if path.startswith("gs://"):
        if gcs_fs is None:
            raise ValueError("gcs_fs required for GCS paths")

        # Generate cache filename
        cache_filename = path.replace("gs://", "").replace("/", "_")
        cache_path = os.path.join(cache_dir, cache_filename)

        # Check if cached version exists
        if use_cache and os.path.exists(cache_path):
            print(f"📦 Loading from cache: {cache_filename}")
            df = pd.read_parquet(cache_path, columns=columns)
            print(f"✓ Loaded {len(df):,} rows (cached)")
            return df

        # Download from GCS with progress
        gcs_path = path.replace("gs://", "")

        print(f"📥 Downloading from GCS: {os.path.basename(gcs_path)}")

        # Get file size for progress bar
        try:
            file_info = gcs_fs.info(gcs_path)
            file_size = file_info.get('size', 0)
            file_size_mb = file_size / (1024 * 1024)
            print(f"   Size: {file_size_mb:.1f} MB")
        except:
            file_size = None

        # Read with progress indication
        with gcs_fs.open(gcs_path, 'rb') as f:
            if file_size:
                # Wrap file object with tqdm for progress
                with tqdm(total=file_size, unit='B', unit_scale=True, desc="Downloading") as pbar:
                    # Read in chunks to show progress
                    chunks = []
                    chunk_size = 1024 * 1024  # 1MB chunks
                    while True:
                        chunk = f.read(chunk_size)
                        if not chunk:
                            break
                        chunks.append(chunk)
                        pbar.update(len(chunk))

                    # Combine chunks and parse
                    content = b''.join(chunks)
                    df = pq.read_table(io.BytesIO(content), columns=columns).to_pandas()
            else:
                # Fallback without progress
                df = pq.read_table(f, columns=columns).to_pandas()

        print(f"✓ Loaded {len(df):,} rows from GCS")

        # Cache for future use (save full file even if only some columns were requested)
        if use_cache:
            os.makedirs(cache_dir, exist_ok=True)
            # Re-read full table for caching if columns were specified
            if columns is not None:
                with gcs_fs.open(gcs_path, 'rb') as f:
                    full_df = pq.read_table(f).to_pandas()
                full_df.to_parquet(cache_path)
            else:
                df.to_parquet(cache_path)
            print(f"💾 Cached to: {cache_path}")

        return df
    else:
        # Local file
        df = pd.read_parquet(path, columns=columns)
        print(f"✓ Loaded {len(df):,} rows")
        return df


def read_swc_from_gcs(gcs_fs, swc_path):
    """
    Read a single SWC file from GCS using navis.

    Parameters
    ----------
    gcs_fs : gcsfs.GCSFileSystem
        GCS filesystem object
    swc_path : str
        GCS path to SWC file (without gs:// prefix)

    Returns
    -------
    navis.TreeNeuron
        Loaded neuron
    """
    with gcs_fs.open(swc_path, 'rb') as f:
        content = f.read()

    swc_file = io.BytesIO(content)
    neuron = navis.read_swc(swc_file)

    return neuron


def batch_read_swc_from_gcs(gcs_fs, directory, filenames, show_progress=True):
    """
    Batch read multiple SWC files from GCS.

    Parameters
    ----------
    gcs_fs : gcsfs.GCSFileSystem
        GCS filesystem object
    directory : str
        GCS directory path (without gs:// prefix)
    filenames : list of str
        List of SWC filenames to read
    show_progress : bool
        Whether to show progress bar

    Returns
    -------
    navis.NeuronList
        List of loaded neurons
    """
    neurons = []

    iterator = tqdm(filenames, desc="Reading neurons") if show_progress else filenames

    for filename in iterator:
        swc_path = f"{directory}/{filename}"
        try:
            neuron = read_swc_from_gcs(gcs_fs, swc_path)
            neurons.append(neuron)
        except Exception as e:
            if show_progress:
                print(f"Error reading {filename}: {e}")
            continue

    return navis.NeuronList(neurons)


def read_obj_from_gcs(gcs_fs, obj_path):
    """
    Read OBJ mesh file from GCS.

    Parameters
    ----------
    gcs_fs : gcsfs.GCSFileSystem
        GCS filesystem object
    obj_path : str
        GCS path to OBJ file (without gs:// prefix)

    Returns
    -------
    trimesh.Trimesh
        Loaded mesh
    """
    with gcs_fs.open(obj_path, 'rb') as f:
        content = f.read()

    with tempfile.NamedTemporaryFile(suffix='.obj', delete=False) as tmp:
        tmp.write(content)
        tmp_path = tmp.name

    try:
        mesh = trimesh.load_mesh(tmp_path)
    finally:
        os.unlink(tmp_path)

    return mesh


def save_figure(fig, filename, format='png', **kwargs):
    """
    Save matplotlib or plotly figure.

    Parameters
    ----------
    fig : matplotlib.figure.Figure or plotly.graph_objects.Figure
        Figure to save
    filename : str
        Output filename
    format : str
        Output format ('png', 'html', 'svg', etc.)
    **kwargs
        Additional arguments passed to savefig/write_* functions
    """
    # Check if it's a plotly figure
    if hasattr(fig, 'write_html'):
        # Plotly figure
        if format == 'html':
            fig.write_html(filename, **kwargs)
        elif format == 'png':
            fig.write_image(filename, **kwargs)
        else:
            raise ValueError(f"Unsupported format for plotly: {format}")
    else:
        # Matplotlib figure
        fig.savefig(filename, format=format, **kwargs)

    print(f"✓ Saved figure: {filename}")


def save_plot(fig, name, img_dir=None, format='png', **kwargs):
    """
    Save plot to image directory (convenience wrapper).

    Parameters
    ----------
    fig : matplotlib.figure.Figure or plotly.graph_objects.Figure
        Figure to save
    name : str
        Base name (without extension or directory)
    img_dir : str, optional
        Image directory (defaults to IMG_DIR if set in globals)
    format : str
        Output format ('png', 'html', 'svg', etc.)
    **kwargs
        Additional arguments passed to save_figure
    """
    # Use IMG_DIR from globals if available
    if img_dir is None:
        import sys
        frame = sys._getframe(1)
        img_dir = frame.f_globals.get('IMG_DIR', '.')

    # Construct full path
    filename = os.path.join(img_dir, f"{name}.{format}")

    # Save using save_figure
    save_figure(fig, filename, format=format, **kwargs)

    print(f"✓ Saved plot to {filename}")


# ==============================================================================
# Export commonly used items
# ==============================================================================

__all__ = [
    # Packages
    'pd', 'np', 'plt', 'sns', 'go', 'px', 'nx',
    'feather', 'pq', 'gcsfs', 'umap',
    'linkage', 'dendrogram', 'cut_tree', 'pdist', 'squareform',
    'pearsonr', 'spearmanr', 'tqdm', 'Counter',
    'make_subplots', 'io', 're', 'os', 'tempfile',

    # Neuron analysis
    'navis', 'read_swc_from_gcs', 'batch_read_swc_from_gcs',

    # 3D meshes
    'trimesh', 'read_obj_from_gcs',

    # Helper functions
    'setup_gcs', 'construct_path',
    'read_feather_gcs', 'read_parquet_gcs',
    'save_figure', 'save_plot'
]
