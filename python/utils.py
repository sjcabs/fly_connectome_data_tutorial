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


# BANC bucket root (used for skeleton / mesh assets that live outside compiled_data/)
BANC_BUCKET_ROOT = "gs://lee-lab_brain-and-nerve-cord-fly-connectome"


def construct_path(data_root, dataset, file_type="meta", space_suffix=None):
    """
    Build a path to a connectome data file in the new bucket layout.

    The new bucket is
    ``gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/{dataset}_{version}/``.

    Parameters
    ----------
    data_root : str
        Root data directory (e.g.
        ``"gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data"``) or a local
        mirror.
    dataset : str
        Dataset name with version (e.g. ``"banc_888"``, ``"fafb_783"``).
    file_type : str
        One of ``"meta"``, ``"synapses"``, ``"edgelist_simple"``, ``"edgelist_split"``,
        ``"edgelist"`` (alias for ``"edgelist_simple"``), ``"metrics"``, ``"skeletons"``.
    space_suffix : str, optional
        Space name for skeletons (defaults to native space, e.g. ``"banc_space"``).

    Returns
    -------
    str
        Full path to the requested file or directory.

    Notes
    -----
    BANC's compiled_data layout differs from the other datasets:
    - Edgelists are named ``banc_888_edgelist_simple_v3.feather`` and
      ``banc_888_edgelist_split.feather`` (not ``_simple_edgelist`` / ``_split_edgelist``).
    - Synapses are ``banc_888_synapses_v2_enriched.parquet``.
    - SWC skeletons live at
      ``gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons/swcs-from-pcg-skel/``,
      **not** inside ``compiled_data/banc_888/``.

    Examples
    --------
    >>> construct_path(
    ...     "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data",
    ...     "banc_888", "meta")
    'gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/banc_888_meta.feather'

    >>> construct_path(
    ...     "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data",
    ...     "banc_888", "skeletons")
    'gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons/swcs-from-pcg-skel'
    """
    dataset_name = dataset.split("_")[0]

    # Resolve aliases
    if file_type == "edgelist":
        file_type = "edgelist_simple"

    # BANC SWC skeletons live at the bucket root, not inside compiled_data/
    if file_type == "skeletons" and dataset_name == "banc":
        return f"{BANC_BUCKET_ROOT}/neuron_skeletons/swcs-from-pcg-skel"

    extensions = {
        "meta": ".feather",
        "metrics": ".feather",
        "synapses": ".parquet",
        "edgelist_simple": ".feather",
        "edgelist_split": ".feather",
        "skeletons": "",
    }
    if file_type not in extensions:
        raise ValueError(
            f"Unknown file_type: {file_type}. "
            f"Choose: {', '.join(extensions.keys())}"
        )
    extension = extensions[file_type]

    if file_type == "skeletons":
        if space_suffix is None:
            space_suffix = f"{dataset_name}_space"
        filename = f"{dataset_name}_{space_suffix}_swc{extension}"
    elif dataset_name == "banc":
        # BANC uses different naming inside compiled_data/banc_888/
        filename = {
            "meta":            f"{dataset}_meta{extension}",
            "metrics":         f"{dataset}_metrics{extension}",
            "synapses":        f"{dataset}_synapses_v2_enriched{extension}",
            "edgelist_simple": f"{dataset}_edgelist_simple_v3{extension}",
            "edgelist_split":  f"{dataset}_edgelist_split{extension}",
        }[file_type]
    else:
        filename = {
            "meta":            f"{dataset}_meta{extension}",
            "metrics":         f"{dataset}_metrics{extension}",
            "synapses":        f"{dataset}_synapses{extension}",
            "edgelist_simple": f"{dataset}_simple_edgelist{extension}",
            "edgelist_split":  f"{dataset}_split_edgelist{extension}",
        }[file_type]

    # New layout: compiled_data/{dataset}_{version}/{filename}
    return f"{data_root}/{dataset}/{filename}"


def construct_obj_path(data_root, dataset, subdir="."):
    """
    Path to OBJ mesh directory for a dataset.

    BANC's mesh assets are at ``gs://.../region_outlines/`` in Neuroglancer
    precomputed format (not OBJ files), so this returns ``None`` for BANC.
    Other datasets keep OBJ meshes under
    ``compiled_data/{dataset}_{version}/obj/``.

    Parameters
    ----------
    data_root : str
        Root data directory.
    dataset : str
        Dataset name with version (e.g. ``"fafb_783"``).
    subdir : str
        ``"."`` for the top-level OBJ directory, or ``"neuropils"``.

    Returns
    -------
    str or None
        Path to the mesh directory, or None for BANC.
    """
    if dataset.split("_")[0] == "banc":
        return None
    base = f"{data_root}/{dataset}/obj"
    if subdir in (".", None):
        return base
    return f"{base}/{subdir}"


