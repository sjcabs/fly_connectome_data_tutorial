# Fly Connectome Data Tutorial

Tutorial materials for working with Drosophila connectome datasets at the [San Juan Winter School on Connectomics and Brain Simulation (SJCABS)](https://sjcabs.com/). We will work with all the major, dense connectome datasets for the fruit fly.

**Instructors:** [Sven Dorkenwald](https://scholar.google.com/citations?user=sGHphbYAAAAJ&hl=en) & [Alexander Bates](https://scholar.google.com/citations?user=BOVTiXIAAAAJ&hl=en)

This tutorial provides foundational skills for loading, analysing, and visualising connectome data that will be used throughout the workshop. You'll learn to work with neuronal morphologies, synaptic connectivity, and network analysis across multiple fly brain and nerve cord datasets. Key contributors to the tools used in, and to prepare, this workshop include [Philipp Schlegel](https://scholar.google.com/citations?user=_JMLZbcAAAAJ&hl=en) and [Greg Jefferis](https://scholar.google.com/citations?user=cuXoCA8AAAAJ&hl=en).

---

# This tutorial

This tutorial offers: 

1. curated data for connectomic analyses.

2. concise Python and R code for simple but effective analyses of connectome data. 

3. guides you through some general principles of exploratory connectomics analysis that should be useful. 

---

## Quick Links

- [Connectome Datasets](#connectome-datasets) - BANC, Male CNS, FAFB, MANC, Hemibrain
- [Guides](#guides) - Neuroglancer and ultrastructure guides
- [Analysis Tools](#analysis-tools) - Python and R packages with installation guides
- [Data Organisation](#data-organisation) - Google Drive structure and file types
- [Tutorial Path](#tutorial-path) - What you'll learn (2 hours)
- [Getting Started](#getting-started) - Installation and first steps
- [Citation](#citation) - How to cite the datasets

---

<p align="center">
  <img src="inst/images/banner.png" alt="Fly connectome datasets" width="100%">
</p>

## Connectome Datasets

We focus primarily on two FlyWire datasets—**BANC** and **FAFB**—while also providing access to MANC, Hemibrain, and Male CNS. All datasets have been harmonized to use the unified metadata schema we used in the **BANC** project, enabling cross-dataset comparisons. Possible metadata entries given here: [data/meta_data_entries](data/meta_data_entries.csv). You can see renderings of neuronal meshes from the BANC, FAFB, MANC and HemiBrain datasets in neuroglancer [here](https://ngl.banc.community/view).

<p align="center">
  <img src="inst/images/banc.png" alt="BANC connectome" width="40%">
</p>

### BANC (Brain and Nerve Cord)
**Primary dataset for this tutorial**

The first synapse-resolution connectome that spanning the brain and ventral nerve cord. Contains ~114,000 neurons with ~108 million synaptic connections. A female fly. Missing the first optic relay, the lamina, and the retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=banc) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B4e-9%2C%22m%22%5D%2C%22y%22:%5B4e-9%2C%22m%22%5D%2C%22z%22:%5B4.5e-8%2C%22m%22%5D%7D%2C%22position%22:%5B120011.1796875%2C30963.720703125%2C3154.5%5D%2C%22crossSectionScale%22:1.5696123052244317%2C%22projectionOrientation%22:%5B-0.00458524888381362%2C0.9922990202903748%2C-0.12186047434806824%2C0.021718576550483704%5D%2C%22projectionScale%22:501856.617474674%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22precomputed://gs://seunglab_lee_fly_cns_001_alignment/aligned/v0%22%2C%22tab%22:%22source%22%2C%22shader%22:%22#uicontrol%20float%20black%20slider%28min=0%2C%20max=1%2C%20default=0.0%29%5Cn#uicontrol%20float%20white%20slider%28min=0%2C%20max=1%2C%20default=1.0%29%5Cnfloat%20rescale%28float%20value%29%20%7B%5Cn%20%20return%20%28value%20-%20black%29%20/%20%28white%20-%20black%29%3B%5Cn%7D%5Cnvoid%20main%28%29%20%7B%5Cn%20%20float%20val%20=%20toNormalized%28getDataValue%28%29%29%3B%5Cn%20%20if%20%28val%20%3C%20black%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%280%2C0%2C0%29%29%3B%5Cn%20%20%7D%20else%20if%20%28val%20%3E%20white%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%281.0%2C%201.0%2C%201.0%29%29%3B%5Cn%20%20%7D%20else%20%7B%5Cn%20%20%20%20emitGrayscale%28rescale%28val%29%29%3B%5Cn%20%20%7D%5Cn%7D%5Cn%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%5B%7B%22url%22:%22graphene://middleauth+https://cave.fanc-fly.com/segmentation/table/wclee_fly_cns_001%22%2C%22subsources%22:%7B%22default%22:true%2C%22graph%22:true%2C%22bounds%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%7B%22url%22:%22precomputed://middleauth+https://cave.fanc-fly.com/skeletoncache/api/v1/brain_and_nerve_cord/precomputed/skeleton%22%2C%22enableDefaultSubsources%22:false%7D%5D%2C%22tab%22:%22source%22%2C%22segments%22:%5B%22%21720575941581870457%22%2C%22%21720575941562217517%22%2C%22%21720575941521454003%22%2C%22%21720575941642438776%22%5D%2C%22timestamp%22:1753103400000%2C%22timestampOwner%22:%5B%22BANC%20m626%22%5D%2C%22name%22:%22BANC%20m626%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://lee-lab_brain-and-nerve-cord-fly-connectome/region_outlines/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22rendering%22%2C%22selectedAlpha%22:0%2C%22meshSilhouetteRendering%22:2%2C%22segments%22:%5B%221%22%5D%2C%22name%22:%22region_outlines%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22region_outlines%22%7D%2C%22layout%22:%22xy-3d%22%7D)
- **Publication:** [Bates et al. (2025)](https://pubmed.ncbi.nlm.nih.gov/40766407/) bioRxiv
- **Documentation:** [data/dataset_documentation/banc_data.md](data/dataset_documentation/banc_data.md)

<p align="center">
  <img src="inst/images/malecns.png" alt="Male CNS connectome" width="40%">
</p>

### Male CNS (Central Nervous System)
Complete male CNS connectome with 166,691 neurons spanning the brain and ventral nerve cord. Includes fruitless and doublesex expression data for studying sex-specific circuits. A male fly. Missing retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=mcns) | [neuPrint](https://neuprint.janelia.org/?dataset=male-cns:v0.9) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B0.000004096%2C%22m%22%5D%2C%22y%22:%5B0.000004096%2C%22m%22%5D%2C%22z%22:%5B0.00000512%2C%22m%22%5D%7D%2C%22position%22:%5B123.39667510986328%2C37.636898040771484%2C35.086002349853516%5D%2C%22crossSectionScale%22:0.0019169223883004237%2C%22projectionOrientation%22:%5B0.047697652131319046%2C0.02295735850930214%2C0.010306727141141891%2C0.9985447525978088%5D%2C%22projectionScale%22:100.04291034597205%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22gs://flyem-male-cns/em/em-clahe-jpeg/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%7B%22url%22:%22gs://flyem-male-cns/v0.9/segmentation/clio/%7Cneuroglancer-precomputed:%22%2C%22subsources%22:%7B%22default%22:true%2C%22bounds%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%22tab%22:%22segments%22%2C%22segments%22:%5B%5D%2C%22name%22:%22MaleCNS_v0.9%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%7B%22url%22:%22gs://flyem-male-cns/rois/fullbrain-major-shells/%7Cneuroglancer-precomputed:%22%2C%22subsources%22:%7B%22default%22:true%2C%22properties%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%22tab%22:%22rendering%22%2C%22selectedAlpha%22:0%2C%22saturation%22:0%2C%22hoverHighlight%22:false%2C%22meshSilhouetteRendering%22:7%2C%22segments%22:%5B%221%22%2C%222%22%2C%223%22%5D%2C%22segmentDefaultColor%22:%22#ffffff%22%2C%22name%22:%22fullbrain-major-shells%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22MaleCNS_v0.9%22%7D%2C%22layout%22:%22xy-3d%22%7D)
- **Publication:** [Berg et al. (2025)](https://www.biorxiv.org/content/10.1101/2025.10.09.680999v1) bioRxiv
- **Documentation:** [data/dataset_documentation/malecns_data.md](data/dataset_documentation/malecns_data.md)

<p align="center">
  <img src="inst/images/fafb.png" alt="FAFB connectome" width="40%">
</p>

### FAFB (Full Adult Fly Brain)
Complete adult female fly brain connectome via the FlyWire project. Contains ~139,000 neurons spanning all brain regions, including detailed annotations of 8,453 cell types. A female fly. Missing ventral nerve cord and retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=fafb) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B4e-9%2C%22m%22%5D%2C%22y%22:%5B4e-9%2C%22m%22%5D%2C%22z%22:%5B4e-8%2C%22m%22%5D%7D%2C%22position%22:%5B132596.984375%2C53845.46875%2C3380.5%5D%2C%22crossSectionScale%22:13.628079869267063%2C%22projectionScale%22:255985.26295878578%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22precomputed://https://bossdb-open-data.s3.amazonaws.com/flywire/fafbv14%22%2C%22tab%22:%22rendering%22%2C%22shader%22:%22#uicontrol%20float%20black%20slider%28min=0%2C%20max=1%2C%20default=0.0%29%5Cn#uicontrol%20float%20white%20slider%28min=0%2C%20max=1%2C%20default=1.0%29%5Cnfloat%20rescale%28float%20value%29%20%7B%5Cn%20%20return%20%28value%20-%20black%29%20/%20%28white%20-%20black%29%3B%5Cn%7D%5Cnvoid%20main%28%29%20%7B%5Cn%20%20float%20val%20=%20toNormalized%28getDataValue%28%29%29%3B%5Cn%20%20if%20%28val%20%3C%20black%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%280%2C0%2C0%29%29%3B%5Cn%20%20%7D%20else%20if%20%28val%20%3E%20white%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%281.0%2C%201.0%2C%201.0%29%29%3B%5Cn%20%20%7D%20else%20%7B%5Cn%20%20%20%20emitGrayscale%28rescale%28val%29%29%3B%5Cn%20%20%7D%5Cn%7D%5Cn%22%2C%22shaderControls%22:%7B%22white%22:0.82%7D%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%7B%22url%22:%22precomputed://gs://flywire_v141_m783%22%2C%22subsources%22:%7B%22default%22:true%2C%22bounds%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%22tab%22:%22segments%22%2C%22segments%22:%5B%5D%2C%22name%22:%22flywire_m783%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%5B%22precomputed://gs://flywire_neuropil_meshes/whole_neuropil/brain_mesh_v3%22%2C%22precomputed://middleauth+https://global.daf-apis.com/nglstate/api/v1/property/4691248662183936%22%5D%2C%22tab%22:%22segments%22%2C%22objectAlpha%22:0.5%2C%22meshSilhouetteRendering%22:2%2C%22segments%22:%5B%221%22%5D%2C%22segmentDefaultColor%22:%22#ffffff%22%2C%22name%22:%22Brain%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%5B%22precomputed://gs://flywire_neuropil_meshes/neuropils/neuropil_mesh_v141_v6%22%2C%22precomputed://middleauth+https://global.daf-apis.com/nglstate/api/v1/property/6127113405988864%22%5D%2C%22tab%22:%22segments%22%2C%22selectedAlpha%22:0.83%2C%22objectAlpha%22:0.5%2C%22meshSilhouetteRendering%22:1%2C%22segments%22:%5B%5D%2C%22name%22:%22Neuropils%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22flywire_m783%22%7D%2C%22layout%22:%22xy-3d%22%7D)
- **Publication:** [Dorkenwald et al. (2024)](https://www.nature.com/articles/s41586-024-07686-5) Nature; [Schlegel et al. (2024)](https://www.nature.com/articles/s41586-024-07686-5) Nature
- **Documentation:** [data/dataset_documentation/fafb_data.md](data/dataset_documentation/fafb_data.md)

<p align="center">
  <img src="inst/images/manc.png" alt="MANC connectome" width="25%">
</p>

### MANC (Male Adult Nerve Cord)
First complete nerve cord connectome with ~23,000 neurons. A male fly. Missing brain.

- **Explore:** [neuPrint](https://neuprint.janelia.org/?dataset=manc) | [Codex](https://codex.flywire.ai/?dataset=manc) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B8e-9%2C%22m%22%5D%2C%22y%22:%5B8e-9%2C%22m%22%5D%2C%22z%22:%5B8e-9%2C%22m%22%5D%7D%2C%22position%22:%5B23056.5%2C29733.5%2C41138.5%5D%2C%22crossSectionScale%22:1%2C%22projectionScale%22:131072%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22gs://flyem-vnc-2-26-213dba213ef26e094c16c860ae7f4be0/v3_emdata_clahe_xy/jpeg/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://manc-seg-v1p2/manc-seg-v1.2/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22segments%22:%5B%5D%2C%22name%22:%22MANC%20v1.2.3%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://flyem-vnc-roi-d5f392696f7a48e27f49fa1a9db5ee3b/roi-202208/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22selectedAlpha%22:0%2C%22segments%22:%5B%5D%2C%22name%22:%22neuropils%22%7D%5D%2C%22showAxisLines%22:false%2C%22showDefaultAnnotations%22:false%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22MANC%20v1.2.3%22%7D%2C%22layout%22:%22xy-3d%22%2C%22selection%22:%7B%22layers%22:%7B%22seg%22:%7B%22annotationId%22:%22data-bounds%22%2C%22annotationSource%22:0%2C%22annotationSubsource%22:%22bounds%22%7D%7D%7D%7D)
- **Publication:** [Takemura et al. (2024)](https://elifesciences.org/reviewed-preprints/97769) eLife
- **Documentation:** [data/dataset_documentation/manc_data.md](data/dataset_documentation/manc_data.md)

<p align="center">
  <img src="inst/images/hemibrain.png" alt="Hemibrain connectome" width="40%">
</p>

### Hemibrain
Dense reconstruction of approximately half the central brain (~25,000 neurons). Includes mushroom body learning circuits and central complex navigation circuits. A female fly. Missing ventral nerve cord and approximately half of the brain and optic lobes.

- **Explore:** [neuPrint](https://neuprint.janelia.org/?dataset=hemibrain%3Av1.2.1&qt=findneurons) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B8e-9%2C%22m%22%5D%2C%22y%22:%5B8e-9%2C%22m%22%5D%2C%22z%22:%5B8e-9%2C%22m%22%5D%7D%2C%22position%22:%5B30005.095703125%2C20073.41015625%2C12157.427734375%5D%2C%22crossSectionScale%22:9.214678755682833%2C%22projectionOrientation%22:%5B-0.03779619187116623%2C0.38050830364227295%2C0.13536255061626434%2C0.9140360355377197%5D%2C%22projectionScale%22:441638.40352250263%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22gs://neuroglancer-janelia-flyem-hemibrain/emdata/clahe_yz/jpeg/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://neuroglancer-janelia-flyem-hemibrain/v1.2/segmentation/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22segments%22:%5B%5D%2C%22name%22:%22Hemibrain%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://neuroglancer-janelia-flyem-hemibrain/v1.2/rois/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22segments%22%2C%22selectedAlpha%22:0%2C%22segments%22:%5B%5D%2C%22name%22:%22rois%22%7D%5D%2C%22showAxisLines%22:false%2C%22showDefaultAnnotations%22:false%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22Hemibrain%22%7D%2C%22layout%22:%22xy-3d%22%2C%22selection%22:%7B%22layers%22:%7B%22seg%22:%7B%22annotationId%22:%22data-bounds%22%2C%22annotationSource%22:0%2C%22annotationSubsource%22:%22bounds%22%7D%7D%7D%7D)
- **Publication:** [Scheffer et al. (2020)](https://elifesciences.org/articles/57443) eLife
- **Documentation:** [data/dataset_documentation/hemibrain_data.md](data/dataset_documentation/hemibrain_data.md)

---
## Guides

These guides were created by the FlyWire project:
- [Neuroglancer cheatsheet](https://docs.google.com/document/d/1ZHJIRAiH0QsIjtwIsO8nKjyzT2zXsgdWbV5xwXAUjgc/edit?usp=sharing) (slightly different neuroglancer version)
- [Fly synapses](https://docs.google.com/document/d/1tNeG-SIOlSAORXn_m8bKdjcIM80ksPAtyOk8u2CXj_4/edit?usp=sharing)
- [Ultrastructure and morphology](https://docs.google.com/document/d/1Jj9k53hr8CFnh2KmeqjVl3JSpjy2J3LRCmCORnxmnLY/edit?usp=sharing)

---

## Analysis Tools

<p align="center">
  <img src="inst/images/navis.png" alt="navis - neuron analysis and visualization" width="30%">
</p>

### Python
**Installation guide:** [Setting up Python for connectomics](https://navis-org.github.io/neuropython2024/preparing/)

- **[navis](https://navis.readthedocs.io/)** - Neuron analysis and visualisation (works with all datasets)
- **[skeletor](https://github.com/navis-org/skeletor)** - Mesh skeletonisation
- **[fafbseg-py](https://github.com/navis-org/fafbseg-py)** - FlyWire/FAFB-specific tools
- **[navis-flybrains](https://github.com/navis-org/navis-flybrains)** - Coordinate transforms and template brains
- **[ConnectomeInfluenceCalculator](https://zenodo.org/records/17693838)** - Quantify influence between sensory and effector neurons
- **[cocoa](https://github.com/flyconnectome/cocoa)** - Compare inter/intra-dataset connectivity
-**[CAVEclient](https://github.com/CAVEconnectome/CAVEclient)** - Live connectome dataset annotation and tracking (for flies: FAFB, BANC, FANC)
  
<p align="center">
  <img src="inst/images/natverse_promotion.png" alt="natverse - NeuroAnatomy Toolbox for R" width="70%">
</p>

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
- **[coconatfly](https://natverse.org/coconatfly/)** - Compare inter/intra-dataset connectivity
- **[influencer](https://github.com/natverse/influencer/)** - Influence score analysis

---

## Data Organisation

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

- **Antennal Lobe**: Primary olfactory processing centre receiving input from olfactory receptor neurons and projecting to higher brain regions via projection neurons. Critical for odour discrimination and learning.

- **Central Complex**: Navigation circuits for spatial orientation, motor control, and goal-directed behaviour. Contains ring neurons encoding heading direction and columnar neurons for path integration.

- **Mushroom Body**: Associative learning and memory circuits. Kenyon cells integrate sensory information and form associations with dopaminergic reinforcement signals.

- **Optic Lobe**: Visual processing through lamina (motion detection), medulla (colour and contrast), and lobula (object recognition). Includes both retinotopic local circuits and wide-field integration neurons.

- **Suboesophageal Zone**: Lower brain region controlling feeding, grooming, and processing gustatory/tactile information from mouthparts and antennae.

- **Front Leg / Abdominal Neuromere**: Motor control circuits coordinating limb movements and postural adjustments through local sensory feedback and descending command signals.

---

## Detailed Data Inventory

### BANC (Brain and Nerve Cord)
**[Browse Files](https://console.cloud.google.com/storage/browser/sjcabs_2025_data/banc)** | `gs://sjcabs_2025_data/banc/`

- [`banc_746_meta.feather`](https://console.cloud.google.com/storage/browser/_details/sjcabs_2025_data/banc/banc_746_meta.feather) (0.01 GB) - Metadata
- [`banc_746_simple_edgelist.feather`](https://console.cloud.google.com/storage/browser/_details/sjcabs_2025_data/banc/banc_746_simple_edgelist.feather) (4.8 GB) - Connectivity
- [`banc_746_synapses.feather`](https://console.cloud.google.com/storage/browser/_details/sjcabs_2025_data/banc/banc_746_synapses.feather) (10.2 GB) - Synapses
- [`banc_banc_space_l2_swc.zip`](https://console.cloud.google.com/storage/browser/_details/sjcabs_2025_data/banc/banc_banc_space_l2_swc.zip) - Skeletons
- **Curated subsets:** `abdominal_neuromere/`, `antennal_lobe/`, `central_complex/`, `front_leg/`, `mushroom_body/`, `optic/`, `suboesophageal_zone/`

### FAFB (Full Adult Fly Brain)
**[Browse Files](https://console.cloud.google.com/storage/browser/sjcabs_2025_data/fafb)** | `gs://sjcabs_2025_data/fafb/`

- `fafb_783_meta.feather` (~0.01 GB) - Metadata
- `fafb_783_simple_edgelist.feather` (~5 GB) - Connectivity
- `fafb_783_split_edgelist.feather` (~10 GB) - Compartment connectivity
- `fafb_783_synapses.feather` (~12 GB) - Synapses
- `fafb_783_banc_space_swc.zip` - Skeletons (BANC space)
- `fafb_fafb_space_swc.zip` - Skeletons (native FAFB space)
- **Curated subsets:** `antennal_lobe/`, `central_complex/`, `mushroom_body/`, `optic/`, `suboesophageal_zone/`

### MANC (Male Adult Nerve Cord)
**[Browse Files](https://console.cloud.google.com/storage/browser/sjcabs_2025_data/manc)** | `gs://sjcabs_2025_data/manc/`

- `manc_121_meta.feather` (~0.005 GB) - Metadata
- `manc_121_simple_edgelist.feather` (~1.5 GB) - Connectivity
- `manc_121_split_edgelist.feather` (~3 GB) - Compartment connectivity
- `manc_121_synapses.feather` (~4 GB) - Synapses
- `manc_banc_space_swc.zip` - Skeletons (BANC space)

### Hemibrain
**[Browse Files](https://console.cloud.google.com/storage/browser/sjcabs_2025_data/hemibrain)** | `gs://sjcabs_2025_data/hemibrain/`

- `hemibrain_121_meta.feather` (~0.005 GB) - Metadata
- `hemibrain_121_simple_edgelist.feather` (~2 GB) - Connectivity
- `hemibrain_121_split_edgelist.feather` (~4 GB) - Compartment connectivity
- `hemibrain_121_synapses.feather` (~5 GB) - Synapses
- `hemibrain_banc_space_swc.zip` - Skeletons (BANC space)
- `hemibrain_hemibrain_raw_space_swc.zip` - Skeletons (native space)
- `neuropils/`, `obj/` - Mesh data

### Download Examples
```bash
# Small file - metadata (recommended to start)
gsutil cp gs://sjcabs_2025_data/banc/banc_746_meta.feather .

# Curated subset - much smaller than full dataset
gsutil -m cp -r gs://sjcabs_2025_data/banc/antennal_lobe/ .

# Large file - check size first
gsutil ls -lh gs://sjcabs_2025_data/banc/banc_746_synapses.feather
```

---

## Tutorial Path

This tutorial follows a progressive learning path designed to take about 2 hours for the core content, with optional extensions for deeper exploration.

### Tutorial 01: Data Access (30 minutes)
**[R version](R/01_data_access.Rmd) | [Python version](python/fly_connectome_01_data_access.ipynb)**

**Core Tutorial:**
- Understanding file formats (Feather vs Parquet)
- Loading metadata and exploring hierarchical classifications
- Working with Google Cloud Storage and local files
- Filtering and characterizing neurons by connectivity patterns
- Example: Mushroom body calyx neurons

**Extensions:**
- Your Turn: Apply analysis to different datasets (maleCNS, FAFB)
- Compare biological vs technical differences between datasets

### Tutorial 02: Neuron Morphology (30 minutes)
**[R version](R/02_neuron_morphology.Rmd) | [Python version](python/fly_connectome_02_neuron_morphology.ipynb)**

**Core Tutorial:**
- Loading and visualizing 3D neuron skeletons (.swc files)
- Reading neuropil meshes for spatial context
- Co-plotting neurons across datasets
- NBLAST morphological similarity analysis
- Hierarchical clustering of neuron morphologies

**Extensions:**
- Your Turn: Analyze different neuron populations
- Extension 1: Template brain transformations (MANC → JRCVNC2018F → BANC)
- Extension 2: Axon-dendrite splits using flow centrality
  - Compartment labels from graph-theoretic algorithm ([Schneider-Mizell et al. 2016](https://elifesciences.org/articles/12059))
  - Synapse classification by compartment
  - Available for FAFB, MANC, maleCNS (not yet BANC)

### Tutorial 03: Connectivity Analyses (40 minutes)
**[R version](R/03_connectivity_analyses.Rmd) | [Python version](python/fly_connectome_03_connectivity_analyses.ipynb)**

**Core Tutorial:**
- Loading and querying edgelists (connectivity matrices)
- Neurotransmitter prediction and signed connectivity
- Basic network statistics (degree distributions, weight correlations)
- Connectivity matrices and heatmaps
- Sensory outputs and effector inputs analysis

**Extensions:**
- Your Turn: Analyze different brain regions
- Connectivity-based clustering (cosine similarity, UMAP)
- Cluster composition and network visualization
- Morphological analysis of connectivity clusters

### Tutorial 04: Indirect Connectivity and Influence (20 minutes)
**[R version](R/04_indirect_connectivity.Rmd) | [Python version](python/fly_connectome_04_indirect_connectivity.ipynb)**

**Core Tutorial:**
- Understanding influence scores and random walks through connectomes
- Calculating sensory → dopaminergic neuron influence
- Influence heatmaps and UMAP visualization
- Interpreting multi-hop connectivity patterns

**Extensions:**
- Your Turn: Different source/target neuron populations
- Extension 1: Olfactory channel influence on pC1 neurons (BANC vs maleCNS)
- Extension 2: Abdominal neuromere sensory-effector influence patterns

---

## Getting Started

If running in the cloud:
   **INSERT**
   
If running locally:

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

The Google Bucket contains a curation of connectome data by Alexander Bates. The purpose of the curation was to make it easy to work with all major connectome datasets together, e.g. standardising column names and meta data entires. You are welcome to use this data curation in your own work! Just let Alex know!

More generally, if you use these datasets in your work, please cite the original publications:

**BANC:** Bates, A.S., Phelps, J.S., Kim, M., Yang, H.H., Matsliah, A., Ajabi, Z., Perlman, E., et al. (2025). Distributed control circuits across a brain-and-cord connectome. *bioRxiv*, 2025.07.31.667571. https://doi.org/10.1101/2025.07.31.667571

**FAFB:** Schlegel, P., Yin, Y., Bates, A.S., Dorkenwald, S., Eichler, K., Brooks, P., Han, D.S., et al. (2024). Whole-brain annotation and multi-connectome cell typing of Drosophila. *Nature*, 634(8032), 139-152. https://doi.org/10.1038/s41586-024-07686-5

**FAFB:** Dorkenwald, S., Matsliah, A., Sterling, A.R., Schlegel, P., ... Bates, A.S., ... et al. (2024). Neuronal wiring diagram of an adult brain. *Nature*, 634(8032), 124-138. https://doi.org/10.1038/s41586-024-07686-5

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

<p align="center">
  <img src="inst/images/flywire_sterling_gallery_dm4.png" alt="FlyWire visualization" width="45%">
</p>
