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
- [Data Organisation](#data-organisation) - Google Storage Bucket structure and file types
- [Tutorial Path](#tutorial-path) - What you'll learn (2 hours)
- [Getting Started](#getting-started) - Installation and first steps
- [Citation](#citation) - How to cite the datasets

---

<p align="center">
  <img src="inst/images/banner.png" alt="Fly connectome datasets" width="100%">
</p>

## Connectome Datasets

We focus primarily on two FlyWire datasets—**BANC** and **FAFB**—while also providing access to MANC, Hemibrain, and Male CNS. All datasets have been harmonized to use the unified metadata schema we used in the **BANC** project, enabling cross-dataset comparisons. Possible metadata entries given here: [data/meta_data_entries](data/meta_data_entries.csv). 

**Importantly**, You can see renderings of neuronal meshes from the BANC, FAFB, MANC and HemiBrain datasets in neuroglancer [here](https://ngl.banc.community/view).

<p align="center">
  <img src="inst/images/banc.png" alt="BANC connectome" width="40%">
</p>

### BANC (Brain and Nerve Cord)
**Primary dataset for this tutorial**

The first synapse-resolution connectome that spanning the brain and ventral nerve cord. Contains ~114,000 neurons with ~108 million synaptic connections. A female fly. Missing the first optic relay, the lamina, and the retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=banc) | [Neuroglancer for version 626](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B4e-9%2C%22m%22%5D%2C%22y%22:%5B4e-9%2C%22m%22%5D%2C%22z%22:%5B4.5e-8%2C%22m%22%5D%7D%2C%22position%22:%5B120011.1796875%2C30963.720703125%2C3154.5%5D%2C%22crossSectionScale%22:1.5696123052244317%2C%22projectionOrientation%22:%5B-0.0043923519551754%2C0.9927433729171753%2C-0.11858028173446655%2C0.01949530653655529%5D%2C%22projectionScale%22:501856.617474674%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22precomputed://gs://seunglab_lee_fly_cns_001_alignment/aligned/v0%22%2C%22tab%22:%22source%22%2C%22shader%22:%22#uicontrol%20float%20black%20slider%28min=0%2C%20max=1%2C%20default=0.0%29%5Cn#uicontrol%20float%20white%20slider%28min=0%2C%20max=1%2C%20default=1.0%29%5Cnfloat%20rescale%28float%20value%29%20%7B%5Cn%20%20return%20%28value%20-%20black%29%20/%20%28white%20-%20black%29%3B%5Cn%7D%5Cnvoid%20main%28%29%20%7B%5Cn%20%20float%20val%20=%20toNormalized%28getDataValue%28%29%29%3B%5Cn%20%20if%20%28val%20%3C%20black%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%280%2C0%2C0%29%29%3B%5Cn%20%20%7D%20else%20if%20%28val%20%3E%20white%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%281.0%2C%201.0%2C%201.0%29%29%3B%5Cn%20%20%7D%20else%20%7B%5Cn%20%20%20%20emitGrayscale%28rescale%28val%29%29%3B%5Cn%20%20%7D%5Cn%7D%5Cn%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22graphene://middleauth+https://cave.fanc-fly.com/segmentation/table/wclee_fly_cns_001/%22%2C%22tab%22:%22graph%22%2C%22segments%22:%5B%5D%2C%22timestamp%22:1753085460000%2C%22timestampOwner%22:%5B%22BANC%20m626%22%5D%2C%22name%22:%22BANC%20m626%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://lee-lab_brain-and-nerve-cord-fly-connectome/region_outlines/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22rendering%22%2C%22selectedAlpha%22:0%2C%22meshSilhouetteRendering%22:2%2C%22segments%22:%5B%221%22%5D%2C%22name%22:%22region_outlines%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22BANC%20m626%22%7D%2C%22layout%22:%22xy-3d%22%7D) | [Neuroglancer for version 746](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B4e-9%2C%22m%22%5D%2C%22y%22:%5B4e-9%2C%22m%22%5D%2C%22z%22:%5B4.5e-8%2C%22m%22%5D%7D%2C%22position%22:%5B120011.1796875%2C30963.720703125%2C3154.5%5D%2C%22crossSectionScale%22:1.5696123052244317%2C%22projectionOrientation%22:%5B-0.0043923519551754%2C0.9927433729171753%2C-0.11858028173446655%2C0.01949530653655529%5D%2C%22projectionScale%22:501856.617474674%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22precomputed://gs://seunglab_lee_fly_cns_001_alignment/aligned/v0%22%2C%22tab%22:%22source%22%2C%22shader%22:%22#uicontrol%20float%20black%20slider%28min=0%2C%20max=1%2C%20default=0.0%29%5Cn#uicontrol%20float%20white%20slider%28min=0%2C%20max=1%2C%20default=1.0%29%5Cnfloat%20rescale%28float%20value%29%20%7B%5Cn%20%20return%20%28value%20-%20black%29%20/%20%28white%20-%20black%29%3B%5Cn%7D%5Cnvoid%20main%28%29%20%7B%5Cn%20%20float%20val%20=%20toNormalized%28getDataValue%28%29%29%3B%5Cn%20%20if%20%28val%20%3C%20black%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%280%2C0%2C0%29%29%3B%5Cn%20%20%7D%20else%20if%20%28val%20%3E%20white%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%281.0%2C%201.0%2C%201.0%29%29%3B%5Cn%20%20%7D%20else%20%7B%5Cn%20%20%20%20emitGrayscale%28rescale%28val%29%29%3B%5Cn%20%20%7D%5Cn%7D%5Cn%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%5B%7B%22url%22:%22graphene://middleauth+https://cave.fanc-fly.com/segmentation/table/wclee_fly_cns_001%22%2C%22subsources%22:%7B%22default%22:true%2C%22graph%22:true%2C%22bounds%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%7B%22url%22:%22precomputed://middleauth+https://cave.fanc-fly.com/skeletoncache/api/v1/brain_and_nerve_cord/precomputed/skeleton%22%2C%22enableDefaultSubsources%22:false%7D%5D%2C%22tab%22:%22graph%22%2C%22segments%22:%5B%22%21720575941581870457%22%2C%22%21720575941562217517%22%2C%22%21720575941521454003%22%2C%22%21720575941642438776%22%5D%2C%22timestamp%22:1763539800000%2C%22timestampOwner%22:%5B%22BANC%20m626%22%5D%2C%22name%22:%22BANC%20m746%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://lee-lab_brain-and-nerve-cord-fly-connectome/region_outlines/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22rendering%22%2C%22selectedAlpha%22:0%2C%22meshSilhouetteRendering%22:2%2C%22segments%22:%5B%221%22%5D%2C%22name%22:%22region_outlines%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22BANC%20m626%22%7D%2C%22layout%22:%22xy-3d%22%7D)
- **Publication:** [Bates et al. (2025)](https://pubmed.ncbi.nlm.nih.gov/40766407/) bioRxiv
- **Documentation:** [data/dataset_documentation/banc_data.md](data/dataset_documentation/banc_data.md)
- **BANC space mesh location:** [neuron_meshes](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/neuron_meshes)

<p align="center">
  <img src="inst/images/malecns.png" alt="Male CNS connectome" width="40%">
</p>

### Male CNS (Central Nervous System)
Complete male CNS connectome with 166,691 neurons spanning the brain and ventral nerve cord. Includes fruitless and doublesex expression data for studying sex-specific circuits. A male fly. Missing retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=mcns) | [neuPrint](https://neuprint.janelia.org/?dataset=male-cns:v0.9) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B0.000004096%2C%22m%22%5D%2C%22y%22:%5B0.000004096%2C%22m%22%5D%2C%22z%22:%5B0.00000512%2C%22m%22%5D%7D%2C%22position%22:%5B123.39667510986328%2C37.636898040771484%2C35.086002349853516%5D%2C%22crossSectionScale%22:0.0019169223883004237%2C%22projectionOrientation%22:%5B0.047697652131319046%2C0.02295735850930214%2C0.010306727141141891%2C0.9985447525978088%5D%2C%22projectionScale%22:100.04291034597205%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22gs://flyem-male-cns/em/em-clahe-jpeg/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%7B%22url%22:%22gs://flyem-male-cns/v0.9/segmentation/clio/%7Cneuroglancer-precomputed:%22%2C%22subsources%22:%7B%22default%22:true%2C%22bounds%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%22tab%22:%22segments%22%2C%22segments%22:%5B%5D%2C%22name%22:%22MaleCNS_v0.9%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%7B%22url%22:%22gs://flyem-male-cns/rois/fullbrain-major-shells/%7Cneuroglancer-precomputed:%22%2C%22subsources%22:%7B%22default%22:true%2C%22properties%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%22tab%22:%22rendering%22%2C%22selectedAlpha%22:0%2C%22saturation%22:0%2C%22hoverHighlight%22:false%2C%22meshSilhouetteRendering%22:7%2C%22segments%22:%5B%221%22%2C%222%22%2C%223%22%5D%2C%22segmentDefaultColor%22:%22#ffffff%22%2C%22name%22:%22fullbrain-major-shells%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22MaleCNS_v0.9%22%7D%2C%22layout%22:%22xy-3d%22%7D)
- **Publication:** [Berg et al. (2025)](https://www.biorxiv.org/content/10.1101/2025.10.09.680999v1) bioRxiv
- **Documentation:** [data/dataset_documentation/malecns_data.md](data/dataset_documentation/malecns_data.md)
- **BANC space mesh location:** Not yet available

<p align="center">
  <img src="inst/images/fafb.png" alt="FAFB connectome" width="40%">
</p>

### FAFB (Full Adult Fly Brain)
Complete adult female fly brain connectome via the FlyWire project. Contains ~139,000 neurons spanning all brain regions, including detailed annotations of 8,453 cell types. A female fly. Missing ventral nerve cord and retina.

- **Explore:** [Codex](https://codex.flywire.ai/?dataset=fafb) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B4e-9%2C%22m%22%5D%2C%22y%22:%5B4e-9%2C%22m%22%5D%2C%22z%22:%5B4e-8%2C%22m%22%5D%7D%2C%22position%22:%5B132596.984375%2C53845.46875%2C3380.5%5D%2C%22crossSectionScale%22:13.628079869267063%2C%22projectionScale%22:255985.26295878578%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22precomputed://https://bossdb-open-data.s3.amazonaws.com/flywire/fafbv14%22%2C%22tab%22:%22rendering%22%2C%22shader%22:%22#uicontrol%20float%20black%20slider%28min=0%2C%20max=1%2C%20default=0.0%29%5Cn#uicontrol%20float%20white%20slider%28min=0%2C%20max=1%2C%20default=1.0%29%5Cnfloat%20rescale%28float%20value%29%20%7B%5Cn%20%20return%20%28value%20-%20black%29%20/%20%28white%20-%20black%29%3B%5Cn%7D%5Cnvoid%20main%28%29%20%7B%5Cn%20%20float%20val%20=%20toNormalized%28getDataValue%28%29%29%3B%5Cn%20%20if%20%28val%20%3C%20black%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%280%2C0%2C0%29%29%3B%5Cn%20%20%7D%20else%20if%20%28val%20%3E%20white%29%20%7B%5Cn%20%20%20%20emitRGB%28vec3%281.0%2C%201.0%2C%201.0%29%29%3B%5Cn%20%20%7D%20else%20%7B%5Cn%20%20%20%20emitGrayscale%28rescale%28val%29%29%3B%5Cn%20%20%7D%5Cn%7D%5Cn%22%2C%22shaderControls%22:%7B%22white%22:0.82%7D%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%7B%22url%22:%22precomputed://gs://flywire_v141_m783%22%2C%22subsources%22:%7B%22default%22:true%2C%22bounds%22:true%2C%22mesh%22:true%7D%2C%22enableDefaultSubsources%22:false%7D%2C%22tab%22:%22segments%22%2C%22segments%22:%5B%5D%2C%22name%22:%22flywire_m783%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%5B%22precomputed://gs://flywire_neuropil_meshes/whole_neuropil/brain_mesh_v3%22%2C%22precomputed://middleauth+https://global.daf-apis.com/nglstate/api/v1/property/4691248662183936%22%5D%2C%22tab%22:%22segments%22%2C%22objectAlpha%22:0.5%2C%22meshSilhouetteRendering%22:2%2C%22segments%22:%5B%221%22%5D%2C%22segmentDefaultColor%22:%22#ffffff%22%2C%22name%22:%22Brain%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%5B%22precomputed://gs://flywire_neuropil_meshes/neuropils/neuropil_mesh_v141_v6%22%2C%22precomputed://middleauth+https://global.daf-apis.com/nglstate/api/v1/property/6127113405988864%22%5D%2C%22tab%22:%22segments%22%2C%22selectedAlpha%22:0.83%2C%22objectAlpha%22:0.5%2C%22meshSilhouetteRendering%22:1%2C%22segments%22:%5B%5D%2C%22name%22:%22Neuropils%22%7D%5D%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22flywire_m783%22%7D%2C%22layout%22:%22xy-3d%22%7D)
- **Publication:** [Dorkenwald et al. (2024)](https://www.nature.com/articles/s41586-024-07686-5) Nature; [Schlegel et al. (2024)](https://www.nature.com/articles/s41586-024-07686-5) Nature
- **Documentation:** [data/dataset_documentation/fafb_data.md](data/dataset_documentation/fafb_data.md)
- **BANC space mesh location:** [fafb_783_meshes](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/imported_meshes/fafb_783_meshes_elastix_tpsreg_240721)

<p align="center">
  <img src="inst/images/manc.png" alt="MANC connectome" width="25%">
</p>

### MANC (Male Adult Nerve Cord)
First complete nerve cord connectome with ~23,000 neurons. A male fly. Missing brain.

- **Explore:** [neuPrint](https://neuprint.janelia.org/?dataset=manc) | [Codex](https://codex.flywire.ai/?dataset=manc) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B8e-9%2C%22m%22%5D%2C%22y%22:%5B8e-9%2C%22m%22%5D%2C%22z%22:%5B8e-9%2C%22m%22%5D%7D%2C%22position%22:%5B23056.5%2C29733.5%2C41138.5%5D%2C%22crossSectionScale%22:1%2C%22projectionScale%22:131072%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22gs://flyem-vnc-2-26-213dba213ef26e094c16c860ae7f4be0/v3_emdata_clahe_xy/jpeg/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://manc-seg-v1p2/manc-seg-v1.2/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22segments%22:%5B%5D%2C%22name%22:%22MANC%20v1.2.3%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://flyem-vnc-roi-d5f392696f7a48e27f49fa1a9db5ee3b/roi-202208/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22selectedAlpha%22:0%2C%22segments%22:%5B%5D%2C%22name%22:%22neuropils%22%7D%5D%2C%22showAxisLines%22:false%2C%22showDefaultAnnotations%22:false%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22MANC%20v1.2.3%22%7D%2C%22layout%22:%22xy-3d%22%2C%22selection%22:%7B%22layers%22:%7B%22seg%22:%7B%22annotationId%22:%22data-bounds%22%2C%22annotationSource%22:0%2C%22annotationSubsource%22:%22bounds%22%7D%7D%7D%7D)
- **Publication:** [Takemura et al. (2024)](https://elifesciences.org/reviewed-preprints/97769) eLife
- **Documentation:** [data/dataset_documentation/manc_data.md](data/dataset_documentation/manc_data.md)
- **BANC space mesh location:** [manc_v1.2.1_meshes](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/imported_meshes/manc_v1.2.1_meshes_elastix_tpsreg_240721)

<p align="center">
  <img src="inst/images/hemibrain.png" alt="Hemibrain connectome" width="40%">
</p>

### Hemibrain
Dense reconstruction of approximately half the central brain (~25,000 neurons). Includes mushroom body learning circuits and central complex navigation circuits. A female fly. Missing ventral nerve cord and approximately half of the brain and optic lobes.

- **Explore:** [neuPrint](https://neuprint.janelia.org/?dataset=hemibrain%3Av1.2.1&qt=findneurons) | [Neuroglancer](https://spelunker.cave-explorer.org/#!%7B%22dimensions%22:%7B%22x%22:%5B8e-9%2C%22m%22%5D%2C%22y%22:%5B8e-9%2C%22m%22%5D%2C%22z%22:%5B8e-9%2C%22m%22%5D%7D%2C%22position%22:%5B30005.095703125%2C20073.41015625%2C12157.427734375%5D%2C%22crossSectionScale%22:9.214678755682833%2C%22projectionOrientation%22:%5B-0.039887912571430206%2C0.3780467212200165%2C0.1364591270685196%2C0.9148051738739014%5D%2C%22projectionScale%22:441638.40352250263%2C%22layers%22:%5B%7B%22type%22:%22image%22%2C%22source%22:%22gs://neuroglancer-janelia-flyem-hemibrain/emdata/clahe_yz/jpeg/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22name%22:%22EM%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://neuroglancer-janelia-flyem-hemibrain/v1.2/segmentation/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22source%22%2C%22segments%22:%5B%5D%2C%22name%22:%22Hemibrain%22%7D%2C%7B%22type%22:%22segmentation%22%2C%22source%22:%22gs://neuroglancer-janelia-flyem-hemibrain/v1.2/rois/%7Cneuroglancer-precomputed:%22%2C%22tab%22:%22segments%22%2C%22selectedAlpha%22:0%2C%22segments%22:%5B%5D%2C%22name%22:%22rois%22%2C%22visible%22:false%7D%5D%2C%22showAxisLines%22:false%2C%22showDefaultAnnotations%22:false%2C%22showSlices%22:false%2C%22selectedLayer%22:%7B%22visible%22:true%2C%22layer%22:%22Hemibrain%22%7D%2C%22layout%22:%22xy-3d%22%2C%22selection%22:%7B%7D%7D)
- **Publication:** [Scheffer et al. (2020)](https://elifesciences.org/articles/57443) eLife
- **Documentation:** [data/dataset_documentation/hemibrain_data.md](data/dataset_documentation/hemibrain_data.md)
- **BANC space mesh location:** [hemibrain_v1.2.1_meshes](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/imported_meshes/hemibrain_v1.2.1_meshes_elastix_tpsreg_240721)

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
-**[neuprint-python](https://connectome-neuprint.github.io/neuprint-python/docs/index.html)** - Data access to Janelian connectome projects, e.g. HemiBrain, MANC and maleCNS.
  
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

All processed data is hosted on Google Cloud Storage: **[Access Data](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data)**

To download and work with this data locally, you will need `gsutil`, in terminal you can install and configure with:

```bash
# 1) Install Google Cloud CLI (includes gsutil) – macOS / Linux
#    For Windows, use the official Google Cloud CLI installer instead.
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-$(uname -s | tr '[:upper:]' '[:lower:]')-x86_64.tar.gz
tar -xf google-cloud-cli-*.tar.gz
./google-cloud-sdk/install.sh

# 2) Restart your terminal, then verify install
gcloud --version       # should print a version
gsutil version         # should also print a version

# 3) Log in with your Google account and set up config
gcloud init            # follows browser flow; pick or create a project

# (Optional but often helpful: refresh auth explicitly)
gcloud auth login
gcloud auth application-default login

# 4) Test access to the bucket
gsutil ls gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/

# Outcomes:
#  - If you see object names: access OK.
#  - If you get 403 AccessDenied: you need permissions on the bucket/project.
#  - If you get NotFound: bucket name or visibility is wrong.
```

You can browse and download files directly from the browser, or use command-line tools:
```bash
# List available datasets
gsutil ls gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/

# Download a specific file
gsutil cp gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/banc_888_meta.feather .

# Download an entire dataset folder
gsutil -m cp -r gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888 .
```

### Example Structure (BANC)
```
compiled_data/banc_888/
├── banc_888_meta.feather                  # Neuron annotations
├── banc_888_edgelist_simple_v3.feather    # Neuron-to-neuron connectivity (latest)
├── banc_888_edgelist_simple_v2.feather    # Older neuron-to-neuron connectivity
├── banc_888_edgelist_split.feather        # Compartment-to-compartment connectivity
├── banc_888_synapses_v2_enriched.parquet  # Individual synapse data with neuropil/region/NT
└── banc_888_metrics.feather               # Cable length, volume, synapse counts per neuron
```

BANC neuron skeletons and region meshes are stored at the bucket root rather than inside
`compiled_data/`:

```
gs://lee-lab_brain-and-nerve-cord-fly-connectome/
├── neuron_skeletons/swcs-from-pcg-skel/   # Per-neuron SWC files in BANC space
├── neuron_skeletons.zip                    # Zipped copy of the above
├── neuron_meshes/                          # BANC neuron meshes (Neuroglancer precomputed)
└── region_outlines/                        # BANC region meshes (Neuroglancer precomputed)
```

The other datasets (FAFB, MANC, Hemibrain, maleCNS) keep their SWC and OBJ assets inside
their `compiled_data/{dataset}_{version}/` folder. See the per-dataset documentation files
for the exact contents.

### File Types
- **`*_meta.feather`** - Metadata for each neuron: cell type, brain region, neurotransmitter, developmental lineage ([schema details](data/meta_data_entries.csv))
- **`*_simple_edgelist.feather`** (or `*_edgelist_simple_v3.feather` for BANC) - Connectivity matrix showing which neurons connect to which, with connection strengths
- **`*_split_edgelist.feather`** (or `*_edgelist_split.feather` for BANC) - Compartment-to-compartment connectivity (axon → dendrite, etc.)
- **`*_synapses.{feather,parquet}`** - Coordinates and properties of individual synapses
- **`*_swc/` directories** - 3D skeleton reconstructions in SWC format (one file per neuron)

See individual dataset documentation files in [`data/dataset_documentation/`](data/dataset_documentation/) for detailed column descriptions.

### Subsetting by Neural System / Region

The previous release shipped pre-computed subset folders (`mushroom_body/`, `antennal_lobe/`,
`central_complex/`, `optic/`, `suboesophageal_zone/`, `front_leg/`, `abdominal_neuromere/`)
inside each dataset directory. **These subset folders no longer exist** — the tutorials now
build the equivalent subsets in code, mirroring the original logic from
[`bancpipeline/banc/share/banc-sjcabs.R`](https://github.com/flyconnectome/bancpipeline).

The `subset_by_region()` helper in `R/setup/functions.R` and `python/utils.py`
applies the same filters that produced the old folders:

- **Antennal lobe / central complex / mushroom body** → regex match against the metadata
  hierarchy (`super_class`, `cell_class`, `cell_sub_class`, `cell_type`).
- **Optic lobe / suboesophageal zone / front leg / abdominal neuromere** → filter the
  synapse table by `neuropil` regex with a ≥100 synapse threshold per neuron.

The biology each subset targets is unchanged:

- **Antennal Lobe**: Primary olfactory processing centre receiving input from olfactory receptor neurons and projecting to higher brain regions via projection neurons. Critical for odour discrimination and learning.

- **Central Complex**: Navigation circuits for spatial orientation, motor control, and goal-directed behaviour. Contains ring neurons encoding heading direction and columnar neurons for path integration.

- **Mushroom Body**: Associative learning and memory circuits. Kenyon cells integrate sensory information and form associations with dopaminergic reinforcement signals.

- **Optic Lobe**: Visual processing through lamina (motion detection), medulla (colour and contrast), and lobula (object recognition). Includes both retinotopic local circuits and wide-field integration neurons.

- **Suboesophageal Zone**: Lower brain region controlling feeding, grooming, and processing gustatory/tactile information from mouthparts and antennae.

- **Front Leg / Abdominal Neuromere**: Motor control circuits coordinating limb movements and postural adjustments through local sensory feedback and descending command signals.

---

## Detailed Data Inventory

### BANC (Brain and Nerve Cord)
**[Browse Files](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888)** | `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/`

- `banc_888_meta.feather` (~48 MB) - Metadata (188,153 neurons)
- `banc_888_edgelist_simple_v3.feather` (~336 MB) - Neuron-to-neuron connectivity (latest)
- `banc_888_edgelist_simple_v2.feather` (~285 MB) - Older neuron-to-neuron connectivity
- `banc_888_edgelist_split.feather` (~321 MB) - Compartment-to-compartment connectivity
- `banc_888_synapses_v2_enriched.parquet` (~9.6 GB) - Individual synapses (neuropil/region/NT enriched)
- `banc_888_metrics.feather` (~7.5 MB) - Per-neuron cable length, volume, synapse counts

Skeletons and region meshes for BANC are at the bucket root:

- `gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons/swcs-from-pcg-skel/` - Per-neuron SWC files (BANC space)
- `gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons.zip` - Zipped SWC bundle (~206 MB)
- `gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_meshes/` - BANC neuron meshes (Neuroglancer precomputed)
- `gs://lee-lab_brain-and-nerve-cord-fly-connectome/region_outlines/` - BANC region meshes (Neuroglancer precomputed)

### FAFB (Full Adult Fly Brain)
**[Browse Files](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/fafb_783)** | `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/fafb_783/`

- `fafb_783_meta.feather` (~10 MB) - Metadata
- `fafb_783_simple_edgelist.feather` (~289 MB) - Neuron-to-neuron connectivity
- `fafb_783_split_edgelist.feather` (~523 MB) - Compartment connectivity
- `fafb_783_synapses.feather` (~4.0 GB) / `fafb_783_synapses.parquet` (~1.7 GB) - Individual synapses
- `fafb_783_cell_dcv_detection.feather` (~9.7 GB) - Cellular dense-core-vesicle detections
- `fafb_783_soma_dcv_detection.feather` (~3.7 GB) - Somatic DCV detections
- `fafb_dcv_scores_metadata_ya_3_5_26.csv` (~15 MB) - DCV detection metadata
- `fafb_fafb_space_swc/` - Skeletons in native FAFB space
- `fafb_banc_space_swc/` - Skeletons in BANC space
- `obj/` - FAFB volume and per-neuropil OBJ meshes

### MANC (Male Adult Nerve Cord)
**[Browse Files](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/manc_121)** | `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/manc_121/`

- `manc_121_meta.feather` (~1.4 MB) - Metadata
- `manc_121_simple_edgelist.feather` (~83 MB) - Neuron-to-neuron connectivity
- `manc_121_split_edgelist.feather` (~321 MB) - Compartment connectivity
- `manc_121_synapses.feather` (~3.6 GB) / `manc_121_synapses.parquet` (~2.4 GB) - Individual synapses
- `manc_manc_space_swc/` - Skeletons in native MANC space
- `manc_banc_space_split_swc/` - Skeletons in BANC space (split by compartment)
- `obj/` - MANC volume and neuropil OBJ meshes

### Hemibrain
**[Browse Files](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/hemibrain_121)** | `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/hemibrain_121/`

- `hemibrain_121_meta.feather` (~1.9 MB) - Metadata
- `hemibrain_121_simple_edgelist.feather` (~88 MB) - Neuron-to-neuron connectivity
- `hemibrain_121_split_edgelist.feather` (~145 MB) - Compartment connectivity
- `hemibrain_121_synapses.feather` (~13 KB summary) / `hemibrain_121_synapses.parquet` (~862 MB)
- `hemibrain_hemibrain_raw_space_swc/` - Skeletons in native Hemibrain space
- `hemibrain_banc_space_swc/` - Skeletons in BANC space
- `obj/`, `neuropils/` - Hemibrain volume and per-glomerulus/neuropil OBJ meshes

### Male CNS
**[Browse Files](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/malecns_09)** | `gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/malecns_09/`

- `malecns_09_meta.feather` (~9.7 MB) - Metadata
- `malecns_09_simple_edgelist.feather` (~3.2 GB) - Neuron-to-neuron connectivity
- `malecns_09_split_edgelist.feather` (~4.6 GB) - Compartment connectivity
- `malecns_09_synapses.parquet` (~7.9 GB) - Individual synapses
- `malecns_malecns_space_swc/` - Skeletons in native maleCNS space
- `malecns_banc_space_swc/` - Skeletons in BANC space
- `obj/` - maleCNS volume and neuropil OBJ meshes
- `JRC2018U/` - JRC2018-Unisex registration assets

### Download Examples
```bash
# Small file - metadata (recommended to start)
gsutil cp gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/banc_888_meta.feather .

# Whole dataset folder (big — check sizes first!)
gsutil -m cp -r gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888 .

# Large file - check size first
gsutil ls -lh gs://lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data/banc_888/banc_888_synapses_v2_enriched.parquet

# BANC skeletons live at the bucket root (not under compiled_data/)
gsutil -m cp -r gs://lee-lab_brain-and-nerve-cord-fly-connectome/neuron_skeletons/swcs-from-pcg-skel ./banc_swc
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

If running locally:

1. **Download data** from the [Google Cloud Storage bucket](https://console.cloud.google.com/storage/browser/lee-lab_brain-and-nerve-cord-fly-connectome/compiled_data) for the dataset(s) you want to work with
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
**Note:** For each python tutorial, there is a paired startup `.sh` file to install its dependencies in `python/runtimes` 
     
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