# -----------------------------------------------------------------------------
# Region subsets — reproduces bancpipeline/banc/share/banc-sjcabs.R cut-out logic
# -----------------------------------------------------------------------------

REGION_SPECS = {
    "mushroom_body": dict(
        mode="metadata_with_kc_partners",
        pattern="mushroom_body|kenyon_cell|APL|DPM|LHMB1|OA-VPM3",
        side="right", min_synapses=100,
    ),
    "antennal_lobe": dict(
        mode="metadata",
        pattern="antennal_lobe|olfactory_receptor|thermosensory_receptor|hygrosensory_receptor|CSD",
        side=None, min_synapses=None,
    ),
    "central_complex": dict(
        mode="metadata",
        pattern="central_complex",
        side=None, min_synapses=None,
    ),
    "optic": dict(
        mode="synapse",
        pattern=r"^LO|^LOP|^AME|^ME",
        side="right", min_synapses=100,
    ),
    "suboesophageal_zone": dict(
        mode="synapse",
        pattern=r"^FLA|^SEZ|^GNG|^SAD|^AMMC|^PRW",
        side=None, min_synapses=100,
    ),
    "front_leg": dict(
        mode="synapse",
        pattern=r"^LegNp\(T1\)|T1|^ProNM-T1|^LNp_T1",
        side="right", min_synapses=100,
    ),
    "abdominal_neuromere": dict(
        mode="synapse",
        pattern=r"^ANm|^ABDNM|^ADNM",
        side=None, min_synapses=100,
    ),
}


def region_filter_spec(region):
    """Return the filter spec for a named region. See REGION_SPECS."""
    if region not in REGION_SPECS:
        raise ValueError(
            f"Unknown region: {region}. Choose: {', '.join(REGION_SPECS)}"
        )
    return REGION_SPECS[region]


