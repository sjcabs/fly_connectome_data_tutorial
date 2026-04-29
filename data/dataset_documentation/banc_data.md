# BANC Dataset Documentation

## Overview

**BANC (Brain and Nerve Cord)** - First complete synapse-resolution connectome spanning both brain and ventral nerve cord.

**Publication:** Bates et al. (2025) *bioRxiv* | **Version:** 888 (CAVE materialization 626 lineage; export 888)
**Scale:** 188,153 neurons | ~169 million synapses | ~13.5 million neuron-neuron connections (v3 edgelist)
**Location:** `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/`

## File Structure

```
compiled_data/banc_888/
├── banc_888_meta.feather                   # ~48 MB  - Neuron metadata (188,153 rows × 75 cols)
├── banc_888_edgelist_simple_v2.feather     # ~285 MB - Neuron connectivity (older v2)
├── banc_888_edgelist_simple_v3.feather     # ~336 MB - Neuron connectivity (latest v3)
├── banc_888_edgelist_split.feather         # ~321 MB - Compartment-to-compartment connectivity
├── banc_888_synapses_v2_enriched.parquet   # ~9.6 GB - Individual synapses (neuropil/region/NT enriched)
└── banc_888_metrics.feather                # ~7.5 MB - Per-neuron cable length, volume, synapse counts
```

BANC neuron skeletons and meshes live at the **bucket root**, not inside `compiled_data/`:

```
gs://lee-lab_brain-and-nerve-cord-fly-connectome/
├── neuron_skeletons/swcs-from-pcg-skel/   # Per-neuron SWC files (BANC space, low-res pcg_skel)
├── neuron_skeletons.zip                    # ~206 MB zipped SWC bundle
├── neuron_meshes/                          # BANC neuron meshes (Neuroglancer precomputed)
└── region_outlines/                        # Region outlines (Neuroglancer precomputed; brain vs VNC and finer regions)
```

