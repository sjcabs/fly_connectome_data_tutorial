# Male CNS Dataset Documentation

## Overview

**Male CNS (Central Nervous System)** - Complete male CNS connectome spanning brain and ventral nerve cord with sexual dimorphism data.

**Publication:** Berg et al. (2025) bioRxiv | **Version:** v0.9
**Scale:** 165,114 neurons | ~301 million synapses | 11,691 cell types
**Location:** `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/malecns_09/`

## File Structure

```
compiled_data/malecns_09/
├── malecns_09_meta.feather                    # ~9.7 MB - Neuron metadata
├── malecns_09_simple_edgelist.feather         # ~3.2 GB - Neuron connectivity
├── malecns_09_split_edgelist.feather          # ~4.6 GB - Compartment connectivity
├── malecns_09_synapses.parquet                # ~7.9 GB - Individual synapses
├── malecns_malecns_space_swc/                 # Skeletons in native maleCNS space
├── malecns_banc_space_swc/                    # Skeletons in BANC space
├── obj/                                       # maleCNS volume + neuropil OBJ meshes
│   └── neuropils/
└── JRC2018U/                                  # JRC2018-Unisex registration assets
```

> **Note on subsets.** Pre-computed cut-out folders (including `optic_lobe_hex_*`) no
> longer exist — build them in code via `subset_by_region()`.

---

## File Descriptions

### `malecns_09_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 165,114 rows × 22 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `malecns_09_id` | Neuron ID in maleCNS v0.9 |
| `region` | CNS region (central_brain, optic_lobe, ventral_nerve_cord, neck_connective) |
| `side` | Laterality (left, right, midline) |
| `hemilineage` | Developmental hemilineage |
| `nerve` | Entry/exit nerve |
| `flow` | Information flow (intrinsic, afferent, efferent) |
| `super_class` | Coarse classification |
| `cell_class` | Intermediate classification |
| `cell_sub_class` | Fine classification |
| `cell_type` | Cell type name (11,691 types) |
| `fafb_cell_type` | Matched FAFB cell type |
| `hemibrain_cell_type` | Matched Hemibrain cell type |
| `manc_cell_type` | Matched MANC cell type |
| `neurotransmitter_predicted` | Predicted transmitter |
| `neurotransmitter_score` | Confidence score |
| `cell_function` | Functional category |
| `cell_function_detailed` | Detailed annotation |
| `body_part_sensory` | Sensory target |
| `body_part_effector` | Motor target |
| `dimorphism` | Sexual dimorphism annotation |
| `optic_lobe_hex` | Optic lobe hexagonal grid position |
| `status` | Quality flag |

**Notes:**
- Harmonized to BANC schema
- Complete male CNS (brain + VNC)
- Includes fruitless and doublesex expression data
- Cross-referenced with FAFB, Hemibrain, MANC cell types
- Missing retina

---

### `malecns_09_simple_edgelist.feather`

**Content:** Neuron-to-neuron connectivity
**Dimensions:** 142,881,142 rows × 5 columns
**Each row:** One neuron → neuron connection

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron ID |
| `post` | Postsynaptic neuron ID |
| `count` | Number of synapses |
| `norm` | Normalized weight |
| `total_input` | Total inputs to target |

**Notes:**
- Total synapses: 301,131,971 (~301 million)
- Largest connectome by synapse count

---

### `malecns_09_split_edgelist.feather`

**Content:** Compartment-to-compartment connectivity
**Dimensions:** 145,879,828 rows × 7 columns
**Each row:** One compartment → compartment connection

#### Key Columns

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron IDs |
| `pre_label`, `post_label` | Compartment labels (axon, dendrite, etc.) |
| `count` | Synapses connecting compartments |
| `norm` | Normalized weight |
| `compartment_input` | Total inputs to target compartment |

**Notes:**
- Compartment labels from flow centrality algorithm
- Enables polarity analysis
- Available for maleCNS, FAFB, MANC (not BANC)

---

### `malecns_09_synapses.parquet`

**Content:** Individual synapse locations and properties
**Format:** Parquet (columnar, for large data)
**Size:** 7.0 GB
**Dimensions:** 301,131,971 rows × 22 columns
**Each row:** One synaptic connection

#### Key Columns

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron IDs |
| `x`, `y`, `z` | Synapse coordinates in maleCNS space (nm) |
| `prepost` | Link type (0 = presynapse, 1 = postsynapse) |
| `syn_top_nt` | Predicted neurotransmitter at this synapse |
| `syn_top_p` | Confidence score for transmitter |
| `acetylcholine`, `gaba`, `glutamate`, `dopamine`, `serotonin`, `octopamine`, `histamine` | Individual transmitter scores |
| `confidence` | Synapse confidence score |
| `neuropil` | Neuropil region containing synapse |
| `pre_label`, `post_label` | Compartment annotations |
| `side` | Laterality (left, right, midline) |
| `id` | Unique synapse identifier |
| `region` | CNS region |