def subset_by_region(meta, dataset, region, edgelist=None, synapses=None):
    """
    Reproduce a region cut-out in code.

    Mirrors ``bancpipeline/banc/share/banc-sjcabs.R``. The pre-computed cut-out
    folders that previously shipped with the bucket no longer exist; this helper
    rebuilds them from the dataset-level meta / edgelist / synapse tables.

    Parameters
    ----------
    meta : pandas.DataFrame
        Full metadata table for the dataset.
    dataset : str
        Dataset name with version (e.g. ``"banc_888"``). Used to pick the ID
        column name (``{dataset}_id``) and to know which synapse column names to
        expect.
    region : str
        Region name; see :func:`region_filter_spec`.
    edgelist : pandas.DataFrame, optional
        Required for ``mushroom_body``: used to find KC partners (≥100 synapses).
    synapses : pandas.DataFrame, optional
        Required for synapse-mode regions (``optic``, ``suboesophageal_zone``,
        ``front_leg``, ``abdominal_neuromere``). Must contain ``neuropil`` and
        pre/post columns; for BANC these are ``pre_root_id``/``post_root_id``,
        for other datasets ``pre``/``post``.

    Returns
    -------
    dict
        ``{"ids": list, "meta": pandas.DataFrame}``.
    """
    spec = region_filter_spec(region)
    id_col = f"{dataset}_id"
    if id_col not in meta.columns:
        raise ValueError(f"meta does not contain ID column '{id_col}'")

    def _meta_match(m, pattern, side=None):
        cols = ["super_class", "cell_class", "cell_sub_class", "cell_type"]
        mask = pd.Series(False, index=m.index)
        for c in cols:
            if c in m.columns:
                mask |= m[c].astype(str).str.contains(pattern, regex=True, na=False)
        m_filt = m[mask]
        if side is not None and "side" in m_filt.columns:
            m_filt = m_filt[m_filt["side"] == side]
        return m_filt

    if spec["mode"] == "metadata":
        meta_subset = _meta_match(meta, spec["pattern"], spec["side"])

    elif spec["mode"] == "metadata_with_kc_partners":
        if edgelist is None:
            raise ValueError(
                "subset_by_region(region='mushroom_body') requires `edgelist`."
            )
        kc_meta = meta[meta["cell_class"] == "kenyon_cell"]
        if spec["side"] is not None and "side" in kc_meta.columns:
            kc_meta = kc_meta[kc_meta["side"] == spec["side"]]
        kc_ids = set(kc_meta[id_col].astype(str).tolist())

        if not kc_ids:
            meta_subset = _meta_match(meta, spec["pattern"], spec["side"])
        else:
            el = edgelist.copy()
            el["pre"] = el["pre"].astype(str)
            el["post"] = el["post"].astype(str)
            mask = el["pre"].isin(kc_ids) | el["post"].isin(kc_ids)
            el = el.loc[mask].copy()
            el["pre"] = np.where(el["pre"].isin(kc_ids), "KC", el["pre"])
            el["post"] = np.where(el["post"].isin(kc_ids), "KC", el["post"])
            grouped = el.groupby(["pre", "post"], as_index=False)["count"].sum()
            grouped = grouped[grouped["count"] >= spec["min_synapses"]]
            partner_ids = (set(grouped["pre"].tolist()) | set(grouped["post"].tolist())) - kc_ids - {"KC"}
            ids_str = meta[id_col].astype(str)
            cols = ["super_class", "cell_class", "cell_sub_class", "cell_type"]
            mask = pd.Series(False, index=meta.index)
            for c in cols:
                if c in meta.columns:
                    mask |= meta[c].astype(str).str.contains(spec["pattern"], regex=True, na=False)
            mask |= ids_str.isin(partner_ids)
            if spec["side"] is not None and "side" in meta.columns:
                mask &= (meta["side"] == spec["side"])
            meta_subset = meta[mask]

    elif spec["mode"] == "synapse":
        if synapses is None:
            raise ValueError(
                f"subset_by_region(region='{region}') requires `synapses`."
            )
        pre_col = "pre_root_id" if "pre_root_id" in synapses.columns else "pre"
        post_col = "post_root_id" if "post_root_id" in synapses.columns else "post"
        syns = synapses[synapses["neuropil"].astype(str).str.contains(spec["pattern"], regex=True, na=False)]
        if spec["side"] is not None and "side" in syns.columns:
            syns = syns[syns["side"] == spec["side"]]
        pre_counts = syns[pre_col].value_counts()
        post_counts = syns[post_col].value_counts()
        chosen = set(pre_counts[pre_counts >= spec["min_synapses"]].index.tolist())
        chosen |= set(post_counts[post_counts >= spec["min_synapses"]].index.tolist())
        meta_subset = meta[meta[id_col].isin(chosen)]
    else:
        raise ValueError(f"Unknown spec mode: {spec['mode']}")

    ids = meta_subset[id_col].dropna().unique().tolist()
    return {"ids": ids, "meta": meta_subset}


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
# Neuron Compartment Visualization
# ==============================================================================

def split_neurons_by_compartment(neurons):
    """
    Split neurons by axon/dendrite compartments using Label column from SWC files.

    This function mimics R's hemibrainr cable extraction functions (axonic_cable,
    dendritic_cable, primary_dendrite_cable, primary_neurite_cable).

    Label mapping (from SWC standard):
    - 2 = axon
    - 3 = dendrite
    - 4 = primary dendrite (linker)
    - 7 = primary neurite (cell body fiber)

    Parameters
    ----------
    neurons : navis.NeuronList or list of navis.TreeNeuron
        Neurons to split by compartment

    Returns
    -------
    dict
        Dictionary with keys 'axon', 'dendrite', 'linker', 'neurite' containing
        navis.NeuronList objects for each compartment

    Examples
    --------
    >>> compartments = split_neurons_by_compartment(neurons)
    >>> axons = compartments['axon']
    >>> dendrites = compartments['dendrite']
    """
    import navis
    import pandas as pd

    axons = []
    dendrites = []
    linkers = []
    neurites = []

    for neuron in neurons:
        # Check if neuron has compartment labels
        if 'Label' in neuron.nodes.columns or 'label' in neuron.nodes.columns or 'compartment' in neuron.nodes.columns:
            label_col = 'Label' if 'Label' in neuron.nodes.columns else ('label' if 'label' in neuron.nodes.columns else 'compartment')

            # Get unique labels in this neuron
            unique_labels = neuron.nodes[label_col].unique()

            # Extract axon (Label == 2)
            if 2 in unique_labels:
                axon_nodes = neuron.nodes[neuron.nodes[label_col] == 2].node_id.values
                if len(axon_nodes) > 0:
                    axon_subset = navis.subset_neuron(neuron, axon_nodes)
                    axons.append(axon_subset)

            # Extract dendrite (Label == 3)
            if 3 in unique_labels:
                dendrite_nodes = neuron.nodes[neuron.nodes[label_col] == 3].node_id.values
                if len(dendrite_nodes) > 0:
                    dendrite_subset = navis.subset_neuron(neuron, dendrite_nodes)
                    dendrites.append(dendrite_subset)

            # Extract primary dendrite/linker (Label == 4)
            if 4 in unique_labels:
                linker_nodes = neuron.nodes[neuron.nodes[label_col] == 4].node_id.values
                if len(linker_nodes) > 0:
                    linker_subset = navis.subset_neuron(neuron, linker_nodes)
                    linkers.append(linker_subset)

            # Extract primary neurite (Label == 7)
            if 7 in unique_labels:
                neurite_nodes = neuron.nodes[neuron.nodes[label_col] == 7].node_id.values
                if len(neurite_nodes) > 0:
                    neurite_subset = navis.subset_neuron(neuron, neurite_nodes)
                    neurites.append(neurite_subset)

    return {
        'axon': navis.NeuronList(axons) if axons else navis.NeuronList([]),
        'dendrite': navis.NeuronList(dendrites) if dendrites else navis.NeuronList([]),
        'linker': navis.NeuronList(linkers) if linkers else navis.NeuronList([]),
        'neurite': navis.NeuronList(neurites) if neurites else navis.NeuronList([])
    }


