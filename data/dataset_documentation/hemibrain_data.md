# Hemibrain Dataset Documentation

## Overview

**Hemibrain** - Dense reconstruction of approximately half the central brain with focus on memory and navigation circuits.

**Publication:** Scheffer et al. (2020) eLife | **Version:** v1.2.1
**Scale:** 25,397 neurons | ~27 million synapses | ~4.7 million connections
**Location:** `gs://sjcabs_2025_data/hemibrain/`

## File Structure

```
hemibrain/
├── hemibrain_121_meta.feather                    # 1.9 MB - Neuron metadata
├── hemibrain_121_simple_edgelist.feather         # 88 MB - Neuron connectivity
├── hemibrain_121_split_edgelist.feather          # 145 MB - Compartment connectivity
├── hemibrain_121_synapses.feather                # 13 KB - Synapse summary
├── hemibrain_banc_space_swc/                     # Skeletons in BANC space
├── hemibrain_hemibrain_raw_space_swc/            # Skeletons in native Hemibrain space
├── neuropils/                                    # Neuropil mesh files
├── obj/                                          # Mesh objects
└── [Curated Subsets:]
    ├── antennal_lobe/                            # Olfactory circuits
    ├── central_complex/                          # Navigation circuits
    └── mushroom_body/                            # Associative memory circuits
```

---

## File Descriptions

### `hemibrain_121_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 25,397 rows × 19 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `hemibrain_121_id` | Body ID for neuron in Hemibrain v1.2.1 |
| `instance` | Unique instance name (original Hemibrain identifier) |
| `cell_type` | Cell type name |
| `region` | Brain region |
| `hemilineage` | Developmental hemilineage |
| `nerve` | Entry/exit nerve |
| `flow` | Information flow (intrinsic, afferent, efferent) |
| `super_class` | Coarse classification |
| `cell_class` | Intermediate classification |
| `cell_sub_class` | Fine classification |
| `neurotransmitter_predicted` | Predicted transmitter |
| `neurotransmitter_score` | Confidence score |
| `cell_function` | Functional category |
| `cell_function_detailed` | Detailed annotation |
| `body_part_sensory` | Sensory target |
| `body_part_effector` | Motor target |
| `status` | Quality flag |
| `cropped` | Whether neuron extends beyond volume boundary |
| `root` | Original Hemibrain root ID |

**Notes:**
- Harmonized to BANC schema
- ~Half central brain (right hemisphere emphasis)
- Focus on mushroom body and central complex
- Some neurons cropped at volume boundary

---

### `hemibrain_121_simple_edgelist.feather`

**Content:** Neuron-to-neuron connectivity
**Dimensions:** 4,679,482 rows × 4 columns
**Each row:** One neuron → neuron connection

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron body ID |
| `post` | Postsynaptic neuron body ID |
| `count` | Number of synapses |
| `norm` | Normalized weight |

**Notes:**
- Total synapses: ~27 million
- No `total_input` column (different from other datasets)

---

### `hemibrain_121_split_edgelist.feather`

**Content:** Compartment-to-compartment connectivity
**Dimensions:** ~6.7M rows (estimated)
**Each row:** One compartment → compartment connection

#### Key Columns

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron IDs |
| `pre_label`, `post_label` | Compartment labels |
| `count` | Synapses connecting compartments |
| `norm` | Normalized weight |

**Notes:**
- Compartment labels available for polarity analysis

---

### `hemibrain_121_synapses.feather`

**Content:** Synapse summary file
**Size:** 13 KB (summary only, not full synapse table)

**Note:** This is a summary/metadata file. For detailed synapse locations, use neuPrint queries or the original Hemibrain dataset.

---

### Skeleton Directories

| Directory | Space | Description |
|-----------|-------|-------------|
| `hemibrain_banc_space_swc/` | BANC | Hemibrain neurons in BANC space (cross-dataset comparisons) |
| `hemibrain_hemibrain_raw_space_swc/` | Hemibrain | Native Hemibrain space |

**Format:** One `.swc` file per neuron

---

## Curated Subsets

| Subset | Focus | Key Circuits |
|--------|-------|--------------|
| **antennal_lobe** | Olfaction | ORNs, PNs, local neurons |
| **central_complex** | Navigation | Complete central complex circuits |
| **mushroom_body** | Memory | Complete mushroom body learning circuits |

**Note:** Hemibrain provides the most complete view of mushroom body and central complex circuits (more complete than partial coverage in other datasets).

---

## Data Provenance

- **Source:** Hemibrain neuPrint v1.2.1
- **Imaging:** Female adult central brain EM dataset (~right hemisphere)
- **Processing:** Harmonized to BANC schema
- **Citation:** Scheffer et al. (2020) "A connectome and analysis of the adult Drosophila central brain" *eLife*

---

## Loading Examples

**Python:**
```python
import pandas as pd

meta = pd.read_feather("gs://sjcabs_2025_data/hemibrain/hemibrain_121_meta.feather")
edgelist = pd.read_feather("gs://sjcabs_2025_data/hemibrain/hemibrain_121_simple_edgelist.feather")
split_edgelist = pd.read_feather("gs://sjcabs_2025_data/hemibrain/hemibrain_121_split_edgelist.feather")
```

**R:**
```r
library(arrow)

meta <- read_feather("gs://sjcabs_2025_data/hemibrain/hemibrain_121_meta.feather")
edgelist <- read_feather("gs://sjcabs_2025_data/hemibrain/hemibrain_121_simple_edgelist.feather")
split_edgelist <- read_feather("gs://sjcabs_2025_data/hemibrain/hemibrain_121_split_edgelist.feather")
```

---

## Key Features

**Historical Significance:**
- First large-scale adult fly brain connectome (2020)
- Established standards for connectome analysis
- Pioneered cell type classification approaches

**Key Circuits:**
- **Mushroom Body:** Complete learning and memory circuit
- **Central Complex:** Complete navigation and motor control circuit
- **Visual pathways:** Connections from optic lobes to central brain

**Strengths:**
- High annotation quality
- Well-studied circuits (extensive follow-up papers)
- Complete mushroom body and central complex

**Limitations:**
- ~Half central brain (many neurons cropped at boundary)
- No VNC
- No optic lobes (only descending connections from visual system)

---

## Cross-Dataset Notes

**Hemibrain vs FAFB:**
- Hemibrain: ~25K neurons (~half central brain)
- FAFB: 139K neurons (complete brain)
- Many Hemibrain neurons matched to FAFB (in `fafb/hemibrain_*` directories)

**Hemibrain vs BANC:**
- Hemibrain: Central brain only
- BANC: Brain + VNC
- Overlapping brain regions can be compared

**Usage Recommendations:**
- **Use Hemibrain for:** Mushroom body, central complex (most complete)
- **Use FAFB for:** Complete brain circuits
- **Use BANC for:** Brain-VNC integration
