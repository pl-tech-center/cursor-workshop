#!/usr/bin/env bash
set -euo pipefail

REPO_URL="git@github.com-pl-tech-center:pl-tech-center/cv-builder.git"
CV_BUILDER_DIR="../cv-builder"

echo "=== Cursor Workshop Setup ==="
echo ""

# 1. Clone cv-builder if not already present
if [ -d "$CV_BUILDER_DIR" ]; then
  echo "✓ cv-builder already cloned at $CV_BUILDER_DIR"
else
  echo "→ Cloning cv-builder..."
  git clone "$REPO_URL" "$CV_BUILDER_DIR"
  echo "✓ Cloned"
fi

cd "$CV_BUILDER_DIR"

# 2. Install dependencies
echo "→ Installing npm dependencies..."
npm install
echo "✓ Dependencies installed"

# 3. Download TeX Live WASM assets (~150 MB, one-time)
echo "→ Downloading TeX Live WASM assets (this may take a minute)..."
npm run download:tex-assets
echo "✓ TeX assets downloaded"

# 4. Run tests to verify everything works
echo "→ Running unit tests..."
npm test
echo "✓ All tests passed"

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Open cv-builder in Cursor:  cursor $CV_BUILDER_DIR"
echo "  2. Let codebase indexing finish (Cursor Settings → Features → Codebase Indexing)"
echo "  3. Set your default model: Cmd+Shift+J"
echo "  4. Try the self-paced orientation in the README if you're new to Cursor"