def plot3d_split(neurons, volumes=None, backend='plotly', width=1200, height=800, title=None, **kwargs):
    """
    Plot neurons colored by axon/dendrite compartments (similar to R's hemibrainr functions).

    This function automatically splits neurons by their compartment labels and colors them:
    - Orange: axon
    - Cyan: dendrite
    - Green: linker (primary dendrite)
    - Purple: neurite (primary neurite/cell body fiber)
    - Grey: volumes (if provided)

    Parameters
    ----------
    neurons : navis.NeuronList or list of navis.TreeNeuron
        Neurons to plot (must have Label/label/compartment column in nodes)
    volumes : navis.Volume or list of navis.Volume, optional
        Neuropil volumes to include
    backend : str
        Plotting backend ('plotly', 'octarine', etc.)
    width : int
        Plot width in pixels
    height : int
        Plot height in pixels
    title : str, optional
        Plot title
    **kwargs
        Additional arguments passed to navis.plot3d()

    Returns
    -------
    fig
        Plotly/octarine figure object

    Examples
    --------
    >>> fig = plot3d_split(vpn_neurons, volumes=al_volume)
    >>> fig.show()
    """
    import navis

    # Split neurons by compartment
    compartments = split_neurons_by_compartment(neurons)

    # Prepare plot objects and colors
    plot_objects = []
    plot_colors = []

    # Add volumes first (if provided)
    if volumes is not None:
        if not isinstance(volumes, list):
            volumes = [volumes]
        plot_objects.extend(volumes)
        # Volumes don't use colors from plot3d - set on Volume object

    # Add compartments in order (dendrite, linker, axon, neurite)
    if len(compartments['dendrite']) > 0:
        plot_objects.extend(compartments['dendrite'])
        plot_colors.extend(['cyan'] * len(compartments['dendrite']))

    if len(compartments['linker']) > 0:
        plot_objects.extend(compartments['linker'])
        plot_colors.extend(['green'] * len(compartments['linker']))

    if len(compartments['axon']) > 0:
        plot_objects.extend(compartments['axon'])
        plot_colors.extend(['orange'] * len(compartments['axon']))

    if len(compartments['neurite']) > 0:
        plot_objects.extend(compartments['neurite'])
        plot_colors.extend(['purple'] * len(compartments['neurite']))

    # Plot
    if len(plot_objects) > 0:
        fig = navis.plot3d(
            plot_objects,
            color=plot_colors if plot_colors else None,
            backend=backend,
            width=width,
            height=800,
            title=title if title else 'Neurons - Colored by Compartment',
            **kwargs
        )
        return fig
    else:
        print("⚠ No neurons or compartments to plot")
        return None


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
    'split_neurons_by_compartment', 'plot3d_split',

    # 3D meshes
    'trimesh', 'read_obj_from_gcs',

    # Helper functions
    'setup_gcs', 'construct_path', 'construct_obj_path',
    'region_filter_spec', 'subset_by_region', 'REGION_SPECS',
    'BANC_BUCKET_ROOT',
    'read_feather_gcs', 'read_parquet_gcs',
    'save_figure', 'save_plot',
]
