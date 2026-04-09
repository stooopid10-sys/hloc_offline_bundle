#!/bin/bash
set -e

echo "Reassembling hloc_offline_bundle.tar.gz from parts..."
cat parts/hloc_bundle_part_* > hloc_offline_bundle.tar.gz
echo "Done! Size: $(du -h hloc_offline_bundle.tar.gz | cut -f1)"

echo ""
echo "Verifying checksum..."
sha256sum hloc_offline_bundle.tar.gz

echo ""
echo "To install:"
echo "  tar xzf hloc_offline_bundle.tar.gz"
echo "  cd hloc_transfer"
echo "  bash install_offline.sh"
