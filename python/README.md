# Python Tutorials for Fly Connectome Data

This directory contains Python Jupyter notebooks for analyzing Drosophila connectome datasets. All notebooks work seamlessly in both local Jupyter and Google Colab environments.

## Quick Links

- [Tutorials](#tutorials)
- [Getting Started](#getting-started)
  - [Option 1: Google Colab](#option-1-google-colab-recommended-for-workshop)
  - [Option 2: Local Installation](#option-2-local-installation)
  - [Data Access](#data-access)
- [Tutorial Structure](#tutorial-structure)
- [Template Code for Common Analyses](#template-code-for-common-analyses)
  - [Data Preparation](#data-preparation)
  - [Clustering & Dimensionality Reduction](#clustering--dimensionality-reduction)
  - [Network Analysis](#network-analysis)
  - [Visualization](#visualization)
  - [Helper Functions](#helper-functions)
- [Key Packages](#key-packages)
- [Google Colab Setup](#google-colab-setup)
- [Help & Support](#help--support)

---

## Tutorials

1. **[fly_connectome_01_data_access.ipynb](fly_connectome_01_data_access.ipynb)** - Loading and exploring connectome metadata and synapses
2. **[fly_connectome_02_neuron_morphology.ipynb](fly_connectome_02_neuron_morphology.ipynb)** - 3D neuron visualization and morphological analysis
3. **[fly_connectome_03_connectivity_analyses.ipynb](fly_connectome_03_connectivity_analyses.ipynb)** - Network analysis and connectivity patterns
4. **[fly_connectome_04_indirect_connectivity.ipynb](fly_connectome_04_indirect_connectivity.ipynb)** - Influence scores and multi-hop connectivity

## Getting Started

### Option 1: Google Colab (Recommended for Workshop)

**Zero setup required!** Notebooks auto-configure for Colab:

1. Open notebook in [Vertex AI Colab](https://console.cloud.google.com/vertex-ai/colab/notebooks)
2. Connect to runtime: `sjcabs-connectomics-tutorial`
3. Run all cells - auto-setup happens automatically

**First cell auto-detects Colab and:**
- Authenticates with Google Cloud
- Downloads helper module (`utils.py`)
- Verifies package installations

**Runtime templates** are provided in `runtimes/` directory - see [Google Colab Setup](#google-colab-setup) below.

### Option 2: Local Installation

Install Python (≥3.10) and required packages:

```bash
# Create conda environment
bash inst/fly_connectome_data_tutorial_sjcabs_env.sh

# Activate environment
conda activate sjcabs

# Launch Jupyter
jupyter lab python/fly_connectome_01_data_access.ipynb
```

**Or use pip:**
```bash
pip install pandas==2.3.3 numpy pyarrow gcsfs plotly kaleido navis[all]==1.10.0 trimesh scipy scikit-learn networkx umap-learn
```

### Data Access

Tutorials stream data from Google Cloud Storage: `gs://brain-and-nerve-cord_exports/processed_data/`

**Authentication:**
```bash
gcloud auth application-default login
```

**Or download locally:**
```bash
gsutil -m cp -r gs://brain-and-nerve-cord_exports/processed_data/banc/ ~/data/sjcabs_data/
```

## Tutorial Structure

Each tutorial includes:
- **Core Tutorial**: Essential concepts (~15-30 minutes)
- **Your Turn**: Hands-on exercises with new datasets
- **Extensions**: Advanced methods (optional)
- **Summary**: Key takeaways

---

## Template Code for Common Analyses

This section provides reusable code patterns for common connectome analyses. All examples assume the data structures from `gs://brain-and-nerve-cord_exports/processed_data/`:

**Data files:**
- `*_meta.feather` - Neuron metadata (columns: root_id, flow, super_class, cell_class, cell_sub_class, cell_type, neurotransmitter_predicted, etc.)
- `*_simple_edgelist.feather` - Connectivity (columns: pre, post, count, norm)
- `*_synapses.feather` - Individual synapses (columns: pre_root_id, post_root_id, x, y, z, etc.)

### Data Preparation

#### Loading Connectome Data

```python
import pandas as pd
import numpy as np

# Load metadata
meta = pd.read_feather("banc_888_meta.feather")

# Load edgelist (BANC names this `_edgelist_simple_v3` — other datasets use `_simple_edgelist`)
edgelist = pd.read_feather("banc_888_edgelist_simple_v3.feather")

# Join with metadata to get cell type annotations
edgelist_annotated = edgelist.merge(
    meta[['root_id', 'cell_type', 'super_class', 'cell_class',
          'neurotransmitter_predicted']],
    left_on='pre', right_on='root_id', how='left'
).rename(columns={
    'cell_type': 'pre_cell_type',
    'super_class': 'pre_super_class',
    'cell_class': 'pre_cell_class',
    'neurotransmitter_predicted': 'pre_nt'
}).drop(columns=['root_id'])

edgelist_annotated = edgelist_annotated.merge(
    meta[['root_id', 'cell_type', 'super_class', 'cell_class']],
    left_on='post', right_on='root_id', how='left'
).rename(columns={
    'cell_type': 'post_cell_type',
    'super_class': 'post_super_class',
    'cell_class': 'post_cell_class'
}).drop(columns=['root_id'])
```

#### Creating Connectivity Matrices

```python
from scipy.sparse import csr_matrix

# Filter edgelist
edgelist_filtered = edgelist_annotated[
    (edgelist_annotated['norm'] >= 0.005) &
    (edgelist_annotated['count'] > 10) &
    (edgelist_annotated['pre'] != edgelist_annotated['post'])
].groupby(['pre', 'post']).agg({
    'count': 'sum',
    'norm': 'mean'
}).reset_index()

# Create sparse matrix
unique_pre = edgelist_filtered['pre'].unique()
unique_post = edgelist_filtered['post'].unique()

pre_idx = {id: i for i, id in enumerate(unique_pre)}
post_idx = {id: i for i, id in enumerate(unique_post)}

row_indices = edgelist_filtered['pre'].map(pre_idx).values
col_indices = edgelist_filtered['post'].map(post_idx).values
values = edgelist_filtered['norm'].values

conn_matrix = csr_matrix(
    (values, (row_indices, col_indices)),
    shape=(len(unique_pre), len(unique_post))
)

# Symmetrize for undirected analysis
A_sym = conn_matrix + conn_matrix.T
A_sym.setdiag(0)
```

#### Aggregating by Cell Type

```python
# Collapse connections by cell type
collapsed_edgelist = edgelist_annotated.groupby([
    'pre_cell_type', 'post_cell_type',
    'pre_super_class', 'post_super_class'
]).agg({
    'count': 'sum',
    'norm': 'mean'
}).reset_index().rename(columns={'count': 'weight', 'norm': 'mean_norm'})

# Filter
collapsed_edgelist = collapsed_edgelist[
    (collapsed_edgelist['pre_cell_type'] != collapsed_edgelist['post_cell_type']) &
    (collapsed_edgelist['weight'] >= 10)
]
```

### Clustering & Dimensionality Reduction

#### Cosine Similarity & Hierarchical Clustering

```python
from sklearn.metrics.pairwise import cosine_similarity
from scipy.cluster.hierarchy import linkage, dendrogram, fcluster

# Calculate cosine similarity
cosine_sim_matrix = cosine_similarity(conn_matrix.toarray())
cosine_sim_matrix = np.nan_to_num(cosine_sim_matrix, 0)

# Hierarchical clustering
distance_matrix = 1 - cosine_sim_matrix
linkage_matrix = linkage(distance_matrix[np.triu_indices_from(distance_matrix, k=1)],
                         method='ward')

# Cut tree to get clusters
n_clusters = 12
clusters = fcluster(linkage_matrix, n_clusters, criterion='maxclust')
```

#### Spectral Clustering

```python
from sklearn.cluster import SpectralClustering

# Spectral clustering on adjacency matrix
sc = SpectralClustering(
    n_clusters=12,
    affinity='precomputed',
    assign_labels='kmeans',
    random_state=42
)

# Convert to dense (or use affinity='nearest_neighbors' for large matrices)
spectral_clusters = sc.fit_predict(A_sym.toarray())
```

#### UMAP Dimensionality Reduction

```python
import umap

# Create connectivity matrix (rows = neurons, cols = partners)
influence_matrix = edgelist.pivot_table(
    index='pre',
    columns='post',
    values='norm',
    aggfunc='mean',
    fill_value=0
)

# Clean matrix
influence_matrix = influence_matrix.replace([np.inf, -np.inf], 0).fillna(0)

# Run UMAP with cosine metric
reducer = umap.UMAP(
    metric='cosine',
    n_epochs=500,
    n_neighbors=30,
    min_dist=0.05,
    n_components=2,
    random_state=42
)

umap_embedding = reducer.fit_transform(influence_matrix.values)

# Create DataFrame
umap_df = pd.DataFrame({
    'UMAP1': umap_embedding[:, 0],
    'UMAP2': umap_embedding[:, 1],
    'root_id': influence_matrix.index
})
```

### Network Analysis

#### Creating NetworkX Graph from Edgelist

```python
import networkx as nx

# Create directed graph
G = nx.from_pandas_edgelist(
    edgelist_annotated,
    source='pre_cell_type',
    target='post_cell_type',
    edge_attr=['count', 'pre_nt'],
    create_using=nx.DiGraph()
)

# Add node attributes
node_attrs = {}
for idx, row in meta.iterrows():
    if row['cell_type'] in G.nodes:
        node_attrs[row['cell_type']] = {
            'super_class': row['super_class'],
            'cell_class': row['cell_class']
        }
nx.set_node_attributes(G, node_attrs)
```

#### Community Detection

```python
import community as community_louvain  # python-louvain package

# Louvain algorithm (undirected)
G_undirected = G.to_undirected()
communities = community_louvain.best_partition(G_undirected, random_state=42)

# Leiden algorithm (via leidenalg)
import leidenalg
import igraph as ig

# Convert to igraph
g_ig = ig.Graph.Adjacency(
    (conn_matrix > 0).toarray().tolist(),
    mode='DIRECTED'
)

# Add weights
g_ig.es['weight'] = edgelist_filtered['norm'].values

# Run Leiden
partition = leidenalg.find_partition(
    g_ig,
    leidenalg.RBConfigurationVertexPartition,
    weights=g_ig.es['weight'],
    seed=42
)

leiden_clusters = partition.membership
```

### Visualization

#### UMAP Plot with Plotly

```python
import plotly.express as px
import plotly.graph_objects as go

# Calculate centroids for labels
cluster_centroids = umap_df.groupby('cluster').agg({
    'UMAP1': 'mean',
    'UMAP2': 'mean'
}).reset_index()

# Create scatter plot
fig = px.scatter(
    umap_df,
    x='UMAP1',
    y='UMAP2',
    color='cluster',
    color_continuous_scale='Viridis',
    width=800,
    height=600
)

# Add cluster labels
fig.add_trace(go.Scatter(
    x=cluster_centroids['UMAP1'],
    y=cluster_centroids['UMAP2'],
    text=cluster_centroids['cluster'],
    mode='text',
    textfont=dict(size=14, color='black'),
    showlegend=False
))

fig.update_layout(template='plotly_white')
fig.show()
```

#### Heatmap with Plotly

```python
import plotly.graph_objects as go

# Prepare matrix
heatmap_matrix = edgelist_annotated.pivot_table(
    index='pre_cell_class',
    columns='post_cell_class',
    values='count',
    aggfunc='sum',
    fill_value=0
)

# Min-max normalization
def minmax_normalize(x):
    return (x - x.min()) / (x.max() - x.min())

normalized_matrix = heatmap_matrix.apply(minmax_normalize, axis=0)

# Cluster using cosine similarity
from sklearn.metrics.pairwise import cosine_similarity
from scipy.cluster.hierarchy import linkage, dendrogram

cosine_sim_cols = cosine_similarity(normalized_matrix.T)
cosine_sim_cols = np.nan_to_num(cosine_sim_cols, 0)
linkage_cols = linkage(1 - cosine_sim_cols, method='ward')

cosine_sim_rows = cosine_similarity(normalized_matrix)
cosine_sim_rows = np.nan_to_num(cosine_sim_rows, 0)
linkage_rows = linkage(1 - cosine_sim_rows, method='ward')

# Get order from dendrograms
dend_cols = dendrogram(linkage_cols, no_plot=True)
dend_rows = dendrogram(linkage_rows, no_plot=True)

# Reorder matrix
normalized_matrix = normalized_matrix.iloc[dend_rows['leaves'], dend_cols['leaves']]

# Create heatmap
fig = go.Figure(data=go.Heatmap(
    z=normalized_matrix.values,
    x=normalized_matrix.columns,
    y=normalized_matrix.index,
    colorscale='Viridis',
    colorbar=dict(title="Normalized Count")
))

fig.update_layout(
    width=800,
    height=800,
    xaxis_title="Post Cell Class",
    yaxis_title="Pre Cell Class"
)
fig.show()
```

#### Network Graph with NetworkX

```python
import matplotlib.pyplot as plt

# Calculate node positions
pos = nx.spring_layout(G, k=0.5, iterations=50, seed=42)
# Other layouts: nx.kamada_kawai_layout, nx.circular_layout, nx.shell_layout

# Calculate node sizes based on degree
node_sizes = [G.degree(node) * 100 for node in G.nodes()]

# Draw network
plt.figure(figsize=(12, 10))
nx.draw_networkx_nodes(
    G, pos,
    node_size=node_sizes,
    node_color=[node_attrs[n].get('super_class', 'unknown')
                for n in G.nodes()],
    alpha=0.7,
    cmap='tab20'
)

nx.draw_networkx_edges(
    G, pos,
    width=[d['count']/1000 for u, v, d in G.edges(data=True)],
    alpha=0.3,
    arrows=True,
    arrowsize=10
)

nx.draw_networkx_labels(G, pos, font_size=8)
plt.axis('off')
plt.tight_layout()
plt.show()
```

#### 3D Neuron Visualization (from utils.py)

```python
import navis
from utils import plot3d_split, split_neurons_by_compartment

# Read neurons with compartment labels (FAFB, MANC, maleCNS, Hemibrain)
# Note: BANC neurons don't have compartment labels yet
neurons = navis.read_swc('path/to/neurons.swc')

# Option 1: Automatic compartment visualization
# Splits neurons by Label column and colors by compartment
fig = plot3d_split(
    neurons,
    volumes=neuropil_volume,  # Optional neuropil mesh
    title='Neurons colored by compartment',
    width=1200,
    height=800
)
fig.show()

# Compartment colors:
# - Orange: axon
# - Cyan: dendrite
# - Green: primary dendrite (linker)
# - Purple: primary neurite (cell body fiber)

# Option 2: Manual compartment splitting
# Get separate NeuronLists for each compartment
compartments = split_neurons_by_compartment(neurons)

axons = compartments['axon']
dendrites = compartments['dendrite']
linkers = compartments['linker']
neurites = compartments['neurite']

# Plot specific compartments
fig = navis.plot3d(
    [dendrites, axons],
    color=['cyan', 'orange'],
    backend='plotly'
)
```

**Dataset compartment label availability:**
- ✅ FAFB (fafb_783): Has compartment labels
- ✅ MANC (manc_121): Has compartment labels
- ✅ maleCNS (malecns_09): Has compartment labels
- ✅ Hemibrain (hemibrain_121): Has compartment labels
- ❌ BANC (banc_888): No compartment labels yet

### Helper Functions

```python
import numpy as np

# Min-max normalization
def minmax_normalize(x):
    return (x - x.min()) / (x.max() - x.min())

# Z-score normalization
def zscore_normalize(x):
    return (x - x.mean()) / x.std()

# MAD (Median Absolute Deviation) normalization
def mad_normalize(x):
    median = np.median(x)
    mad = np.median(np.abs(x - median))
    return (x - median) / mad

# Symmetrize adjacency matrix
def symmetrize(A):
    A_sym = A + A.T
    A_sym.setdiag(0)
    return A_sym

# Convert edgelist to matrix
def edgelist_to_matrix(el, value_col='norm'):
    return el.pivot_table(
        index='pre',
        columns='post',
        values=value_col,
        aggfunc='sum',
        fill_value=0
    )

# Calculate cosine similarity safely
def safe_cosine_similarity(matrix):
    from sklearn.metrics.pairwise import cosine_similarity
    sim = cosine_similarity(matrix)
    return np.nan_to_num(sim, 0)
```

---

## Key Packages

**Core Analysis:**
- **navis**: Neuron analysis and visualization
- **pandas/numpy**: Data manipulation
- **pyarrow**: Reading Feather/Parquet files
- **gcsfs**: Google Cloud Storage file system access

**Network Analysis:**
- **networkx**: Graph creation, metrics, algorithms
- **python-louvain**: Community detection (Louvain)
- **leidenalg**: Community detection (Leiden)
- **igraph**: High-performance graph library

**Clustering & Dimensionality Reduction:**
- **scikit-learn**: Machine learning algorithms (clustering, PCA, etc.)
- **umap-learn**: UMAP dimensionality reduction
- **scipy**: Scientific computing (hierarchical clustering, sparse matrices)

**Visualization:**
- **plotly**: Interactive visualizations
- **matplotlib**: Static plots
- **seaborn**: Statistical data visualization

**3D & Morphology:**
- **trimesh**: 3D mesh processing
- **pykdtree**: Fast spatial queries
- **ncollpyde**: Collision detection for meshes

---

## Google Colab Setup

### For Students

**Quick Start (3 steps):**
1. Open notebook in Colab workspace
2. Connect to `sjcabs-connectomics-tutorial` runtime
3. Run all cells

The first cell auto-detects Colab and sets up everything automatically.

### For Instructors

#### Create Runtime Template

1. Go to [Vertex AI Colab](https://console.cloud.google.com/vertex-ai/colab/notebooks)
2. Click "Runtime Templates" → "Create Runtime Template"
3. Configure:
   - **Name**: `sjcabs-connectomics-tutorial`
   - **Machine**: `n1-standard-4` (4 vCPUs, 15 GB RAM)
   - **Disk**: 50 GB
   - **Python**: 3.10

4. **Enable post-startup script** and select the appropriate script from `runtimes/`:
   - For all tutorials: `fly_connectome_data_tutorial.sh` (master script)
   - Or tutorial-specific: `fly_connectome_0X_*_post_startup.sh`

#### Runtime Scripts

Each tutorial has a paired setup script in `runtimes/`:

- `fly_connectome_01_data_access_post_startup.sh`
- `fly_connectome_02_neuron_morphology_post_startup.sh`
- `fly_connectome_03_connectivity_analyses_post_startup.sh`
- `fly_connectome_04_indirect_connectivity_post_startup.sh`
- `fly_connectome_data_tutorial.sh` - Master script (installs all dependencies)

These scripts:
- Install all required Python packages
- Verify installations
- Configure the environment automatically

**Note**: Tutorial 04 requires git to install ConnectomeInfluenceCalculator from GitHub (pre-installed in Colab).

#### Grant Students GCS Access

```bash
# Add students to IAM role
gcloud projects add-iam-policy-binding sjcabs \
    --member="user:student@example.com" \
    --role="roles/storage.objectViewer"

# Or use a group
gcloud projects add-iam-policy-binding sjcabs \
    --member="group:sjcabs-students@example.com" \
    --role="roles/storage.objectViewer"
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Packages not installed | Check post-startup script, restart runtime |
| Authentication fails | Re-run first cell, check IAM roles |
| GCS 401/403 errors | Verify authentication, check bucket access |
| Slow data loading | Check network, verify bucket region matches runtime region |

### Performance

**Expected runtimes** (n1-standard-4):
- Tutorial 01: ~3-5 minutes
- Tutorial 02: ~10-15 minutes (NBLAST is compute-intensive)
- Tutorial 03: ~8-10 minutes
- Tutorial 04: ~5-8 minutes

**Cost estimate** (per student, 4-week workshop):
- ~8 hours total runtime = ~$1.50 per student
- Class of 20 students = ~$30 total

---

## Help & Support

- **Package docs**: https://navis.readthedocs.io/
- **GitHub issues**: https://github.com/sjcabs/fly_connectome_data_tutorial/issues
- **Workshop**: Contact instructors (Sven Dorkenwald, Alexander Bates)
