# FAFB Dataset Documentation

## Overview

**FAFB (Full Adult Fly Brain)** via FlyWire - Complete adult female fly brain connectome at synapse resolution.

**Publication:** Dorkenwald et al. (2024) Nature; Schlegel et al. (2024) Nature | **Version:** 783 (published)
**Scale:** ~140,000 neurons | ~69 million synapses | ~15 million connections
**Location:** `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/fafb_783/`

## File Structure

```
compiled_data/fafb_783/
├── fafb_783_meta.feather                    # ~10 MB  - Neuron metadata (140,177 rows × 21 cols)
├── fafb_783_simple_edgelist.feather         # ~289 MB - Neuron connectivity
├── fafb_783_split_edgelist.feather          # ~523 MB - Compartment connectivity
├── fafb_783_synapses.feather                # ~4.0 GB - Individual synapses (Feather)
├── fafb_783_synapses.parquet                # ~1.7 GB - Same synapses as Parquet (preferred)
├── fafb_783_cell_dcv_detection.feather      # ~9.7 GB - Cellular DCV detections
├── fafb_783_soma_dcv_detection.feather      # ~3.7 GB - Somatic DCV detections
├── fafb_dcv_scores_metadata_ya_3_5_26.csv   # ~15 MB  - DCV detection metadata
├── fafb_fafb_space_swc/                     # Skeletons in native FAFB space
├── fafb_banc_space_swc/                     # Skeletons in BANC space
└── obj/                                     # FAFB volume + per-neuropil OBJ meshes
    └── neuropils/
```

