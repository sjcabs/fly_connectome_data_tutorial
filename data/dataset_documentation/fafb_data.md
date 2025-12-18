# FAFB Dataset Documentation

## Overview

**FAFB (Full Adult Fly Brain)** via FlyWire - Complete adult female fly brain connectome at synapse resolution.

**Publication:** Dorkenwald et al. (2024) Nature; Schlegel et al. (2024) Nature | **Version:** 783 (published)
**Scale:** 139,213 neurons | ~69 million synapses | ~15 million connections
**Location:** `gs://sjcabs_2025_data/fafb/`

## File Structure

```
fafb/
├── fafb_783_meta.feather                    # 8.8 MB - Neuron metadata
├── fafb_783_simple_edgelist.feather         # 289 MB - Neuron connectivity
├── fafb_783_split_edgelist.feather          # 523 MB - Compartment connectivity
├── fafb_783_synapses.feather                # 4.0 GB - Individual synapses
├── fafb_783_synapses.parquet                # 1.7 GB - Synapses (compressed)
├── fafb_banc_space_swc/                     # Skeletons in BANC space
├── fafb_fafb_space_swc/                     # Skeletons in native FAFB space
├── hemibrain_banc_space_swc/                # Hemibrain matches in BANC space
├── hemibrain_hemibrain_raw_space_swc/       # Hemibrain matches in native space
├── neuropils/                               # Neuropil mesh files
├── obj/                                     # Additional mesh objects
└── [Curated Subsets:]
    ├── antennal_lobe/                       # Olfactory circuits
    ├── central_complex/                     # Navigation circuits
    ├── mushroom_body/                       # Associative memory circuits
    ├── optic/                               # Visual processing circuits
    └── suboesophageal_zone/                 # Feeding and tactile circuits
```

---

## File Descriptions

### `fafb_783_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 139,213 rows × 17 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `fafb_783_id` | Root ID for neuron in FAFB version 783 (FlyWire published) |
| `region` | Brain region (central_brain, optic_lobe) |
| `side` | Laterality (left, right, midline) |
| `hemilineage` | Developmental hemilineage |
| `nerve` | Entry/exit nerve (if applicable) |
| `flow` | Information flow (intrinsic, afferent, efferent) |
| `super_class` | Coarse functional classification |
| `cell_class` | Intermediate classification |
| `cell_sub_class` | Fine classification |
| `cell_type` | Cell type name (8,453 annotated types) |
| `neurotransmitter_predicted` | Predicted transmitter |
| `neurotransmitter_score` | Confidence score (0-1) |
| `cell_function` | Functional category |
| `cell_function_detailed` | Detailed annotation |
| `body_part_sensory` | Sensory target |
| `body_part_effector` | Motor target |
| `status` | Quality flag |

**Notes:**
- Harmonized to BANC schema for cross-dataset comparisons
- Brain only (no VNC)
- Comprehensive cell type annotations from Schlegel et al. (2024)

---

### `fafb_783_simple_edgelist.feather`

**Content:** Neuron-to-neuron connectivity
**Dimensions:** 15,023,799 rows × 5 columns
**Each row:** One neuron → neuron connection

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron ID |
| `post` | Postsynaptic neuron ID |
| `count` | Number of synapses pre → post |
| `norm` | Normalized weight (`count / total_input`) |
| `total_input` | Total inputs to target |

---

### `fafb_783_split_edgelist.feather`

**Content:** Compartment-to-compartment connectivity
**Dimensions:** 15,867,088 rows × 7 columns
**Each row:** One compartment → compartment connection

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron ID |
| `pre_label` | Presynaptic compartment (axon, dendrite, soma, primary_dendrite, primary_neurite, unknown) |
| `post` | Postsynaptic neuron ID |
| `post_label` | Postsynaptic compartment |
| `count` | Synapses connecting compartments |
| `norm` | Normalized by total neuron input |
| `compartment_input` | Total inputs to target compartment |

**Notes:**
- Compartment labels from flow centrality (Schneider-Mizell et al. 2016)
- Enables polarity analysis (axon → dendrite, etc.)
- Available for FAFB, MANC, maleCNS (not BANC)

---

### `fafb_783_synapses.*`

**Content:** Individual synapse locations
**Formats:** Feather (4.0 GB) | Parquet (1.7 GB, recommended)
**Each row:** One synaptic connection

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron IDs |
| `x`, `y`, `z` | Coordinates in FAFB space (nm) |
| `prepost` | Link type (0=pre, 1=post) |
| `syn_top_nt` | Predicted transmitter |
| `syn_top_nt_p` | Confidence score |
| `cleft_scores` | Cleft detectability |
| `connector_id` | Presynapse identifier |
| `neuropil` | Neuropil region(s) |
| `label` | Compartment annotation |

**Notes:**
- Use Parquet for faster loading
- Coordinates in native FAFB space

---

### Skeleton Directories

| Directory | Space | Description |
|-----------|-------|-------------|
| `fafb_banc_space_swc/` | BANC | FAFB neurons in BANC space (cross-dataset comparisons) |
| `fafb_fafb_space_swc/` | FAFB | Native space (highest resolution) |
| `hemibrain_banc_space_swc/` | BANC | Hemibrain-matched neurons |
| `hemibrain_hemibrain_raw_space_swc/` | Hemibrain | Hemibrain-matched (native) |

**Format:** One `.swc` file per neuron

---

## Curated Subsets

| Subset | Focus | Circuits |
|--------|-------|----------|
| **antennal_lobe** | Olfaction | ORNs, PNs, local neurons |
| **central_complex** | Navigation | Ring, columnar neurons |
| **mushroom_body** | Memory | Kenyon cells, MBONs, DANs |
| **optic** | Vision | Lobula, medulla, motion |
| **suboesophageal_zone** | Feeding/tactile | Gustatory, motor |

---

## Data Provenance

- **Source:** FAFB FlyWire v783
- **Processing:** Harmonized to BANC schema
- **Citations:**
  - Dorkenwald et al. (2024) "Neuronal wiring diagram" *Nature*
  - Schlegel et al. (2024) "Whole-brain annotation" *Nature*

---

## Loading Examples

**Python:**
```python
import pandas as pd

meta = pd.read_feather("gs://sjcabs_2025_data/fafb/fafb_783_meta.feather")
edgelist = pd.read_feather("gs://sjcabs_2025_data/fafb/fafb_783_simple_edgelist.feather")
split_edgelist = pd.read_feather("gs://sjcabs_2025_data/fafb/fafb_783_split_edgelist.feather")
synapses = pd.read_parquet("gs://sjcabs_2025_data/fafb/fafb_783_synapses.parquet")
```

**R:**
```r
library(arrow)

meta <- read_feather("gs://sjcabs_2025_data/fafb/fafb_783_meta.feather")
edgelist <- read_feather("gs://sjcabs_2025_data/fafb/fafb_783_simple_edgelist.feather")
split_edgelist <- read_feather("gs://sjcabs_2025_data/fafb/fafb_783_split_edgelist.feather")
synapses <- read_parquet("gs://sjcabs_2025_data/fafb/fafb_783_synapses.parquet")
```

---

## Cross-Dataset Notes

**FAFB vs BANC:**
- FAFB: Brain only (139K neurons)
- BANC: Brain + VNC (169K neurons)
- ~139K brain neurons matched between datasets
- Use BANC-space skeletons for spatial comparisons

**FAFB vs Hemibrain:**
- FAFB: Complete brain
- Hemibrain: ~Half central brain (~25K neurons)
- Matched neurons in `hemibrain_*` directories
