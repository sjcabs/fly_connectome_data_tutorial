#!/bin/bash
# Setup script for Python environment for fly connectome tutorials
# Creates conda environment "sjcabs" with all required dependencies

set -e  # Exit on error

echo "=========================================="
echo "Fly Connectome Tutorial - Python Setup"
echo "=========================================="
echo ""

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo "ERROR: conda not found!"
    echo "Please install Anaconda or Miniconda:"
    echo "  https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

echo "✓ conda found: $(conda --version)"
echo ""

# Environment name
ENV_NAME="sjcabs"

# Check if environment already exists
if conda env list | grep -q "^${ENV_NAME} "; then
    echo "Environment '${ENV_NAME}' already exists."
    read -p "Do you want to remove and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "Exiting without changes."
        exit 0
    fi
fi

echo "Creating conda environment: ${ENV_NAME}"
echo "This may take several minutes..."
echo ""

# Create environment with Python 3.10
conda create -n ${ENV_NAME} python=3.10 -y

# Activate environment
echo ""
echo "Activating environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate ${ENV_NAME}

echo "✓ Environment activated: ${ENV_NAME}"
echo ""

# Install core scientific Python packages
echo "Installing core packages (numpy, pandas, scipy)..."
conda install -c conda-forge numpy pandas scipy -y

# Install data handling packages
echo ""
echo "Installing data handling packages..."
pip install pyarrow gcsfs

# Install visualization packages
echo ""
echo "Installing visualization packages..."
pip install plotly kaleido matplotlib seaborn

# Install Jupyter (optional but useful)
echo ""
echo "Installing Jupyter..."
conda install -c conda-forge jupyter jupyterlab -y

# Install neuroscience packages
echo ""
echo "Installing navis and related packages..."
pip install navis[all]

# Install flybrains for template transformations
echo ""
echo "Installing flybrains..."
pip install flybrains

# Download flybrains transforms (optional - can be done later)
echo ""
read -p "Download flybrains template registrations now? (recommended, ~500MB) (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python -c "import flybrains; flybrains.download_jrc_transforms(); flybrains.download_jrc_vnc_transforms(); flybrains.register_transforms()"
    echo "✓ Flybrains transforms downloaded"
else
    echo "Skipping flybrains download (you can do this later)"
fi

# Install UMAP
echo ""
echo "Installing UMAP..."
pip install umap-learn

# Install machine learning and parallel processing
echo ""
echo "Installing joblib and tqdm..."
pip install joblib tqdm

# Install 3D mesh processing
echo ""
echo "Installing trimesh..."
pip install trimesh

# Install ConnectomeInfluenceCalculator
echo ""
echo "Installing ConnectomeInfluenceCalculator..."
pip install git+https://github.com/DrugowitschLab/ConnectomeInfluenceCalculator.git

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Environment '${ENV_NAME}' is ready to use."
echo ""
echo "To activate this environment, run:"
echo "  conda activate ${ENV_NAME}"
echo ""
echo "To deactivate:"
echo "  conda deactivate"
echo ""
echo "Installed packages:"
conda list | grep -E "numpy|pandas|scipy|pyarrow|gcsfs|plotly|navis|flybrains|umap|joblib|tqdm|trimesh"
echo ""
echo "To test the installation, run:"
echo "  python -c 'import navis; import pandas; import plotly; print(\"✓ All imports successful\")'"
echo ""
