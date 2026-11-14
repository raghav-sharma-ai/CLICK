#!/bin/bash
# Helper script to package CLICK for itch.io upload

set -e

if [ ! -f "build/web/index.html" ]; then
    echo "=================================================="
    echo "ERROR: build/web/index.html not found!"
    echo "Please export your project first in Godot:"
    echo "  1. Project -> Export"
    echo "  2. Select 'Web'"
    echo "  3. Click 'Export Project...'"
    echo "  4. Save as 'build/web/index.html'"
    echo "=================================================="
    exit 1
fi

echo "Packaging build/web contents into CLICK-itch-web.zip..."
cd build/web
rm -f ../CLICK-itch-web.zip
zip -r ../CLICK-itch-web.zip ./*
cd ../..

echo "=================================================="
echo "SUCCESS! Package created:"
echo "  $(pwd)/build/CLICK-itch-web.zip"
echo "Upload this file directly to itch.io!"
echo "=================================================="
