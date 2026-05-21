# BANC Dataset Documentation

## Overview

**BANC (Brain and Nerve Cord)** — first complete synapse-resolution connectome spanning both the brain and the ventral nerve cord of an adult female *Drosophila melanogaster*.

**Publication:** Bates, Phelps, Kim, Yang et al. (2026) *Nature*
**Version:** CAVE materialization **888** (snapshot 2026-04-16)
**Scale:** 188,259 neurons | ~198 M synapses (v3) / ~169 M (v2) | ~13.5 M neuron-neuron connections (v3 edgelist) / ~11.5 M (v2)
**Location:** `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/`

> The BANC paper analyses use synapse table **v2** (size >= 5) throughout. New analyses are free to use **v3** (size >= 10) — the updated detector finds ~18% more synapses overall while dropping marginal v2 calls.

## File Structure

```
compiled_data/banc_888/
├── banc_888_meta.feather                                  # ~49 MB  - per-neuron metadata (188,162 rows × ~79 cols)
├── banc_888_metrics.feather                               # ~7.4 MB - slim morphology + synapse-count table (188,259 rows × 12 cols)
├── banc_888_edgelist_simple_v2.feather                    # ~285 MB - neuron-neuron connectivity (v2, size >= 5)
├── banc_888_edgelist_simple_v3.feather                    # ~336 MB - neuron-neuron connectivity (v3, size >= 10)
├── banc_888_edgelist_split_v2.feather                     # ~339 MB - compartment-to-compartment connectivity (v2)
├── banc_888_synapses_v2_enriched.parquet                  # ~9.6 GB - per-synapse table, v2 (neuropil/region/NT enriched, 168.95 M rows × 21 cols)
├── banc_888_synapses_v3_enriched.parquet                  # ~5.6 GB - per-synapse table, v3 (neuropil/region/side enriched, 198.74 M rows × 10 cols; NT joins from a side file)
├── banc_888_neurotransmitter_prediction_v2.csv            # ~21 MB  - per-neuron NT-prediction summary (188,199 rows × 17 cols)
├── banc_888_betweenness_all_to_all_v2.csv                 # ~9.3 MB - all-to-all betweenness on the v2 graph
├── banc_888_betweenness_afferent_to_efferent_v2.csv       # ~8.9 MB - sensory-to-effector betweenness on the v2 graph
├── banc_888_cns_network_spectral_clustering_v2.csv        # per-neuron membership of the CNS networks (spectral clustering on v2 graph)
└── influence/all_to_all/                                  # ~287 GB - pre-computed multiplicative influence scores between proofread pairs (parquet directory; shards keyed by source neuron)
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

**Content:** Per-neuron metadata, annotations, and rolled-up morphology / synapse-count metrics. Primary join target for every downstream analysis.
**Dimensions:** 188,162 rows × ~79 columns
**Each row:** One neuron

#### Key Columns

| Column | Description |
|--------|-------------|
| `banc_888_id` | Root ID at the v888 materialization (recommended primary key). Synonymous with `root_id` in bancr. |
| `supervoxel_id` | A supervoxel of the neuron; small, uneditable chunked-graph unit. Used for resolving annotations to the current root. |
| `root_626`, `root_850`, `root_888` | Root IDs at three CAVE materialization snapshots (kept for joining preprint-era and interim-era resources). |
| `nucleus_id` | Nucleus identifier from the BANC nucleus segmentation. |
| `proofread`, `roughly_proofread` | Manual quality flags. |
| `position`, `root_position`, `root_position_nm` | Soma / root coordinate locations (voxel and nm variants). |
| `region` | CNS region: `central_brain`, `optic_lobe`, `ventral_nerve_cord`, or `cervical_connective`. (In v888 `neck_connective` was retired as a region value; ascending/descending neurons are identified by `super_class` instead, since they span multiple regions.) |
| `side` | Laterality: `left`, `right`, or `center`. |
| `hemilineage` | Developmental hemilineage (e.g. `00A`, `01B`, `VPNp1_medial`). |
| `nerve` | Entry/exit nerve (if applicable). |
| `neuromere` | VNC neuromere (`T1`–`T3`, `A1`–`A8`, etc.). |
| `flow` | Information flow direction: `afferent`, `intrinsic`, or `efferent`. |
| `super_class` | Coarse functional class. One of: `sensory`, `ascending`, `descending`, `intrinsic`, `motor`, `visceral_circulatory`, `ascending_visceral_circulatory`, `optic`. |
| `cell_class` | Intermediate classification (e.g. `central_complex_input`, `mushroom_body_output`, `visual_projection`). |
| `cell_sub_class` | Fine classification. |
| `cell_type` | Cell-type name. |
| `fafb_cell_type`, `manc_cell_type`, `malecns_cell_type`, `hemibrain_cell_type`, `fanc_cell_type` | Matched cell type from each external dataset. |
| `fafb_match`, `manc_match`, `malecns_match`, `hemibrain_match`, `fanc_match` | Match confidence / source flags. |
| `*_nblast_match` | NBLAST-derived cross-dataset matches. |
| `sexually_dimorphic` | Sexual-dimorphism annotation. |
| `cluster`, `manual_cluster`, `super_cluster` | Connectivity-based grouping labels. |
| `cns_network` | Higher-level CNS-network assignment (spectral-clustering output). |
| `body_part_sensory`, `body_part_effector` | Sensory / motor target body part. |
| `peripheral_target_type` | Peripheral target classification. |
| `cell_function`, `cell_function_detailed` | Functional category and detailed annotation. |
| `neurotransmitter_predicted` | Predicted transmitter — one of `acetylcholine`, `dopamine`, `gaba`, `glutamate`, `histamine`, `octopamine`, `serotonin`, `tyramine`. |
| `neurotransmitter_score` | Confidence (max-class probability) of the call in `[0, 1]`. |
| `neurotransmitter_verified` | Manually verified transmitter (when available). |
| `neuropeptide_verified` | Manually verified neuropeptides (when available). |
| `l2_nodes`, `l2_cable_length_um`, `volume_nm3` | Skeleton-size metrics. |
| `input_connections`, `output_connections` | Pre / post synapse counts (v2 graph, `size > 5`). |
| `input_side_index`, `output_side_index` | Connectivity-by-side indices in `[-1, 1]` (negative = left-biased, positive = right-biased). |
| `mitochondria`, `mitochondria_volume`, `pd_width`, `segregation_index` | Ultrastructural / morphological metrics. |
| `seed_01`–`seed_14` | Seed / proofreading provenance flags. |
| `status` | Quality flag (empty = good; `TRACING_ISSUE_*` = potential issue). |

**Notes:**
- Produced by **bancpipeline** (`banc/meta/banc-data.R` Section 1). Manual annotations come from BANC SeaTable; cross-dataset matches are added via the unified BANC/FAFB/MANC/maleCNS/Hemibrain matching pipeline.
- Per-synapse neurotransmitter predictions ultimately come from Eckstein et al. (2024) *Cell* (the 8-NT classifier).

---

### `banc_888_metrics.feather`

**Content:** Slim per-neuron morphology + synapse-count table. Same metric columns as in `banc_888_meta.feather` but without the rest of the annotations — loads ~10× faster when only morphology is needed.
**Dimensions:** 188,259 rows × 12 columns
**Each row:** One neuron

| Column | Description |
|--------|-------------|
| `banc_888_id` | Primary key. |
| `l2_nodes` | Number of L2 chunked-graph nodes in the reconstruction. |
| `l2_cable_length_um` | Total skeletal cable length (micrometers). |
| `volume_nm3` | Total segmentation volume (cubic nanometers). |
| `input_connections` | Number of postsynaptic sites (incoming synapses; v2 `size > 5`). |
| `output_connections` | Number of presynaptic sites (outgoing synapses; v2 `size > 5`). |
| `input_side_index` | Laterality of incoming synapses in `[-1, 1]` (negative = left-biased, positive = right-biased). |
| `output_side_index` | Laterality of outgoing synapses, same convention. |
| `mitochondria` | Mitochondrion count inside the segmentation (CAVE `mitochondria` table). |
| `mitochondria_volume` | Summed mitochondrial volume (cubic nanometers). |
| `pd_width` | Primary-dendrite width from the flow-centrality split. |
| `segregation_index` | Axon/dendrite segregation index in `[0, 1]` (1 = fully polarised). |

---

### `banc_888_edgelist_simple_v3.feather` (and `_v2`)

**Content:** Neuron-to-neuron connectivity matrix.
**Dimensions (v3):** 13,507,098 rows × 6 columns. (v2: 11,510,975 rows.)
**Each row:** One directed presynaptic → postsynaptic pair.

| Column | Description |
|--------|-------------|
| `pre` | Presynaptic (source) neuron ID. Matches `banc_888_id`. |
| `post` | Postsynaptic (target) neuron ID. |
| `count` | Number of synapses connecting `pre → post`. |
| `norm` | `count / post_count` — fraction of the target's total input contributed by this source. |
| `post_count` | Total synaptic input to the target neuron. |
| `pre_count` | Total synaptic output from the source neuron. |

**Notes:**
- Two snapshots ship in parallel. Bates, Phelps, Kim, Yang et al. (2026) use **v2** (size >= 5); v3 (size >= 10) is preferred for new work — the updated detector adds ~18% more synapses overall.
- Self-connections (autapses) are **excluded** at build time. They account for ~2.1% of synaptic connections in BANC.
- No global `count` threshold is applied — apply `count >= 5` at read time for the Codex-style connectivity threshold.
- BANC's column names differ from the other datasets in this tutorial: `post_count` plays the role of `total_input` in FAFB / MANC / Hemibrain / maleCNS edgelists.

---

### `banc_888_edgelist_split_v2.feather`

**Content:** Compartment-to-compartment connectivity (axon / dendrite / etc.) — same `pre → post` pairs as `banc_888_edgelist_simple_v2.feather` but split by compartment label.
**Dimensions:** ~6.3 M rows × 13 columns.

| Column | Description |
|--------|-------------|
| `pre`, `post` | Pre / post neuron IDs. |
| `pre_label`, `post_label` | Compartment labels (`axon`, `dendrite`, `primary_dendrite`, `primary_neurite`, `soma`, `unknown`). |
| `count` | Number of synapses connecting the two compartments. |
| `norm` | Normalised by `post_count` (full-neuron input total). |
| `post_count`, `pre_count` | Per-neuron totals (as in the simple edgelist). |
| `connection` | Connection-type descriptor (e.g. `axon→dendrite`). |
| `pre_conf_nt`, `pre_conf_nt_p` | Pre-side neurotransmitter prediction and confidence. |
| `post_conf_nt`, `post_conf_nt_p` | Post-side neurotransmitter prediction and confidence. |

---

### `banc_888_synapses_v2_enriched.parquet`

**Content:** Per-synapse table at the v2 snapshot, enriched with pre/post root IDs, neuropil & region labels, coordinates, the 8-NT classifier output, and a compartment code.
**Format:** Parquet (columnar; supports predicate pushdown).
**Dimensions:** 168,951,110 rows × 21 columns.
**Each row:** One predicted synaptic contact.

| Column | Description |
|--------|-------------|
| `id` | Unique synapse identifier. |
| `size` | Synapse footprint (voxels; >= 5 for v2). |
| `pre_root_id`, `post_root_id` | Pre / post neuron IDs at v888. |
| `X`, `Y`, `Z` | Synapse centroid in BANC nanometers. |
| `neuropil` | Neuropil code from the alpha-shape parcellation (FlyWire-style; e.g. `MB_CA_R`, `ITO_optic_LO_R`). |
| `region` | Coarse CNS region: bulk values `central_brain`, `optic_lobe`, `ventral_nerve_cord`; sub-partitions `neck`, `sez` may appear at boundaries; `outside` for synapses that fail the alpha-shape test. (Finer-grained than the neuron-level `region` in the meta table — normalise on read if cross-table consistency is needed.) |
| `side` | Laterality: `left` or `right`. |
| `acetylcholine`, `dopamine`, `gaba`, `glutamate`, `histamine`, `octopamine`, `serotonin`, `tyramine` | Per-neurotransmitter probabilities (8 classes, Eckstein et al. 2024). |
| `syn_top_nt` | Argmax neurotransmitter at this synapse. |
| `syn_top_p` | Probability of the top class. |
| `label` | Compartment annotation derived from flow-centrality (`axon`, `dendrite`, `soma`, `unknown`). |

**Notes:**
- Filter by `neuropil` or `region` to subset without loading the whole table — Parquet predicate pushdown only reads matching row groups.
- Autapses are excluded at build time.

---

### `banc_888_neurotransmitter_prediction_v2.csv`

**Content:** Per-neuron neurotransmitter call aggregated from the synapse-level v2 classifier.
**Dimensions:** 188,199 rows × 17 columns.

| Column | Description |
|--------|-------------|
| `root_id` | Root ID of the presynaptic neuron at v888. Synonymous with `banc_888_id`. |
| `acetylcholine`, `dopamine`, `gaba`, `glutamate`, `histamine`, `octopamine`, `serotonin`, `tyramine` | Per-NT presynapse counts (number of presynapses whose argmax was this transmitter). |
| `neurotransmitter_predicted` | Per-neuron predicted transmitter (argmax over the 8 sums); absent for neurons with no classified presynapses. |
| `neurotransmitter_score` | Confidence in `[0, 1]` — max-NT sum divided by the total NT sum. |
| `count` | Total presynapses with a non-NA classifier output for this neuron. |
| `supervoxel_id` | A supervoxel of the neuron (for chunked-graph resolution). |
| `position` | Soma anchor position in BANC voxel space (`"x, y, z"`, 4 × 4 × 45 nm/voxel). |
| `cell_type` | Curated cell type, joined from SeaTable. Used to compute the per-`cell_type` consensus columns. |
| `cell_type_neurotransmitter_predicted` | Per-`cell_type` consensus NT (count-weighted argmax over members of the cell type). |
| `cell_type_neurotransmitter_score` | Per-`cell_type` consensus confidence in `[0, 1]`. |

---

### `banc_888_betweenness_{all_to_all,afferent_to_efferent}_v2.csv`

**Content:** Graph-betweenness centrality on the v2 neuron-to-neuron graph. The `all_to_all` variant counts shortest paths between every pair of proofread neurons; the `afferent_to_efferent` variant restricts the source set to sensory neurons and the target set to effector neurons (motor / endocrine / visceral_circulatory).

| Column | Description |
|--------|-------------|
| `vertex_id` | 0-indexed vertex ID within the igraph object used for the computation. Not stable across reruns. |
| `root_888` | BANC v888 root ID of the neuron. |
| `super_class` | super_class from `banc_888_meta.feather`. |
| `cell_type` | cell_type from `banc_888_meta.feather`. |
| `betweenness` | Brandes betweenness — sum over every shortest-path-pair fraction (or every (sensory, effector) pair for the afferent-to-efferent variant). |

---

### `banc_888_cns_network_spectral_clustering_v2.csv`

**Content:** Per-neuron membership of the CNS networks identified by spectral clustering on the v2 graph. Restricted to intrinsic neurons (one row per intrinsic neuron in BANC).

| Column | Description |
|--------|-------------|
| `root_id` | BANC v888 root ID of the intrinsic neuron. |
| `supervoxel_id` | A supervoxel of the neuron (for chunked-graph resolution). |
| `position` | Soma position in BANC raw voxel space (`"x, y, z"`). |
| `spectral_cluster` | 1-indexed cluster ID assigned by k-means on the Laplacian eigenvectors. |
| `umap_x` | UMAP coordinate 1 of the connectivity-Laplacian embedding. |
| `umap_y` | UMAP coordinate 2. |
| `cns_network` | User-facing network label (e.g. `central complex related`, `abdominal VNC`, `left olfactory`). Matches the `cns_network` column in `banc_888_meta.feather`. |

---

### `influence/all_to_all/`

**Content:** Pre-computed multiplicative influence scores between every pair of proofread BANC neurons, under the linear-dynamical-systems model described in Bates, Phelps, Kim, Yang et al. (2026). Stored as a sharded Parquet directory (~287 GB) partitioned by source neuron, so `filters=[("upstream_id", "in", ids)]` downloads only the shards of interest.

| Column | Description |
|--------|-------------|
| `upstream_id` | Source neuron (banc_888_id). ~500 distinct values per shard. |
| `downstream_id` | Target neuron (banc_888_id). ~138,000 distinct values per shard. |
| `raw_influence` | Steady-state response of the target to a sustained unit signal at the source. Always positive; very small values dominate the long tail. Take `max(0, log(raw_influence) + 24)` to recover the adjusted-influence metric used in the paper. |

---

### Skeletons (bucket root, not in `compiled_data/`)

**Content:** 3D neuron skeletons in SWC format (one file per neuron, named by `banc_888_id`).
**Coordinate space:** BANC (nm).
**Source:** [`pcg_skel`](https://github.com/CAVEconnectome/pcg_skel) — relatively coarse but adequate for most analyses.

```
gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons/swcs-from-pcg-skel/
gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons.zip
```

#### SWC File Format

| Column | Description |
|--------|-------------|
| `PointNo` | Unique point identifier. |
| `Label` | Point type: -1 (root), 0 (undefined), 1 (soma), 2 (axon), 3 (dendrite), 7 (primary dendrite), 9 (primary neurite). |
| `X`, `Y`, `Z` | 3D coordinates in BANC space (nm). |
| `R` | Radius (nm). |
| `Parent` | Parent point ID (-1 for root). |

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

- **Source:** BANC project (CAVE materialization 888, snapshot 2026-04-16).
- **Processing:** Harmonised to the unified BANC framework — the column names listed above match across BANC, FAFB, MANC, Hemibrain, and maleCNS in `compiled_data/`.
- **Quality:** Synapse `cleft_score > 50` upstream filter.
- **Citation:** Bates, Phelps, Kim, Yang et al. (2026). "Distributed control circuits across a brain-and-cord connectome." *Nature*.

---

## Loading Examples

**Python:**
```python
import pandas as pd

base = "gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888"
meta      = pd.read_feather(f"{base}/banc_888_meta.feather")
metrics   = pd.read_feather(f"{base}/banc_888_metrics.feather")
edgelist  = pd.read_feather(f"{base}/banc_888_edgelist_simple_v3.feather")
split     = pd.read_feather(f"{base}/banc_888_edgelist_split_v2.feather")
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
metrics  <- read_feather(file.path(base, "banc_888_metrics.feather"))
edgelist <- read_feather(file.path(base, "banc_888_edgelist_simple_v3.feather"))
split    <- read_feather(file.path(base, "banc_888_edgelist_split_v2.feather"))
# Use open_dataset for lazy filtering on Parquet
synapses <- open_dataset(file.path(base, "banc_888_synapses_v2_enriched.parquet"),
                         format = "parquet") |>
  dplyr::filter(neuropil == "MB_CA_R", side == "right") |>
  dplyr::collect()
```
