# Male CNS Dataset Documentation

## Overview

**Male CNS (Central Nervous System)** - Complete male CNS connectome spanning brain and ventral nerve cord with sexual dimorphism data.

**Publication:** Berg et al. (2025) bioRxiv | **Version:** v0.9
**Scale:** 165,114 neurons | ~312 million synapses | 11,691 cell types
**Location:** `gs://sjcabs_2025_data/malecns/`

## File Structure

```
malecns/
├── malecns_09_meta.feather                    # 12 MB - Neuron metadata
├── malecns_09_simple_edgelist.feather         # 1.5 GB - Neuron connectivity
└── malecns_09_split_edgelist.feather          # 2.2 GB - Compartment connectivity
```

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
**Size:** 1.5 GB
**Each row:** One neuron → neuron connection

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic neuron ID |
| `post` | Postsynaptic neuron ID |
| `count` | Number of synapses |
| `norm` | Normalized weight |
| `total_input` | Total inputs to target |

**Notes:**
- Total synapses: ~312 million (estimated)
- Largest connectome by synapse count

---

### `malecns_09_split_edgelist.feather`

**Content:** Compartment-to-compartment connectivity
**Size:** 2.2 GB
**Each row:** One compartment → compartment connection

#### Key Columns

| Column | Description |
|--------|-------------|
| `pre`, `post` | Neuron IDs |
| `pre_label`, `post_label` | Compartment labels (axon, dendrite, etc.) |
| `count` | Synapses connecting compartments |
| `norm` | Normalized weight |

**Notes:**
- Compartment labels from flow centrality algorithm
- Enables polarity analysis
- Available for maleCNS, FAFB, MANC (not BANC)

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

meta = pd.read_feather("gs://sjcabs_2025_data/malecns/malecns_09_meta.feather")
edgelist = pd.read_feather("gs://sjcabs_2025_data/malecns/malecns_09_simple_edgelist.feather")
split_edgelist = pd.read_feather("gs://sjcabs_2025_data/malecns/malecns_09_split_edgelist.feather")
```

**R:**
```r
library(arrow)

meta <- read_feather("gs://sjcabs_2025_data/malecns/malecns_09_meta.feather")
edgelist <- read_feather("gs://sjcabs_2025_data/malecns/malecns_09_simple_edgelist.feather")
split_edgelist <- read_feather("gs://sjcabs_2025_data/malecns/malecns_09_split_edgelist.feather")
```

---

## Key Features

**Unique Features:**
- **Sexual dimorphism:** Includes fruitless and doublesex expression data
- **Complete male CNS:** Brain + VNC (largest neuron count)
- **Cross-dataset matching:** Cell types matched to FAFB, Hemibrain, MANC
- **Comprehensive annotations:** 11,691 cell types

**Key Circuits:**
- Sex-specific circuits (courtship, mating)
- Complete sensory-motor pathways
- Brain-VNC integration
- Neuromodulatory systems

**Strengths:**
- Most neurons of any dataset (165K)
- Most synapses (312M)
- Sexual dimorphism data
- Cross-dataset cell type matching

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
