# hloc Offline Bundle

Fully self-contained offline installer for [hloc (Hierarchical-Localization)](https://github.com/cvg/Hierarchical-Localization) v1.5.

**Target:** Ubuntu 20.04 / RTX 3060 / CUDA 12.6 / Python 3.12 (via Miniconda)

## What's inside

- Miniconda Python 3.12 installer
- PyTorch 2.6.0+cu124 wheels
- hloc v1.5 + all dependencies (59 wheels)
- Pre-trained model weights (SuperPoint, SuperGlue, LightGlue, NetVLAD)
- One-command installer script

## Download & Install

### Step 1: Clone this repo

```bash
git clone https://github.com/stooopid10-sys/hloc_offline_bundle.git
cd hloc_offline_bundle
```

### Step 2: Reassemble the tar.gz

The bundle is split into 90MB parts (GitHub file limit). Reassemble:

```bash
bash reassemble.sh
```

Or manually:

```bash
cat parts/hloc_bundle_part_* > hloc_offline_bundle.tar.gz
```

**Expected SHA256:** `5f45e1adbdd5038975f8904af4746371f95042daf906a3f555e4edf2d209f4f5`

### Step 3: Transfer to offline server via USB

Copy `hloc_offline_bundle.tar.gz` (4.0GB) to USB drive.

### Step 4: Install on offline server

```bash
tar xzf hloc_offline_bundle.tar.gz
cd hloc_transfer
bash install_offline.sh
```

### Step 5: Use hloc

```bash
export PATH=$HOME/miniconda3/bin:$PATH
source ~/hloc_offline/venv/bin/activate
python3 -c "import hloc; print(hloc.__version__)"
```

## What this does NOT touch

- System Python (3.8)
- ROS Noetic
- System OpenCV / Ceres
- System CUDA toolkit
- /usr, /opt, /etc

Everything installs under `~/miniconda3/`, `~/hloc_offline/`, and `~/.cache/torch/hub/`.

## Verified

- Tested with `unshare --net` (zero network access)
- Full pipeline test: SuperPoint + SuperGlue + LightGlue all pass on GPU
