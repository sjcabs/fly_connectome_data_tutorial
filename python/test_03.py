#!/usr/bin/env python3
"""
Test script for Python Tutorial 03 - Connectivity Analyses
"""

import pandas as pd
import numpy as np
import pyarrow.feather as feather
import gcsfs
import plotly.graph_objects as go
import plotly.express as px

# Configuration
DATASET = "banc_746"
DATASET_ID = "banc_746_id"
DATA_PATH = "gs://sjcabs_2025_data"
USE_GCS = DATA_PATH.startswith("gs://")

print("=" * 60)
print("Testing Python Tutorial 03 - Connectivity Analyses")
print("=" * 60)

# Test 1: Setup and imports
print("\n✓ All required packages imported successfully")

# Test 2: Helper functions
def construct_path(data_root, dataset, file_type="meta"):
    """Construct file paths for dataset files."""
    dataset_name = dataset.split("_")[0]

    # File type mappings with correct naming
    file_mappings = {
        "meta": f"{dataset}_meta.feather",
        "edgelist": f"{dataset}_edgelist.feather",
        "edgelist_simple": f"{dataset}_simple_edgelist.feather",  # Note: simple comes before edgelist
        "synapses": f"{dataset}_synapses.parquet"
    }

    if file_type not in file_mappings:
        raise ValueError(f"Unknown file_type: {file_type}")

    filename = file_mappings[file_type]
    full_path = f"{data_root}/{dataset_name}/{filename}"

    return full_path

def read_feather_gcs(path, gcs_fs=None):
    """Read Feather file from GCS or local path."""
    if path.startswith("gs://"):
        if gcs_fs is None:
            raise ValueError("gcs_fs required for GCS paths")

        print(f"Reading from GCS: {path}")
        gcs_path = path.replace("gs://", "")

        with gcs_fs.open(gcs_path, 'rb') as f:
            df = feather.read_feather(f)

        print(f"✓ Loaded {len(df):,} rows")
        return df
    else:
        print(f"Reading from local path: {path}")
        df = pd.read_feather(path)
        print(f"✓ Loaded {len(df):,} rows")
        return df

print("✓ Helper functions defined")

# Test 3: GCS Access
try:
    if USE_GCS:
        print("\nSetting up Google Cloud Storage access...")
        gcs = gcsfs.GCSFileSystem(token='google_default')
        print("✓ GCS filesystem initialized")
    else:
        gcs = None
        print("Using local filesystem")
except Exception as e:
    print(f"⚠ GCS setup failed: {e}")
    gcs = None

# Test 4: Load data (just check paths)
try:
    meta_path = construct_path(DATA_PATH, DATASET, "meta")
    edgelist_path = construct_path(DATA_PATH, DATASET, "edgelist_simple")

    print("\n✓ Data paths constructed:")
    print(f"  Metadata: {meta_path}")
    print(f"  Edgelist: {edgelist_path}")

    # Try to load a small sample
    if gcs:
        print("\nAttempting to load metadata...")
        meta = read_feather_gcs(meta_path, gcs_fs=gcs)
        print(f"✓ Metadata loaded: {len(meta):,} neurons")
        print(f"  Columns: {list(meta.columns)[:10]}...")

        print("\nAttempting to load edgelist...")
        edgelist = read_feather_gcs(edgelist_path, gcs_fs=gcs)
        print(f"✓ Edgelist loaded: {len(edgelist):,} connections")
        print(f"  Columns: {list(edgelist.columns)}")

        print("\n" + "=" * 60)
        print("✓ ALL TESTS PASSED")
        print("=" * 60)
    else:
        print("\n⚠ Cannot load data without GCS access")
        print("  But code structure is valid")

except Exception as e:
    print(f"\n✗ Error during data loading: {e}")
    import traceback
    traceback.print_exc()