> **Note on subsets.** The previous release shipped per-region cut-out folders inside this
> dataset directory. They no longer exist — build them in code via `subset_by_region()`,
> mirroring the original logic from
> [`bancpipeline/banc/share/banc-sjcabs.R`](https://github.com/flyconnectome/bancpipeline).

---

## File Descriptions

### `fafb_783_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 140,177 rows × 21 columns
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
| `sexually_dimorphic` | Sexual dimorphism annotation |
| `soma_dcv_density` | Per-neuron somatic DCV density (from `fafb_783_soma_dcv_detection.feather`) |
| `cell_dcv_density_um`, `cell_dcv_density_um3` | Per-neuron whole-cell DCV densities (per cable µm and per µm³) |

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

### `fafb_783_cell_dcv_detection.feather`

**Content:** Dense core vesicle (DCV) detections from anywhere within FAFB neurons
**Size:** 9.7 GB
**Each row:** One DCV detection

| Column | Description |
|--------|-------------|
| `id` | Unique identifier for the DCV |
| `sv_id` | Supervoxel ID for the DCV's centroid |
| `root_784`, `segment_id` | Unique identifier for the associated FAFB-FlyWire neuron |
| `x`, `y`, `z` | Coordinates of the DCV centroid (nm) |
| `size` | Number of pixels in the detection, from the 4×4×40 nm v14 FAFB volume |
| `confidence` | Confidence score from the detection network |

**Notes:**
- DCV detections performed by Stephan Gerhard (Wei Lee group, HMS)
- DCVs are associated with neuropeptide signalling; their distribution helps identify peptidergic neurons
- Neuron-level summary statistics (`dcv_count`, `dcv_density`) are available in the metadata table

---

### `fafb_783_soma_dcv_detection.feather`

**Content:** Dense core vesicle (DCV) detections localised to FAFB neuron somata
**Size:** 3.7 GB
**Each row:** One somatic DCV detection

| Column | Description |
|--------|-------------|
| `x`, `y`, `z` | Coordinates in FAFB v14.1 FlyWire space (nm) |
| `center_x`, `center_y`, `center_z` | Centre of the soma in FAFB v14.1 FlyWire space (raw) |
| `index` | Section index in which the vesicle is found |
| `area` | Number of pixels |
| `eccentricity` | Measure of how circular the segmentation is |
| `luminance` | Mean pixel intensity |
| `contrast` | Standard deviation of pixel intensities |
| `skew` | Skew of pixel intensities |
| `diameter` | Size measure along one direction |
| `orientation` | Angle between x-axis and major axis of an estimated ellipse encompassing the segmentation |
| `perimeter` | Approximate perimeter of the object |
| `centroid` | Centre of the segmentation |
| `centroid_weighted` | Centre of segmentation weighted by pixel intensities |
| `flywire` | Centre coordinate of vesicle in FlyWire space |
| `flywire_bbox_start` | Start coordinate of the bounding box in FlyWire space |
| `flywire_bbox_end` | End coordinate of the bounding box in FlyWire space |
| `fafb` | Centre coordinate of vesicle in FAFB space |
| `fafb_bbox_start` | Start coordinate of the bounding box in FAFB space |
| `fafb_bbox_end` | End coordinate of the bounding box in FAFB space |

**Notes:**
- Somatic DCV detections performed by Yervand Azatian (Wei Lee group, HMS)
- Somatic DCV counts provide a complementary measure to whole-cell detections
- Neuron-level summary statistics (`dcv_soma_count`, `dcv_soma_density`) are available in the metadata table

---

### Skeleton Directories

| Directory | Space | Description |
|-----------|-------|-------------|
| `fafb_banc_space_swc/` | BANC | FAFB neurons in BANC space (cross-dataset comparisons) |
| `fafb_fafb_space_swc/` | FAFB | Native space (highest resolution) |

**Format:** One `.swc` file per neuron

---

## Region Subsets (build in code)

The pre-computed cut-out folders no longer exist. The `subset_by_region()` helper in
`R/setup/functions.R` and `python/utils.py` reproduces them:

| Subset | Filter |
|--------|--------|
| **antennal_lobe** | Regex `antennal_lobe\|olfactory_receptor\|thermosensory_receptor\|hygrosensory_receptor\|CSD` against metadata |
| **central_complex** | Regex `central_complex` against metadata |
| **mushroom_body** | Regex `mushroom_body\|kenyon_cell\|APL\|DPM\|LHMB1\|OA-VPM3` + KC partners ≥100 syn, `side == "right"` |
| **optic** | `neuropil` matches `^LO\|^LOP\|^AME\|^ME`, `side == "right"`, ≥100 synapses |
| **suboesophageal_zone** | `neuropil` matches `^FLA\|^SEZ\|^GNG\|^SAD\|^AMMC\|^PRW`, ≥100 synapses |

Logic mirrors `bancpipeline/banc/share/banc-sjcabs.R`. Synapse-based subsets use Parquet
predicate pushdown so only matching rows are downloaded.

---

## Data Provenance

- **Source:** FAFB FlyWire v783
- **Processing:** Harmonised to BANC schema
- **DCV detections:** Cellular detections by Stephan Gerhard; somatic detections by Yervand Azatian (Wei Lee group, HMS). Collaboration between Wei Lee (HMS), Alex Bates (HMS), and Meet Zandawala (University of Reno).
- **Citations:**
  - Dorkenwald et al. (2024) "Neuronal wiring diagram" *Nature*
  - Schlegel et al. (2024) "Whole-brain annotation" *Nature*

---

## Loading Examples

**Python:**
```python
import pandas as pd

base = "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/fafb_783"
meta            = pd.read_feather(f"{base}/fafb_783_meta.feather")
edgelist        = pd.read_feather(f"{base}/fafb_783_simple_edgelist.feather")
split_edgelist  = pd.read_feather(f"{base}/fafb_783_split_edgelist.feather")
synapses        = pd.read_parquet(f"{base}/fafb_783_synapses.parquet")

# Dense core vesicle detections
dcv_cell = pd.read_feather(f"{base}/fafb_783_cell_dcv_detection.feather")
dcv_soma = pd.read_feather(f"{base}/fafb_783_soma_dcv_detection.feather")
```

**R:**
```r
library(arrow)

base <- "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/fafb_783"
meta           <- read_feather(file.path(base, "fafb_783_meta.feather"))
edgelist       <- read_feather(file.path(base, "fafb_783_simple_edgelist.feather"))
split_edgelist <- read_feather(file.path(base, "fafb_783_split_edgelist.feather"))
synapses       <- read_parquet(file.path(base, "fafb_783_synapses.parquet"))

# Dense core vesicle detections
dcv_cell <- read_feather(file.path(base, "fafb_783_cell_dcv_detection.feather"))
dcv_soma <- read_feather(file.path(base, "fafb_783_soma_dcv_detection.feather"))
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