> **Note on subsets.** The previous release shipped per-region cut-out folders
> (`mushroom_body/`, `antennal_lobe/`, `central_complex/`, `optic/`, `suboesophageal_zone/`,
> `front_leg/`, `abdominal_neuromere/`). These no longer exist — the tutorials build the
> equivalent subsets in code via the `subset_by_region()` helper, mirroring
> [`bancpipeline/banc/share/banc-sjcabs.R`](https://github.com/flyconnectome/bancpipeline).

---

## File Descriptions

### `banc_888_meta.feather`

**Content:** Neuron metadata and annotations
**Dimensions:** 188,153 rows × 75 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `banc_888_id` | Root ID for the neuron in BANC export 888 (recommended primary key) |
| `supervoxel_id` | Original supervoxel identifier |
| `root_626`, `root_850`, `root_888` | Root IDs at three CAVE materialization snapshots |
| `nucleus_id` | Nucleus ID from BANC nucleus segmentation |
| `proofread`, `roughly_proofread` | Quality flags |
| `position`, `root_position`, `root_position_nm` | Soma / root coordinate locations |
| `region`, `root_region` | CNS region (central_brain, optic_lobe, ventral_nerve_cord, neck_connective) |
| `side` | Laterality (left, right, midline) |
| `hemilineage` | Developmental hemilineage (e.g. 00A, 01B, VPNp1_medial) |
| `nerve` | Entry/exit nerve (if applicable) |
| `neuromere` | VNC neuromere (T1-T3, A1-A8, etc.) |
| `flow` | Information flow direction (intrinsic, afferent, efferent) |
| `super_class` | Coarse functional classification |
| `cell_class` | Intermediate classification |
| `cell_sub_class` | Fine classification |
| `cell_type` | Cell type name |
| `fafb_cell_type`, `manc_cell_type`, `malecns_cell_type`, `hemibrain_cell_type`, `fanc_cell_type` | Matched cell type from each external dataset |
| `fafb_match`, `manc_match`, `malecns_match`, `hemibrain_match`, `fanc_match` | Match confidence/source flags |
| `*_nblast_match` | NBLAST-derived cross-dataset matches |
| `sexually_dimorphic` | Sexual dimorphism annotation |
| `cluster`, `manual_cluster`, `super_cluster` | Connectivity-based grouping labels |
| `cns_network` | Higher-level network assignment |
| `body_part_sensory`, `body_part_effector` | Sensory / motor target body part |
| `peripheral_target_type` | Peripheral target classification |
| `cell_function`, `cell_function_detailed` | Functional category and detailed annotation |
| `neurotransmitter_predicted` | Predicted transmitter (acetylcholine, gaba, glutamate, dopamine, serotonin, octopamine) |
| `neurotransmitter_score` | Confidence score for transmitter prediction (0-1) |
| `neurotransmitter_verified` | Manually verified transmitter (when available) |
| `neuropeptide_verified` | Manually verified neuropeptides (when available) |
| `l2_nodes`, `l2_cable_length_um`, `volume_nm3` | Skeleton size metrics |
| `input_connections`, `output_connections` | Pre/post connection counts |
| `input_side_index`, `output_side_index` | Connectivity-by-side indices |
| `mitochondria`, `mitochondria_volume`, `pd_width`, `segregation_index` | Ultrastructural / morphological metrics |
| `seed_01`–`seed_14` | Seed/proofreading provenance flags |
| `status` | Quality flag (empty = good, TRACING_ISSUE_* = potential issue) |

**Notes:**
- Metadata produced by the unified BANC/FAFB/MANC/maleCNS/Hemibrain matching pipeline.
- Neurotransmitter predictions from Eckstein et al. (2024) *Cell*.

---

### `banc_888_edgelist_simple_v3.feather` (and `_v2`)

**Content:** Neuron-to-neuron connectivity matrix
**Dimensions (v3):** 13,507,098 rows × 6 columns
**Each row:** One presynaptic-postsynaptic neuron pair

#### Columns

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic (source) neuron ID (matches `banc_888_id`) |
| `post` | Postsynaptic (target) neuron ID |
| `count` | Number of synapses connecting pre → post |
| `norm` | `count / post_count` (fraction of target's input from this source) |
| `post_count` | Total synaptic input to the target neuron |
| `pre_count` | Total synaptic output from the source neuron |

**Notes:**
- Two versions (`_v2`, `_v3`) ship in parallel during the v1 → v2 synapse table
  migration; prefer `_v3` for new analyses.
- BANC's column names differ from the other datasets: `post_count` plays the role of
  `total_input` in FAFB / MANC / Hemibrain / maleCNS edgelists.
- Self-connections (autapses) included.

---

### `banc_888_edgelist_split.feather`

**Content:** Compartment-to-compartment connectivity (axon/dendrite/etc.)
**Dimensions:** 5,963,868 rows × 13 columns

#### Columns

| Column | Description |
|--------|-------------|
| `pre`, `post` | Pre / post neuron IDs |
| `pre_label`, `post_label` | Compartment labels (axon, dendrite, primary_dendrite, primary_neurite, soma, unknown) |
| `count` | Synapses connecting compartments |
| `norm` | Normalised by `post_count` |
| `post_count`, `pre_count` | Per-neuron totals (as above) |
| `connection` | Connection type descriptor (e.g. `axon→dendrite`) |
| `pre_conf_nt`, `pre_conf_nt_p` | Pre-side neurotransmitter prediction and confidence |
| `post_conf_nt`, `post_conf_nt_p` | Post-side neurotransmitter prediction and confidence |

---

### `banc_888_synapses_v2_enriched.parquet`

**Content:** Individual synapse locations and properties (synapse table v2 with
neuropil/region/NT enrichment)
**Format:** Parquet (columnar; supports predicate pushdown)
**Size:** ~9.6 GB
**Dimensions:** 168,930,931 rows × 21 columns
**Each row:** One synaptic connection (pre→post)

#### Columns

| Column | Description |
|--------|-------------|
| `id` | Unique synapse identifier |
| `size` | Synapse size (voxels) |
| `pre_root_id`, `post_root_id` | Pre / post neuron IDs |
| `X`, `Y`, `Z` | Coordinates in BANC space (nm) |
| `neuropil` | Neuropil region containing the synapse |
| `region` | Coarse region (central_brain, optic_lobe, ventral_nerve_cord, neck_connective) |
| `side` | Laterality (left, right, midline) |
| `acetylcholine`, `dopamine`, `gaba`, `glutamate`, `histamine`, `octopamine`, `serotonin`, `tyramine` | Per-neurotransmitter probabilities |
| `syn_top_nt` | Predicted top neurotransmitter at this synapse |
| `syn_top_p` | Top-NT probability |
| `label` | Compartment annotation (axon, dendrite, soma, unknown) |

**Notes:**
- Synapse-level transmitter predictions from Eckstein et al. (2024).
- Filter by `neuropil` to subset to a specific region (e.g. `MB_CA_R`) without loading
  the whole table — Parquet predicate pushdown only reads matching row groups.
- Coordinates in BANC space (covers brain and VNC).

---

### Skeletons (bucket root, not in `compiled_data/`)

**Content:** 3D neuron skeletons in SWC format (one file per neuron, named by `banc_888_id`)
**Coordinate space:** BANC (nm)
**Source:** [`pcg_skel`](https://github.com/CAVEconnectome/pcg_skel) — relatively coarse but adequate for most analyses

```
gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons/swcs-from-pcg-skel/
gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons.zip
```

#### SWC File Format

| Column | Description |
|--------|-------------|
| `PointNo` | Unique point identifier |
| `Label` | Point type: -1 (root), 0 (undefined), 1 (soma), 2 (axon), 3 (dendrite), 7 (primary dendrite), 9 (primary neurite) |
| `X`, `Y`, `Z` | 3D coordinates in BANC space (nm) |
| `R` | Radius (nm) |
| `Parent` | Parent point ID (-1 for root) |

---

## Region Subsets (build in code)

Each subset is reproduced by the `subset_by_region()` helper in
`R/setup/functions.R` and `python/utils.py`. Filter logic mirrors
`bancpipeline/banc/share/banc-sjcabs.R`:

| Subset | Filter |
|--------|--------|
| **mushroom_body** | Regex `mushroom_body\|kenyon_cell\|APL\|DPM\|LHMB1\|OA-VPM3` against metadata, `side == "right"`, with KC partners ≥100 syn included |
| **antennal_lobe** | Regex `antennal_lobe\|olfactory_receptor\|thermosensory_receptor\|hygrosensory_receptor\|CSD` against metadata |
| **central_complex** | Regex `central_complex` against metadata |
| **optic** | `neuropil` matches `^LO\|^LOP\|^AME\|^ME`, `side == "right"`, ≥100 synapses per neuron |
| **suboesophageal_zone** | `neuropil` matches `^FLA\|^SEZ\|^GNG\|^SAD\|^AMMC\|^PRW`, ≥100 synapses |
| **front_leg** | `neuropil` matches `^LegNp\(T1\)\|T1\|^ProNM-T1\|^LNp_T1`, `side == "right"`, ≥100 synapses |
| **abdominal_neuromere** | `neuropil` matches `^ANm\|^ABDNM`, ≥100 synapses |

**Usage:** Ideal for focused analyses without loading the full connectome. The synapse
filters use Parquet predicate pushdown so only the matching rows are downloaded from
GCS.

---

## Data Provenance

- **Source:** BANC project (CAVE materialization 626 → export version 888)
- **Processing:** Harmonised to the unified metadata schema (see `data/meta_data_entries.csv`)
- **Quality:** Synapse `cleft_score > 50` upstream filter; left optic lobe is not yet fully proofread
- **Citation:** Bates et al. (2025) "Distributed control circuits across a brain-and-cord connectome" *bioRxiv*

---

## Loading Examples

**Python:**
```python
import pandas as pd

base = "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888"
meta      = pd.read_feather(f"{base}/banc_888_meta.feather")
edgelist  = pd.read_feather(f"{base}/banc_888_edgelist_simple_v3.feather")
split     = pd.read_feather(f"{base}/banc_888_edgelist_split.feather")
# Predicate pushdown: only download synapses in the right mushroom body calyx
synapses  = pd.read_parquet(
    f"{base}/banc_888_synapses_v2_enriched.parquet",
    filters=[("neuropil", "in", ["MB_CA_R"]), ("side", "=", "right")],
)
```

**R:**
```r
library(arrow)

base <- "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888"
meta     <- read_feather(file.path(base, "banc_888_meta.feather"))
edgelist <- read_feather(file.path(base, "banc_888_edgelist_simple_v3.feather"))
split    <- read_feather(file.path(base, "banc_888_edgelist_split.feather"))
# Use open_dataset for lazy filtering on Parquet
synapses <- open_dataset(file.path(base, "banc_888_synapses_v2_enriched.parquet"),
                         format = "parquet") |>
  dplyr::filter(neuropil == "MB_CA_R", side == "right") |>
  dplyr::collect()
```
