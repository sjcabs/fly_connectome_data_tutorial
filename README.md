# Fly Connectome Data Tutorial

Tutorial materials for working with Drosophila connectome datasets at the [Winter School on Computational Approaches in Biological Sciences (SJCABS)](https://sjcabs.com/). We will work with all the major, dense connectome datasets of 2025.

**Instructors:** Sven Dorkenwald & Alexander Bates

This tutorial provides foundational skills for loading, analyzing, and visualizing connectome data that will be used throughout the workshop. You'll learn to work with neuronal morphologies, synaptic connectivity, and network analysis across multiple fly brain and nerve cord datasets.

---

## Quick Links

- [Connectome Datasets](#connectome-datasets) - BANC, Male CNS, FAFB, MANC, Hemibrain
- [Analysis Tools](#analysis-tools) - Python and R packages with installation guides
- [Data Organization](#data-organization) - Google Drive structure and file types
- [Tutorial Path](#tutorial-path) - What you'll learn (2 hours)
- [Getting Started](#getting-started) - Installation and first steps
- [Citation](#citation) - How to cite these datasets

---

## Connectome Datasets

We focus primarily on two FlyWire datasets—**BANC** and **FAFB**—while also providing access to MANC, Hemibrain, and Male CNS. All datasets have been harmonized to use the unified metadata schema we used in the **BANC** project, enabling cross-dataset comparisons. Possible metadata entries given here: [data/meta_data_entries](data/meta_data_entries.csv).

### BANC (Brain and Nerve Cord)
**Primary dataset for this tutorial**

The first synapse-resolution connectome spanning the both brain and ventral nerve cord. Contains ~114,000 neurons with ~108 million synaptic connections. A female fly. Missing first optic relay, the lamina and retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=banc)
- **Publication:** [Bates et al. (2025)](https://pubmed.ncbi.nlm.nih.gov/40766407/) bioRxiv
- **Documentation:** [data/dataset_documentation/banc_data.md](data/dataset_documentation/banc_data.md)

### Male CNS (Central Nervous System)
Complete male CNS connectome with 166,691 neurons spanning brain and ventral nerve cord. Includes fruitless and doublesex expression data for studying sex-specific circuits. A male fly. Missing retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=mcns) | [neuPrint](https://neuprint.janelia.org/?dataset=male-cns:v0.9)
- **Publication:** [Berg et al. (2025)](https://www.biorxiv.org/content/10.1101/2025.10.09.680999v1) bioRxiv
- **Documentation:** [data/dataset_documentation/malecns_data.md](data/dataset_documentation/malecns_data.md)

### FAFB (Full Adult Fly Brain)
Complete adult female fly brain connectome via the FlyWire project. Contains ~139,000 neurons spanning all brain regions including detailed annotations of 8,453 cell types. A female fly. Missing ventral nerve cord, lamina and retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=fafb)
- **Publication:** [Dorkenwald et al. (2024)](https://www.nature.com/articles/s41586-024-07686-5) Nature; [Schlegel et al. (2024)](https://www.nature.com/articles/s41586-024-07686-5) Nature
- **Documentation:** [data/dataset_documentation/fafb_data.md](data/dataset_documentation/fafb_data.md)

### MANC (Male Adult Nerve Cord)
First complete nerve cord connectome with ~23,000 neurons. A male fly. Missing brain.

- **Explore:** [neuPrint](https://neuprint.janelia.org/?dataset=manc)
- **Publication:** [Takemura et al. (2024)](https://elifesciences.org/reviewed-preprints/97769) eLife
- **Documentation:** [data/dataset_documentation/manc_data.md](data/dataset_documentation/manc_data.md)

### Hemibrain
Dense reconstruction of approximately half the central brain (~25,000 neurons). Includes mushroom body learning circuits and central complex navigation circuits. A female fly. Missing ventral nerve cord and approximately half of the brain.

- **Explore:** [neuPrint](https://neuprint.janelia.org/?dataset=hemibrain:v1.2.1)
- **Publication:** [Scheffer et al. (2020)](https://elifesciences.org/articles/57443) eLife
- **Documentation:** [data/dataset_documentation/hemibrain_data.md](data/dataset_documentation/hemibrain_data.md)

---

## Analysis Tools

### Python
**Installation guide:** [Setting up Python for connectomics](https://navis-org.github.io/neuropython2024/preparing/)

- **[navis](https://navis.readthedocs.io/)** - Neuron analysis and visualization (works with all datasets)
- **[skeletor](https://github.com/navis-org/skeletor)** - Mesh skeletonization
- **[fafbseg-py](https://github.com/navis-org/fafbseg-py)** - FlyWire/FAFB-specific tools
- **[navis-flybrains](https://github.com/navis-org/navis-flybrains)** - Coordinate transforms and template brains
- **[Influence score calculator](https://zenodo.org/records/17693838)** - Quantify influence between sensory and effector neurons

### R
**Installation guide:** [Installing the natverse](https://natverse.org/install/)

Core packages:
- **[natverse](http://natverse.org/)** - NeuroAnatomy Toolbox ecosystem (works with all datasets)
- **[neuprintr](https://github.com/natverse/neuprintr)** - neuPrint client for querying connectome databases
- **[nat.flybrains](https://github.com/natverse/nat.flybrains)** - Coordinate transforms and template brains

Dataset-specific packages:
- **[bancr](https://github.com/flyconnectome/bancr)** - BANC-specific client
- **[fafbseg](https://github.com/natverse/fafbseg)** - FlyWire/FAFB-specific tools
- **[hemibrainr](https://github.com/natverse/hemibrainr)** - Hemibrain-specific tools
- **[malevnc](https://github.com/natverse/malevnc)** - Male VNC (MANC) specific tools
- **[malecns](https://github.com/flyconnectome/malecns)** - Male CNS specific tools

Analysis tools:
- **[influencer](https://github.com/natverse/influencer/)** - Influence score analysis

---

## Data Organization

All processed data is hosted on Google Cloud Storage: **[Access Data](https://console.cloud.google.com/storage/browser/sjcabs_2025_data)**

You can browse and download files directly from the browser, or use command-line tools:
```bash
# List available datasets
gsutil ls gs://sjcabs_2025_data/

# Download a specific file
gsutil cp gs://sjcabs_2025_data/path/to/file .

# Download an entire folder
gsutil -m cp -r gs://sjcabs_2025_data/folder_name .
```

### Example Structure (BANC)
```
banc/
├── banc_746_meta.feather              # Neuron annotations
├── banc_746_edgelist_simple.feather   # Neuron-to-neuron connectivity
├── banc_746_synapses.feather          # Individual synapse data
├── banc_746_skeletons_in_banc_space.zip  # 3D morphologies (SWC format)
├── abdominal_neuromere/               # Subset: abdominal control circuits
├── antennal_lobe/                     # Subset: olfactory circuits
├── central_complex/                   # Subset: navigation circuits
├── front_leg/                         # Subset: front leg control
├── mushroom_body/                     # Subset: associative memory circuits
├── optic/                             # Subset: visual processing circuits
└── suboesophageal_zone/              # Subset: feeding and tactile circuits
```

### File Types
- **`*_meta.feather`** - Metadata for each neuron: cell type, brain region, neurotransmitter, developmental lineage ([schema details](data/meta_data_entries.csv))
- **`*_edgelist_simple.feather`** - Connectivity matrix showing which neurons connect to which, with connection strengths
- **`*_synapses.feather`** - Coordinates and properties of individual synapses
- **`*_skeletons_*.zip`** - 3D skeleton reconstructions in SWC format

See individual dataset documentation files in [`data/dataset_documentation/`](data/dataset_documentation/) for detailed column descriptions.

### Neural System Subsets

We provide curated subsets focusing on specific circuits:

- **Antennal Lobe**: Primary olfactory processing center receiving input from olfactory receptor neurons and projecting to higher brain regions via projection neurons. Critical for odor discrimination and learning.

- **Central Complex**: Navigation circuits for spatial orientation, motor control, and goal-directed behavior. Contains ring neurons encoding heading direction and columnar neurons for path integration.

- **Mushroom Body**: Associative learning and memory circuits. Kenyon cells integrate sensory information and form associations with dopaminergic reinforcement signals.

- **Optic Lobe**: Visual processing through lamina (motion detection), medulla (color and contrast), and lobula (object recognition). Includes both retinotopic local circuits and wide-field integration neurons.

- **Suboesophageal Zone**: Lower brain region controlling feeding, grooming, and processing gustatory/tactile information from mouthparts and antennae.

- **Front Leg / Abdominal Neuromere**: Motor control circuits coordinating limb movements and postural adjustments through local sensory feedback and descending command signals.

---

## Tutorial Path

This tutorial follows a progressive learning path. It is designed to take about 2 hours. 

### 1. Data access
- Find and read our data files, which are stored as .zip or .feather
- Test you can do this across multiple datasets.

### 2. Neuronal Morphology
- Load and visualize 3D neuron skeletons
- Transform coordinates between native dataset spaces and BANC space
- Understand morphological features (dendrites, axons, branch points)

### 3. Synapse Analysis
- Load and map individual synapse locations
- Visualize synaptic distributions along neurites
- Determine axon/dendrite compartments using flow centrality ([navis](https://navis.readthedocs.io/en/latest/source/tutorials/morph_analysis.html) | [natverse](http://natverse.org/nat/reference/flow.centrality.html) implementations)
- Analyze neurotransmitter predictions per synapse

### 4. Connectivity Networks
- Load and query edgelists (connectivity matrices)
- Build and visualize network graphs
- Calculate network properties (hubs, modules, motifs)
- Identify pathways between neuron populations

### 5. Influence Quantification
- Calculate influence scores from sensory neurons to effector neurons
- Understand multi-hop indirect influences through network paths
- Compare influence patterns across datasets
- Relate structural connectivity to functional impact

---

## Getting Started

1. **Download data** from the [Google Cloud Storage bucket](https://console.cloud.google.com/storage/browser/sjcabs_2025_data) for the dataset(s) you want to work with
2. **Install analysis tools:**
   - **Python:** `pip install navis fafbseg`
   - **R:**
     ```r
     install.packages("natmanager")
     natmanager::install(pkgs = "core")

     # Install Python dependencies for fafbseg
     library(fafbseg)
     simple_python()
     ```
3. **Open the first tutorial** in `tutorials/python/` or `tutorials/R/`

---

## Citation

If you use these datasets in your work, please cite the original publications:

**BANC:** Bates, A.S., Phelps, J.S., Kim, M., Yang, H.H., Matsliah, A., Ajabi, Z., Perlman, E., et al. (2025). Distributed control circuits across a brain-and-cord connectome. *bioRxiv*, 2025.07.31.667571. https://doi.org/10.1101/2025.07.31.667571

**FAFB (proofreading):** Dorkenwald, S., Matsliah, A., Sterling, A.R., Schlegel, P., ... Bates, A.S., ... et al. (2024). Neuronal wiring diagram of an adult brain. *Nature*, 634(8032), 124-138. https://doi.org/10.1038/s41586-024-07686-5

**FAFB (annotations):** Schlegel, P., Yin, Y., Bates, A.S., Dorkenwald, S., Eichler, K., Brooks, P., Han, D.S., et al. (2024). Whole-brain annotation and multi-connectome cell typing of Drosophila. *Nature*, 634(8032), 139-152. https://doi.org/10.1038/s41586-024-07686-5

**MANC:** Takemura, S., et al. (2024). A Connectome of the Male Drosophila Ventral Nerve Cord. *eLife*. https://doi.org/10.7554/eLife.97769

**Hemibrain:** Scheffer, L.K., Xu, C., Januszewski, M., Lu, Z., Takemura, S.Y., Bates, A.S., et al. (2020). A connectome and analysis of the adult Drosophila central brain. *eLife*, 9, e57443. https://doi.org/10.7554/eLife.57443

**Male CNS:** Berg, S., Beckett, I.R., Costa, M., Schlegel, P., Januszewski, M., Marin, E.C., Bates, A.S., et al. (2025). Sexual dimorphism in the complete connectome of the Drosophila male central nervous system. *bioRxiv*, 2025.10.09.680999. https://doi.org/10.1101/2025.10.09.680999

**Neurotransmitter Predictions:** Eckstein, N., Bates, A.S., Champion, A., Du, M., Yin, Y., Schlegel, P., Lu, A.K.Y., et al. (2024). Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster. *Cell*, 187(10), 2574-2594.e23. https://doi.org/10.1016/j.cell.2024.03.016

---

## License & Contact

**Data:** Licensed under CC-BY by the respective dataset creators
**Code:** MIT License
**Questions:** Open an issue on this repository or contact the instructors during the workshop

---

**Workshop:** [SJCABS Winter School](https://sjcabs.com/)
**Year:** 2025
