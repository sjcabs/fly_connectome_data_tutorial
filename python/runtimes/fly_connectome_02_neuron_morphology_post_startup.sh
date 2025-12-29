#!/bin/bash
# neuron_morphology_post_startup.sh - SJCABS Tutorial 02: Neuron Morphology
# Runtime script for Vertex AI Colab - Tutorial 02 Environment Setup

set -e

echo "========================================="
echo "SJCABS Tutorial 02: Neuron Morphology"
echo "Installing Python packages..."
echo "========================================="

# Update pip
python3 -m pip install --quiet --upgrade pip

# Install core data science packages
# NumPy must be <2.1 for compatibility with numba (used by navis)
# Protobuf must be <5.0 for compatibility with pyarrow/gcsfs
python3 -m pip install --quiet --upgrade \
    "protobuf>=3.20,<5.0" \
    pandas==2.3.3 \
    "numpy>=2.0,<2.1" \
    pyarrow \
    gcsfs

# Install visualization packages
python3 -m pip install --quiet --upgrade \
    plotly==5.24.1 \
    kaleido \
    matplotlib \
    seaborn

# Install navis and neuroscience tools (essential for morphology analysis)
python3 -m pip install --quiet --upgrade \
    navis[all]==1.10.0 \
    flybrains \
    trimesh \
    pykdtree \
    ncollpyde \
    scipy \
    scikit-learn \
    networkx \
    umap-learn

# Install Jupyter widgets for interactive plots
python3 -m pip install --quiet --upgrade \
    ipywidgets \
    tqdm

# Install CAVE tools for Extension 03 (optional - for downloading meshes from BANC)
python3 -m pip install --quiet --upgrade \
    caveclient \
    meshparty

# Verify key installations
echo ""
echo "Verifying installations..."
python3 -c "import navis; print(f'✓ navis {navis.__version__}')" || echo "✗ navis failed"
python3 -c "import flybrains; print('✓ navis-flybrains installed')" || echo "✗ navis-flybrains failed"
python3 -c "import pandas as pd; print(f'✓ pandas {pd.__version__}')" || echo "✗ pandas failed"
python3 -c "import gcsfs; print('✓ gcsfs installed')" || echo "✗ gcsfs failed"
python3 -c "import plotly; print('✓ plotly installed')" || echo "✗ plotly failed"
python3 -c "import trimesh; print('✓ trimesh installed')" || echo "✗ trimesh failed"
python3 -c "import caveclient; print('✓ caveclient installed (Extension 03)')" || echo "✗ caveclient failed"
python3 -c "import meshparty; print('✓ meshparty installed (Extension 03)')" || echo "✗ meshparty failed"

echo ""
echo "========================================="
echo "Environment setup complete!"
echo "Ready for Tutorial 02: Neuron Morphology"
echo "========================================="
