#!/bin/bash
# Tutorial 04 Runtime Script - Google Colab Compatible

set -e
set -o pipefail

echo "========================================="
echo "SJCABS Tutorial 04: Indirect Connectivity"
echo "Installing Python packages..."
echo "========================================="

# Update pip
python3 -m pip install --quiet --upgrade pip

# Fix protobuf
echo "Fixing protobuf version..."
python3 -m pip uninstall -y protobuf 2>/dev/null || true
python3 -m pip install --no-cache-dir "protobuf>=3.20,<5.0"
echo "✓ protobuf installed"

# Install core packages
echo "Installing core data science packages..."
python3 -m pip install --quiet \
    pandas==2.3.3 \
    "numpy>=2.0,<2.1" \
    pyarrow \
    gcsfs

# Install visualization
echo "Installing visualization packages..."
python3 -m pip install --quiet \
    plotly==5.24.1 \
    kaleido \
    matplotlib \
    seaborn

# Install analysis tools
echo "Installing analysis packages..."
python3 -m pip install --quiet \
    networkx \
    scipy \
    scikit-learn \
    umap-learn \
    ipywidgets \
    jupyter \
    tqdm \
    joblib

# Install neuroscience tools (needed by utils.py)
echo "Installing neuroscience packages..."
python3 -m pip install --quiet \
    navis==1.10.0 \
    trimesh \
    pykdtree \
    ncollpyde

echo "✓ Core packages installed"

# Install InfluenceCalculator
echo ""
echo "Installing ConnectomeInfluenceCalculator..."

if command -v conda >/dev/null 2>&1; then
    # Local conda
    echo "  Using conda for PETSc/SLEPc"
    conda install -c conda-forge petsc petsc4py slepc slepc4py -y --quiet
else
    # Colab
    echo "  Installing system dependencies for Colab..."
    apt-get update -qq
    apt-get install -y -qq libpetsc-real-dev libslepc-real-dev build-essential gfortran libgomp1
    echo "  ✓ System libraries installed"
    
    echo "  Installing PETSc/SLEPc Python bindings..."
    python3 -m pip install --no-cache-dir petsc4py slepc4py
    echo "  ✓ Python bindings installed"
fi

# Install InfluenceCalculator
echo "  Downloading ConnectomeInfluenceCalculator..."
TEMP_DIR="/tmp/ic_install_$$"
git clone --quiet https://github.com/DrugowitschLab/ConnectomeInfluenceCalculator.git "$TEMP_DIR"

if [ -f "$TEMP_DIR/pyproject.toml" ]; then
    sed -i 's/^license = "BSD-3-Clause"/license = {text = "BSD-3-Clause"}/' "$TEMP_DIR/pyproject.toml"
fi

echo "  Installing ConnectomeInfluenceCalculator..."
python3 -m pip install "$TEMP_DIR"
rm -rf "$TEMP_DIR"

# Verify
echo ""
echo "Verifying InfluenceCalculator installation..."
python3 -c "from InfluenceCalculator import InfluenceCalculator; print('✓ InfluenceCalculator imported successfully')"

echo ""
echo "========================================="
echo "✓ ALL PACKAGES INSTALLED SUCCESSFULLY"
echo "Ready for Tutorial 04: Indirect Connectivity"
echo "========================================="
