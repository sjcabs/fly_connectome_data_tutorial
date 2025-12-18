# BANC Dataset Documentation

## Overview

**BANC (Brain and Nerve Cord)** - First complete synapse-resolution connectome spanning both brain and ventral nerve cord.

**Publication:** Bates et al. (2025) *bioRxiv* | **Version:** 746 (published)
**Scale:** 168,791 neurons | ~155 million synapses | ~114 million connections
**Location:** `gs://sjcabs_2025_data/banc/`

## File Structure

```
banc/
├── banc_746_meta.feather                    # 9.8 MB - Neuron metadata
├── banc_746_simple_edgelist.feather         # 3.4 GB - Neuron connectivity
├── banc_746_synapses.parquet                # 8.7 GB - Individual synapses
├── banc_banc_space_l2_swc/                  # 3D neuron skeletons
├── neuropils/                               # Neuropil mesh files
├── obj/                                     # Additional mesh objects
└── [Curated Subsets:]
    ├── abdominal_neuromere/                 # Abdominal control circuits
    ├── antennal_lobe/                       # Olfactory circuits
    ├── central_complex/                     # Navigation circuits
    ├── front_leg/                           # Front leg motor control
    ├── mushroom_body/                       # Associative memory circuits
    ├── optic/                               # Visual processing circuits
    └── suboesophageal_zone/                 # Feeding and tactile circuits
```

---

## File Descriptions

### `banc_746_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 168,791 rows × 18 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `banc_746_id` | Root ID for the neuron in BANC version 746 (published) |
| `supervoxel_id` | Original supervoxel identifier |
| `region` | CNS region (central_brain, optic_lobe, ventral_nerve_cord, neck_connective) |
| `side` | Laterality (left, right, midline) |
| `hemilineage` | Developmental hemilineage (e.g., 00A, 01B, VPNp1_medial) |
| `nerve` | Entry/exit nerve (if applicable) |
| `flow` | Information flow direction (intrinsic, afferent, efferent) |
| `super_class` | Coarse functional classification (13 types) |
| `cell_class` | Intermediate classification (115 types) |
| `cell_sub_class` | Fine classification (hierarchical) |
| `cell_type` | Cell type name (11,136 types) |
| `neurotransmitter_predicted` | Predicted transmitter (acetylcholine, gaba, glutamate, etc.) |
| `neurotransmitter_score` | Confidence score for transmitter prediction (0-1) |
| `cell_function` | Functional category (e.g., olfactory, motor, visual) |
| `cell_function_detailed` | Detailed functional annotation |
| `body_part_sensory` | Sensory target (if sensory neuron) |
| `body_part_effector` | Motor target (if motor neuron) |
| `status` | Quality flag (empty = good, TRACING_ISSUE_* = potential issue) |

**Notes:**
- Metadata based on harmonized BANC/FAFB/MANC cell type matching
- Neurotransmitter predictions from Eckstein et al. (2024) Cell

---

### `banc_746_simple_edgelist.feather`

**Content:** Neuron-to-neuron connectivity matrix
**Dimensions:** 113,981,973 rows × 5 columns
**Each row:** One neuron → neuron connection

#### Columns

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic (source) neuron ID |
| `post` | Postsynaptic (target) neuron ID |
| `count` | Number of synapses connecting pre → post |
| `norm` | Normalized weight: `count / total_input` |
| `total_input` | Total input synapses to target neuron |

**Notes:**
- Only includes synapses with `cleft_score > 50` (high confidence)
- Total synapses across all connections: ~155 million
- Self-connections (autapses) included

**Example:**
```
pre                post               count  norm      total_input
720575941509220642 720575941277394247 1      1.0       1
720575941526837604 720575940420901192 1      1.0       1
720575941508750721 720575941576493706 1      0.5       2
```

---

### `banc_746_synapses.parquet`

**Content:** Individual synapse locations and properties
**Format:** Parquet (columnar, for large data)
**Size:** 8.7 GB
**Each row:** One synaptic connection (pre→post)

