#!/bin/bash
# indirect_connectivity_post_startup.sh - SJCABS Tutorial 04: Indirect Connectivity
# Runtime script for Vertex AI Colab - Tutorial 04 Environment Setup
#
# Note: This script requires git to be available for installing ConnectomeInfluenceCalculator
# from GitHub. Colab environments typically have git pre-installed.

set -e

echo "========================================="
echo "SJCABS Tutorial 04: Indirect Connectivity"
echo "Installing Python packages..."
echo "========================================="

# Update pip
python3 -m pip install --quiet --upgrade pip

# CRITICAL: Install protobuf FIRST to prevent AttributeError issues
echo "Installing protobuf (compatible version)..."
python3 -m pip install --quiet --force-reinstall "protobuf>=3.20,<5.0"

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

# Install network analysis and clustering tools
python3 -m pip install --quiet --upgrade \
    networkx \
    scipy \
    scikit-learn \
    umap-learn

# Install navis for neuroscience tools
python3 -m pip install --quiet --upgrade \
    navis==1.10.0 \
    trimesh \
    pykdtree \
    ncollpyde

# Install ConnectomeInfluenceCalculator (required for Tutorial 04)
# Install PETSc/SLEPc dependencies first via conda
echo "Installing PETSc/SLEPc dependencies..."
conda install -c conda-forge petsc petsc4py slepc slepc4py -y --quiet 2>&1 | tail -3

echo "Installing ConnectomeInfluenceCalculator from GitHub..."
# Clone to temporary directory
TEMP_IC_DIR="/tmp/ConnectomeInfluenceCalculator_$$"
if git clone --quiet https://github.com/DrugowitschLab/ConnectomeInfluenceCalculator.git "$TEMP_IC_DIR" 2>/dev/null; then
    # Fix pyproject.toml license format (known issue)
    sed -i.bak 's/^license = "BSD-3-Clause"/license = {text = "BSD-3-Clause"}/' "$TEMP_IC_DIR/pyproject.toml" 2>/dev/null || true

    # Install from local directory
    python3 -m pip install --quiet "$TEMP_IC_DIR"

    # Test import
    if python3 -c "from InfluenceCalculator import InfluenceCalculator" 2>/dev/null; then
        echo "✓ ConnectomeInfluenceCalculator installed successfully"
    else
        echo "⚠ InfluenceCalculator import test failed"
    fi

    # Cleanup
    rm -rf "$TEMP_IC_DIR"
else
    echo "⚠ Failed to clone InfluenceCalculator repository"
fi

# Install Jupyter widgets for interactive plots
python3 -m pip install --quiet --upgrade \
    ipywidgets \
    jupyter \
    tqdm

# Verify key installations
echo ""
echo "Verifying installations..."
python3 -c "import pandas as pd; print(f'✓ pandas {pd.__version__}')" || echo "✗ pandas failed"
python3 -c "import gcsfs; print('✓ gcsfs installed')" || echo "✗ gcsfs failed"
python3 -c "import plotly; print('✓ plotly installed')" || echo "✗ plotly failed"
python3 -c "import networkx; print('✓ networkx installed')" || echo "✗ networkx failed"
python3 -c "import umap; print('✓ umap installed')" || echo "✗ umap failed"

echo ""
echo "========================================="
echo "Environment setup complete!"
echo "Ready for Tutorial 04: Indirect Connectivity"
echo "========================================="
