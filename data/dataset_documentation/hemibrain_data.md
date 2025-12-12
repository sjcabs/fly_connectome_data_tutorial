## Overview

This location contains data for the Full Adult Fly Brain (manc) project.

We are here:

```
sjcabs_data/
├── hemibrain/          
│   ├── hemibrain_121_meta.feather     
│   ├── hemibrain_121_edgelist_simple.feather     
│   ├── hemibrain_121_edgelist.feather 
│   ├── hemibrain_121_synapses.feather 
│   ├── hemibrain_121_skeletons_in_banc_space.zip  
│   ├── hemibrain_121_skeletons_in_hemibrain_space.zip
│   ├── antennal_lobe/ * data subset for olfactory circuits of the anennal lobe
│   ├── central_complex/ * data subset for navigation circuits of the central complex
│   └── mushroom_body/ * data subset for associative memory circuits of the mushroom body
└── ...
```

For each dataset, feather file contain:
- `meta` - Neuron metadata and annotations (in manc, subsetted to only "proofread" neurons)
- `edgelist_simple` - Neuron-to-neuron connections
- `edgelist` - Compartment-to-compartment connections  
- `synapses` - Detailed synapse information (in manc, subsetted to presynaptic links with cleft_score > 50 on proofead neurons)
- `skeletons` - manc high-resolution skeletons in SWC format

meta - each row is a unique neuron
========================================================================================

**hemibrain_121_id**   :   the neuron ID for the source (i.e. upstream, presynaptic) neuron. For manc this is a bodyid for version 121 (published version).

**cell_type**     :   the name of the matched neuron from manc (if brain neuron or DN) or MANC (if VNC neuron or AN), hierarchical below cell_sub_class. Exceptions exist where names were further split to define single cell types

**side**    :   the side of the CNS; "L" = left, "R" = right

**hemilineage** :   the hemilineage to which the neuron is thought to belong (ito_lee_hemilineage, hartenstein_hemilineage are the same, but represent two different brain naming schemes)

**nerve**   :   entry or exit nerve

**region**  :   region of the CNS; all neurons with arbours in the optic lobe are optic_lobe, all neurons that fully transit the neck connective between the brain and VNC are neck_connective

**flow** : from the perspective of the whole CNS, whether the neuron is afferent, efferent, or intrinsic

**super_class** : coarse division, hierarchical below flow

**cell_class** : hierarchical below super_class

**cell_sub_class** : hierarchical below cell_class

**neurotransmitter_predicted**     :   the most commonly predicted (modal) transmitter, or the most commonly predicted when weighted by pre-synapse confidence score (conf_nt)


synapses - each row is a unique synaptic connection
========================================================================================

**pre**     :   the neuron ID for the source (i.e. upstream, presynaptic) neuron. For manc this is a root_id for BANC, root_id for FAFB, cell_id for FANC and bodyid for MANC and Hemibrain.

**post**    :   the neuron ID for the target (i.e. downstrea, pesynaptic) neuron. For manc this is a root_id for BANC, root_id for FAFB, cell_id for FANC and bodyid for MANC and Hemibrain.

**x,y,z**   :   the  position of the connection in nanometer space for the given brain. For the franenbrain, with will be MANC or manc depending on the neuron.

**prepost** :   whether the link is pre- (0, i.e. output synapse) or post (1, i.e. input) relative to post_id. In the presynapses table, all prepost==0, in the postsynaptic table, all prepost==1.

**syn_top_nt**  :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction. Only valid for manc.

**syn_top_nt_p**    :   the confidence score assicated with syn_top_nt. Only valid for manc.

**gaba**    :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction score for gaba. Only valid for manc.

**glutamate**    :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction score for glutamate. Only valid for manc.

**acetylcholine**    :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction score for acetylcholine. Only valid for manc.

**octopamine**    :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction score for octopamine. Only valid for manc.

**serotonin**    :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction score for serotonin. Only valid for manc.

**dopamine**    :   the Eckstein and Bates et al. 2024 synapse-level neurotransmitter prediction score for dopamine. Only valid for manc.

**scores**  :   the  Buhmamnn prediction score for the synapse, unsure of definition. Only valid for manc.

**cleft_scores**    :   a score that indicates how discriminable the synaptic cleft is. More useful than `size` or `scores`.

**size**    :   the number of voxels (?) in the detected synapse.