#### Key Columns

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron ID |
| `post` | Postsynaptic neuron ID |
| `x`, `y`, `z` | Synapse coordinates in BANC space (nm) |
| `prepost` | Link type (0 = presynapse, 1 = postsynapse) |
| `syn_top_nt` | Predicted neurotransmitter at this synapse |
| `syn_top_nt_p` | Confidence score for transmitter |
| `acetylcholine`, `gaba`, `glutamate`, `dopamine`, `serotonin`, `octopamine` | Individual transmitter scores |
| `cleft_scores` | Synaptic cleft detectability score |
| `size` | Synapse size (voxels) |
| `connector_id` | Unique presynapse identifier (multiple posts can share one connector) |
| `neuropil` | Neuropil region(s) containing synapse |
| `label` | Compartment annotation (axon, dendrite, soma, unknown) |
| `strahler_order` | Branch order in skeleton |
| `status` | Quality flag |

**Notes:**
- Synapse-level transmitter predictions from Eckstein et al. (2024)
- Filtered to `cleft_score > 50` for published dataset
- Coordinates in BANC space (covers brain and VNC)

---

### `banc_banc_space_l2_swc/`

**Content:** 3D neuron skeletons in SWC format
**Format:** One `.swc` file per neuron (named by `banc_746_id`)
**Coordinate space:** BANC space (nm)

#### SWC File Format

Each `.swc` file contains point cloud representation of neuron morphology:

| Column | Description |
|--------|-------------|
| `PointNo` | Unique point identifier (positive integer) |
| `Label` | Point type: -1 (root), 0 (undefined), 1 (soma), 2 (axon), 3 (dendrite), 7 (primary dendrite), 9 (primary neurite) |
| `X`, `Y`, `Z` | 3D coordinates in BANC space (nm) |
| `R` | Radius (nm) - half the cylinder thickness |
| `Parent` | Parent point ID (-1 for root, defines tree structure) |

**Notes:**
- Level 2 (L2) skeletons: Simplified from full resolution for computational efficiency
- BANC space encompasses both brain and VNC (unlike FAFB or MANC spaces)

---

## Curated Subsets

Each subset directory contains filtered metadata, edgelists, and synapse data for specific circuits:

| Subset | Focus | Key Circuits |
|--------|-------|--------------|
| **abdominal_neuromere** | Abdominal control | Motor neurons, sensory neurons, premotor circuits |
| **antennal_lobe** | Olfaction | ORNs, PNs, local neurons |
| **central_complex** | Navigation | Ring neurons, columnar neurons, heading circuits |
| **front_leg** | Leg control | Motor neurons, sensory feedback, CPGs |
| **mushroom_body** | Memory | Kenyon cells, MBONs, DANs |
| **optic** | Vision | Lobula, medulla, wide-field neurons |
| **suboesophageal_zone** | Feeding/tactile | Gustatory, mechanosensory, motor circuits |

**Usage:** Ideal for focused analyses without loading the full connectome.

---

## Data Provenance

- **Source:** BANC FlyWire project (version 746)
- **Processing:** Harmonized to unified metadata schema (see `data/meta_data_entries.csv`)
- **Quality:** Synapses filtered by `cleft_score > 50`
- **Citation:** Bates et al. (2025) "Distributed control circuits across a brain-and-cord connectome" *bioRxiv*

---

## Loading Examples

**Python:**
```python
import pandas as pd

meta = pd.read_feather("gs://sjcabs_2025_data/banc/banc_746_meta.feather")
edgelist = pd.read_feather("gs://sjcabs_2025_data/banc/banc_746_simple_edgelist.feather")
synapses = pd.read_parquet("gs://sjcabs_2025_data/banc/banc_746_synapses.parquet")
```

**R:**
```r
library(arrow)

meta <- read_feather("gs://sjcabs_2025_data/banc/banc_746_meta.feather")
edgelist <- read_feather("gs://sjcabs_2025_data/banc/banc_746_simple_edgelist.feather")
synapses <- read_parquet("gs://sjcabs_2025_data/banc/banc_746_synapses.parquet")
```
