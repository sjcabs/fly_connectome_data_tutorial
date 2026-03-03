# MANC Dataset Documentation

## Overview

**MANC (Male Adult Nerve Cord)** - First complete ventral nerve cord connectome at synapse resolution.

**Publications:** Takemura et al. (2024) eLife; Marin et al. (2024) eLife; Cheong et al. (2024) eLife | **Version:** v1.2.1
**Scale:** 23,650 neurons | ~31 million synapses | ~5.3 million connections
**Location:** `gs://brain-and-nerve-cord_exports/processed_data/manc/`

## File Structure

```
manc/
├── manc_121_meta.feather                    # 1.4 MB - Neuron metadata
├── manc_121_simple_edgelist.feather         # 83 MB - Neuron connectivity
├── manc_121_split_edgelist.feather          # 321 MB - Compartment connectivity
├── manc_121_synapses.feather                # 3.6 GB - Individual synapses
├── manc_banc_space_split_swc/               # Skeletons in BANC space (split by compartment)
├── manc_manc_space_swc/                     # Skeletons in native MANC space
└── obj/                                     # Mesh objects
```

---

## File Descriptions

### `manc_121_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 23,650 rows × 15 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `manc_121_id` | Body ID for neuron in MANC v1.2.1 |
| `region` | VNC region (e.g., T1, T2, T3, A1-A8 neuromeres) |
| `side` | Laterality (left, right, midline) |
| `hemilineage` | Developmental hemilineage |
| `nerve` | Entry/exit nerve |
| `flow` | Information flow (intrinsic, afferent, efferent) |
| `super_class` | Coarse classification |
| `cell_class` | Intermediate classification |
| `cell_sub_class` | Fine classification |
| `cell_type` | Cell type name |
| `neurotransmitter_predicted` | Predicted transmitter |
| `cell_function` | Functional category |
| `cell_function_detailed` | Detailed annotation |
| `body_part_sensory` | Sensory target |
| `body_part_effector` | Motor target (leg, wing, etc.) |

**Notes:**
- Harmonized to BANC schema
- VNC only (no brain)
- Focus on descending commands → motor output transformation

---

### `manc_121_simple_edgelist.feather`

**Content:** Neuron-to-neuron connectivity
**Dimensions:** 5,305,354 rows × 5 columns
**Each row:** One neuron → neuron connection

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron body ID |
| `post` | Postsynaptic neuron body ID |
| `count` | Number of synapses |
| `norm` | Normalized weight |
| `total_input` | Total inputs to target |

**Notes:**
- Total synapses: ~31 million

---

### `manc_121_split_edgelist.feather`

**Content:** Compartment-to-compartment connectivity
**Dimensions:** 6,761,806 rows × 14 columns
**Each row:** One compartment → compartment connection

#### Key Columns

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron IDs |
| `pre_label`, `post_label` | Compartment labels |
| `count` | Synapses connecting compartments |
| `norm` | Normalized by total neuron input |
| `post_label_count` | Inputs to target compartment |
| `pre_top_nt`, `post_top_nt` | Predicted transmitters |
| `pre_top_nt_p`, `post_top_nt_p` | Confidence scores |
| `connection` | Connection type descriptor |

**Notes:**
- Includes transmitter predictions for both pre and post neurons
- Compartment labels from flow centrality algorithm
- Enables polarity analysis (axon → dendrite, etc.)

---

### `manc_121_synapses.feather`

**Content:** Individual synapse locations and properties
**Size:** 3.6 GB
**Each row:** One synaptic connection

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron body IDs |
| `x`, `y`, `z` | Coordinates in MANC space (nm) |
| `prepost` | Link type (0=pre, 1=post) |
| `cleft_scores` | Cleft detectability |
| `connector_id` | Presynapse identifier |
| `neuropil` | Neuropil region |
| `label` | Compartment annotation |
| `strahler_order` | Branch order |

**Notes:**
- Coordinates in native MANC space
- No synapse-level transmitter predictions (unlike BANC/FAFB)

---

### Skeleton Directories

| Directory | Space | Description |
|-----------|-------|-------------|
| `manc_banc_space_split_swc/` | BANC | MANC neurons in BANC space (split by compartment) |
| `manc_manc_space_swc/` | MANC | Native MANC space |

**Format:** One `.swc` file per neuron or compartment

---

## Data Provenance

- **Source:** MANC neuPrint v1.2.1
- **Imaging:** Male adult VNC EM dataset
- **Processing:** Harmonized to BANC schema
- **Citations:**
  - Takemura et al. (2024) "A Connectome of the Male Drosophila Ventral Nerve Cord" *eLife*
  - Marin et al. (2024) "Systematic annotation of a complete adult male Drosophila nerve cord connectome" *eLife*
  - Cheong et al. (2024) "Transforming descending input into behavior" *eLife*

---

## Loading Examples

**Python:**
```python
import pandas as pd

meta = pd.read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_meta.feather")
edgelist = pd.read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_simple_edgelist.feather")
split_edgelist = pd.read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_split_edgelist.feather")
synapses = pd.read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_synapses.feather")
```

**R:**
```r
library(arrow)

meta <- read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_meta.feather")
edgelist <- read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_simple_edgelist.feather")
split_edgelist <- read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_split_edgelist.feather")
synapses <- read_feather("gs://brain-and-nerve-cord_exports/processed_data/manc/manc_121_synapses.feather")
```

---

## Key Features

**Focus:** Descending command signals → motor output transformation

**Key Circuits:**
- Leg motor circuits (walking, grooming)
- Wing motor circuits (flight)
- Abdominal circuits (egg-laying, mating)
- Sensory feedback integration

**Unique Features:**
- Complete VNC (no brain)
- Detailed motor neuron annotations
- Compartment-level connectivity with transmitter predictions
- Transformation from command to action

---

## Cross-Dataset Notes

**MANC vs BANC:**
- MANC: VNC only (23K neurons)
- BANC: Brain + VNC (169K neurons, including ~23K VNC neurons)
- VNC neurons matched between datasets
- Use BANC-space skeletons for spatial comparisons

**Complementary Datasets:**
- **BANC:** Full CNS context (brain → VNC → behavior)
- **FAFB:** Brain circuits that send descending commands