**id**  :   the index for the Buhmann synapse in the original .sql table.

**connector_id**  :   a unique identifier for the presynapse to which this link is associated.

**status**  :   whether the synaptic link seems good, or whether it is suspicious because it falls outside the neuropil, is on a non-synaptic cable, etc.

**strahler_order**  :   the Strahler order of the branch to which this synapse is attached

**label**   :   the compartment to which this synapse is attached, can be axon, dendrite, primary dendrite, primary neurite, unknown, or soma.

**neuropil** :   the neuropil volume inside of which this synaptic link can be found. If inside multiple volumes, they appear separated by a comma. 


edgelist_simple - each row is a unique neuron-neuron connection
========================================================================================

**pre**     :   the neuron ID for the source (i.e. upstream, presynaptic) neuron. For manc this is a root_id for BANC, root_id for FAFB, cell_id for FANC and bodyid for MANC and Hemibrain.

**post**    :   the neuron ID for the target (i.e. downstrea, pesynaptic) neuron. For manc this is a root_id for BANC, root_id for FAFB, cell_id for FANC and bodyid for MANC and Hemibrain.

**count**   :   the number of synaptic links that connect pre to post. For banc a cleft_score threshold of 50 has been applied.

**norm**    :   the normalised weight of a connection, this is count/post_count, where post_count are the total number of inputs to the target neuron (post).

**total_input** :   the total number of inputs to the target neuron (post).


edgelist - each row is a unique compartment-compartment connection
========================================================================================
***NOTE*** *each 'compartment' on each row is an axon/dendrite/primary neurite/primary dendrite/unknown cable for a neuron*

**pre**     :   the neuron ID for the source (i.e. upstream, presynaptic) neuron. For manc this is a root_id for BANC, root_id for FAFB, cell_id for FANC and bodyid for MANC and Hemibrain.

**post**    :   the neuron ID for the target (i.e. downstrea, pesynaptic) neuron. For manc this is a root_id for BANC, root_id for FAFB, cell_id for FANC and bodyid for MANC and Hemibrain.

**pre_count**  :   the total number of oututs from the target neuron (post) NOT the source neuron (pre). *I understand this is a little confusing, and will seek to change the column names to use pre/post for synapses and sourcd/target for neurons in the future.*

**post_count** :   the total number of inputs to the target neuron (post).

**pre_label**  :   the compartment of the presynaptic neuron (source), can be axon, dendrite, primary dendrite, primary neurite, unknown, soma.

**post_label**  :   the compartment of the postsynaptic neuron (target), can be axon, dendrite, primary dendrite, primary neurite, unknown, soma.

**pre_label_count**  :   the total number of oututs from the specified target neuron compartment (post+post_label) NOT the specified target neuron compartment (post+post_label). *I understand this is a little confusing, and will seek to change the column names to use pre/post for synapses and sourcd/target for neurons in the future.*

**post_label_count** :   the total number of inputs to the specified target neuron compartment (post+post_label).

**count**   :   the number of synaptic links that connect pre+pre_label to post+post_label. For manc a cleft_score threshold of 50 has been applied.

**norm**    :   the normalised weight of a connection, this is count/post_count NOT post_label_count, where post_count is the total number of inputs to the target neuron (post).

**norm_label**  :   the normalised weight of a connection, this is count/post_label_count NOT post_count, where post_label_count is the number of inputs to the target neuron compartment (post_post_label).

*other coumns with information from 'meta' may exist for convenience, with pre/post appended to the name to idicate labelled compartment*


skeletons - each .swc file is a unique neuron, each row in the file is a point in 3D space
========================================================================================

**PointNo**  :   Point identifier. A positive integer.
**Label**  :   Type identifier. The basic set of types used in NeuroMorpho.org SWC files is:
-1  - root
 0  - undefined
 1  - soma
 2  - axon
 3  - dendrite
 4  - apical dendrite
 5-6 - custom
 7 - primary dendrite
 9 - primary neurite
**X,Y,Z**  :   3D point in nm in BANC space (as this covers both brain and nerve cord).
**R**  :   Radius in nanometers (half the cylinder thickness).
**Parent**  :   Parent point identifier. This defines how points are connected to each other. In a tree, multiple points can have the same ParentID. The first point in the file must have a ParentID equal to -1, which represents the root point. Parent samples must be defined before they are being referred to. By counting how many points refer to the a given parent, the number of its children can be computed.

