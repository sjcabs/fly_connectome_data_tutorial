#!/bin/bash
# post_startup.sh - SJCABS Connectomics Tutorial Environment Setup
# Runtime template script for Vertex AI Colab

set -e

echo "========================================="
echo "SJCABS Connectomics Tutorial Environment"
echo "Installing Python packages..."
echo "========================================="

# Update pip
python3 -m pip install --quiet --upgrade pip

# Install core data science packages
# NumPy must be <2.1 for compatibility with numba (used by navis)
python3 -m pip install --quiet --upgrade \
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

# Install navis and neuroscience tools
python3 -m pip install --quiet --upgrade \
    navis==1.10.0 \
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

# Verify key installations
echo ""
echo "Verifying installations..."
python3 -c "import navis; print(f'✓ navis {navis.__version__}')" || echo "✗ navis failed"
python3 -c "import pandas as pd; print(f'✓ pandas {pd.__version__}')" || echo "✗ pandas failed"
python3 -c "import gcsfs; print('✓ gcsfs installed')" || echo "✗ gcsfs failed"
python3 -c "import plotly; print('✓ plotly installed')" || echo "✗ plotly failed"

echo ""
echo "========================================="
echo "Environment setup complete!"
echo "Ready for SJCABS tutorials"
echo "========================================="
