# hloc Offline Bundle

Fully self-contained offline installer for [hloc (Hierarchical-Localization)](https://github.com/cvg/Hierarchical-Localization) v1.5.

**Target:** Ubuntu 20.04 / RTX 3060 / CUDA 12.6 / Python 3.12 (via Miniconda)

## What's inside

- Miniconda Python 3.12 installer
- PyTorch 2.6.0+cu124 wheels
- hloc v1.5 source code + all dependencies (59 wheels)
- Pre-trained model weights (SuperPoint, SuperGlue, LightGlue, NetVLAD)
- One-command installer script

## Demos & Notebooks Included

The bundle includes the full hloc repo, so all official notebooks are available:

| Notebook | Status | Notes |
|---|---|---|
| `demo.ipynb` | ✅ Works offline | Uses bundled Sacré-Cœur dataset (10 images) |
| `pipeline_SfM.ipynb` | ⚠️ Needs dataset | Structure-from-Motion pipeline |
| `pipeline_Aachen.ipynb` | ⚠️ Needs dataset | Aachen Day-Night benchmark (~5GB) |
| `pipeline_InLoc.ipynb` | ⚠️ Needs dataset | Indoor localization benchmark (~30GB) |

**Bundled dataset:** `datasets/sacre_coeur/` (10 sample images, 4.2MB) — enough to run the main `demo.ipynb` fully offline.

For the larger benchmark notebooks (Aachen, InLoc), you'd need to pre-download the respective datasets while online.

## Pre-requisites on offline server

The offline server only needs:

| Requirement | Why |
|---|---|
| **Ubuntu 20.04** (or compatible) | Base OS |
| **NVIDIA GPU driver** (≥ 525) | For GPU access — must be installed before going offline |

**NOT needed:**
- ❌ CUDA toolkit (PyTorch bundles its own runtime)
- ❌ cuDNN (PyTorch bundles its own)
- ❌ Python 3.10+ (Miniconda brings 3.12)
- ❌ pip / virtualenv (Miniconda brings them)
- ❌ sudo / apt commands
- ❌ Internet connection

## Download & Install

### Step 1: Clone this repo (on a machine with internet)

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

Copy `hloc_offline_bundle.tar.gz` (4.0GB) to USB drive, then to the offline server.

### Step 4: Install on offline server (5 simple commands, no sudo)

```bash
tar xzf hloc_offline_bundle.tar.gz
cd hloc_transfer
bash install_offline.sh
```

The installer will:
- Install Miniconda Python 3.12 to `~/miniconda3/`
- Create venv at `~/hloc_offline/venv/`
- Install PyTorch + hloc from bundled wheels
- Copy model weights to `~/.cache/torch/hub/`
- Verify everything works

### Step 5: Use hloc

```bash
export PATH=$HOME/miniconda3/bin:$PATH
source ~/hloc_offline/venv/bin/activate
python3 -c "import hloc; print(hloc.__version__)"
```

### Step 6: Run the demo

```bash
cd ~/hloc_transfer/hloc_repo
jupyter notebook demo.ipynb
```

Or run as a Python script:

```bash
python3 -c "
from hloc import extract_features, match_features, reconstruction, pairs_from_exhaustive
from pathlib import Path

images = Path('datasets/sacre_coeur')
outputs = Path('/tmp/hloc_demo_output')
outputs.mkdir(exist_ok=True)

feature_conf = extract_features.confs['superpoint_aachen']
matcher_conf = match_features.confs['superglue']
references = sorted([p.relative_to(images).as_posix() for p in (images / 'mapping/').iterdir()])

extract_features.main(feature_conf, images, image_list=references, feature_path=outputs/'features.h5')
pairs_from_exhaustive.main(outputs/'pairs.txt', image_list=references)
match_features.main(matcher_conf, outputs/'pairs.txt', features=outputs/'features.h5', matches=outputs/'matches.h5')
model = reconstruction.main(outputs/'sfm', images, outputs/'pairs.txt', outputs/'features.h5', outputs/'matches.h5', image_list=references)
print(f'Reconstructed {model.num_reg_images()} cameras, {model.num_points3D()} 3D points')
"
```

## What this does NOT touch

- System Python (3.8)
- ROS Noetic
- System OpenCV / Ceres
- System CUDA toolkit
- /usr, /opt, /etc

Everything installs under `~/miniconda3/`, `~/hloc_offline/`, and `~/.cache/torch/hub/`.

To completely uninstall:

```bash
rm -rf ~/miniconda3 ~/hloc_offline ~/.cache/torch/hub ~/hloc_transfer
```

## Verified

- ✅ Tested with `unshare --net` (zero network access during install)
- ✅ Full pipeline test on GPU: SuperPoint + SuperGlue + LightGlue all pass
- ✅ Demo `demo.ipynb` reconstructs 1847 3D points from 10 Sacré-Cœur images in ~5 seconds (L40S GPU)

## Troubleshooting

**Q: "CUDA not available" in PyTorch**
A: Check NVIDIA driver: `nvidia-smi`. If no output, the GPU driver is not installed.

**Q: "No module named hloc"**
A: Make sure you activated the venv: `source ~/hloc_offline/venv/bin/activate`

**Q: Out of GPU memory**
A: hloc needs ~1-2GB VRAM. If other processes use the GPU, stop them first.
