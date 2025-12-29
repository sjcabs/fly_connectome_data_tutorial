#!/bin/bash
# fly_connectome_data_tutorial.sh - SJCABS Fly Connectome Data Tutorial
# Master runtime script for Vertex AI Colab - All Tutorials Environment Setup
# This script installs all dependencies needed for all four tutorial notebooks
#
# Note: This script requires git to be available for installing ConnectomeInfluenceCalculator
# from GitHub. Colab environments typically have git pre-installed.

set -e

echo "========================================="
echo "SJCABS Fly Connectome Data Tutorial"
echo "Master Environment Setup"
echo "Installing all Python packages..."
echo "========================================="

# Update pip
echo "Updating pip..."
python3 -m pip install --quiet --upgrade pip

# Install core data science packages
echo "Installing core data science packages..."
# NumPy must be <2.1 for compatibility with numba (used by navis)
# Protobuf must be <5.0 for compatibility with pyarrow/gcsfs
python3 -m pip install --quiet --upgrade \
    "protobuf>=3.20,<5.0" \
    pandas==2.3.3 \
    "numpy>=2.0,<2.1" \
    pyarrow \
    gcsfs

# Install visualization packages
echo "Installing visualization packages..."
python3 -m pip install --quiet --upgrade \
    plotly==5.24.1 \
    kaleido \
    matplotlib \
    seaborn

# Install navis and neuroscience tools
# Using navis[all] to include all optional dependencies
echo "Installing navis and neuroscience tools..."
python3 -m pip install --quiet --upgrade \
    "navis[all]==1.10.0" \
    flybrains \
    trimesh \
    pykdtree \
    ncollpyde \
    caveclient

# Install network analysis and scientific computing tools
echo "Installing network analysis and clustering tools..."
python3 -m pip install --quiet --upgrade \
    networkx \
    scipy \
    scikit-learn \
    umap-learn

# Install ConnectomeInfluenceCalculator from GitHub (for Tutorial 04)
echo "Installing ConnectomeInfluenceCalculator from GitHub..."
python3 -m pip install --quiet --upgrade \
    git+https://github.com/DrugowitschLab/ConnectomeInfluenceCalculator.git || echo "⚠ Influence calculator installation failed, may require manual setup"

# Install Jupyter widgets for interactive plots
echo "Installing Jupyter widgets..."
python3 -m pip install --quiet --upgrade \
    ipywidgets \
    tqdm

# Verify key installations
echo ""
echo "========================================="
echo "Verifying installations..."
echo "========================================="
python3 -c "import navis; print(f'✓ navis {navis.__version__}')" || echo "✗ navis failed"
python3 -c "import pandas as pd; print(f'✓ pandas {pd.__version__}')" || echo "✗ pandas failed"
python3 -c "import numpy as np; print(f'✓ numpy {np.__version__}')" || echo "✗ numpy failed"
python3 -c "import gcsfs; print('✓ gcsfs installed')" || echo "✗ gcsfs failed"
python3 -c "import plotly; print('✓ plotly installed')" || echo "✗ plotly failed"
python3 -c "import trimesh; print('✓ trimesh installed')" || echo "✗ trimesh failed"
python3 -c "import networkx; print('✓ networkx installed')" || echo "✗ networkx failed"
python3 -c "import scipy; print('✓ scipy installed')" || echo "✗ scipy failed"
python3 -c "import sklearn; print('✓ scikit-learn installed')" || echo "✗ scikit-learn failed"
python3 -c "import umap; print('✓ umap installed')" || echo "✗ umap failed"

echo ""
echo "========================================="
echo "Environment setup complete!"
echo ""
echo "All dependencies installed for:"
echo "  • Tutorial 01: Data Access"
echo "  • Tutorial 02: Neuron Morphology"
echo "  • Tutorial 03: Connectivity Analyses"
echo "  • Tutorial 04: Indirect Connectivity"
echo ""
echo "Ready for SJCABS Fly Connectome Tutorials!"
echo "========================================="