**Notes:**
- Synapse-level transmitter predictions available
- Coordinates in native maleCNS space
- Use Parquet format for efficient loading

---

### Skeleton Directories

| Directory | Space | Description |
|-----------|-------|-------------|
| `malecns_banc_space_swc/` | BANC | maleCNS neurons in BANC space (cross-dataset comparisons) |
| `malecns_malecns_space_swc/` | maleCNS | Native maleCNS space (highest resolution) |

**Format:** One `.swc` file per neuron

---

## Region Subsets (build in code)

| Subset | Filter |
|--------|--------|
| **abdominal_neuromere** | `neuropil` matches `^ANm\|^ABDNM\|^ADNM`, ≥100 synapses |
| **antennal_lobe** | Regex `antennal_lobe\|olfactory_receptor\|thermosensory_receptor\|hygrosensory_receptor\|CSD` against metadata |
| **central_complex** | Regex `central_complex` against metadata |
| **front_leg** | `neuropil` matches `^LegNp\(T1\)\|T1\|^ProNM-T1\|^LNp_T1`, `side == "right"`, ≥100 synapses |
| **mushroom_body** | Regex `mushroom_body\|kenyon_cell\|APL\|DPM\|LHMB1\|OA-VPM3` + KC partners ≥100 syn, `side == "right"` |
| **optic** | `neuropil` matches `^LO\|^LOP\|^AME\|^ME`, `side == "right"`, ≥100 synapses |
| **optic_lobe_hex_08** | `optic_lobe_hex_1 == "8" & optic_lobe_hex_2 == "8"` + downstream partners (count > 5) |
| **suboesophageal_zone** | `neuropil` matches `^FLA\|^SEZ\|^GNG\|^SAD\|^AMMC\|^PRW`, ≥100 synapses |

Reproduced in code via `subset_by_region()`. The synapse-based filters use Parquet
predicate pushdown so only matching rows are downloaded.

---

## Data Provenance

- **Source:** Male CNS FlyWire v0.9
- **Imaging:** Complete male CNS EM dataset
- **Processing:** Harmonized to BANC schema
- **Citation:** Berg et al. (2025) "Sexual dimorphism in the complete connectome of the Drosophila male central nervous system" *bioRxiv*

---

## Loading Examples

**Python:**
```python
import pandas as pd

base = "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/malecns_09"
meta           = pd.read_feather(f"{base}/malecns_09_meta.feather")
edgelist       = pd.read_feather(f"{base}/malecns_09_simple_edgelist.feather")
split_edgelist = pd.read_feather(f"{base}/malecns_09_split_edgelist.feather")
synapses       = pd.read_parquet(f"{base}/malecns_09_synapses.parquet")
```

**R:**
```r
library(arrow)

base <- "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/malecns_09"
meta           <- read_feather(file.path(base, "malecns_09_meta.feather"))
edgelist       <- read_feather(file.path(base, "malecns_09_simple_edgelist.feather"))
split_edgelist <- read_feather(file.path(base, "malecns_09_split_edgelist.feather"))
synapses       <- read_parquet(file.path(base, "malecns_09_synapses.parquet"))
```

---

## Key Features

**Unique Features:**
- **Sexual dimorphism:** Includes fruitless and doublesex expression data
- **Complete male CNS:** Brain + VNC (largest neuron count)
- **Cross-dataset matching:** Cell types matched to FAFB, Hemibrain, MANC
- **Comprehensive annotations:** 11,691 cell types
- **Optic lobe organization:** Hexagonal grid position annotations

**Key Circuits:**
- Sex-specific circuits (courtship, mating)
- Complete sensory-motor pathways
- Brain-VNC integration
- Neuromodulatory systems
- Visual processing circuits

**Strengths:**
- Most neurons of any dataset (165K)
- Most synapses (301M)
- Sexual dimorphism data
- Cross-dataset cell type matching
- Synapse-level transmitter predictions

**Limitations:**
- Missing retina (like BANC)
- Version 0.9 (pre-publication, may have updates)

---

## Cross-Dataset Notes

**maleCNS vs BANC:**
- maleCNS: Male CNS (165K neurons)
- BANC: Female CNS (169K neurons)
- Similar coverage (brain + VNC)
- Enables sex difference comparisons

**maleCNS vs FAFB:**
- maleCNS: Complete male CNS
- FAFB: Complete female brain only
- ~139K brain neurons can be compared
- Sexual dimorphism analysis possible

**Usage Recommendations:**
- **Use maleCNS for:** Sexual dimorphism, male-specific circuits
- **Use BANC for:** Female CNS, published version
- **Compare both for:** Sex differences in circuit structure
