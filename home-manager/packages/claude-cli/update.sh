#!/usr/bin/env bash
set -euo pipefail

# Update crutchy script for Claude Code CLI Nix package
# Usage: ./update.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GCS_BASE="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

echo "Fetching latest Claude Code version..."
VERSION=$(curl -fsSL "$GCS_BASE/latest")
echo "Latest version: $VERSION"

echo ""
echo "Fetching manifest for version $VERSION..."
MANIFEST=$(curl -fsSL "$GCS_BASE/$VERSION/manifest.json")

echo ""
echo "Extracting checksums..."

# Extract checksums for each platform
DARWIN_ARM64=$(echo "$MANIFEST" | jq -r '.platforms["darwin-arm64"].checksum')
DARWIN_X64=$(echo "$MANIFEST" | jq -r '.platforms["darwin-x64"].checksum')
LINUX_ARM64=$(echo "$MANIFEST" | jq -r '.platforms["linux-arm64"].checksum')
LINUX_X64=$(echo "$MANIFEST" | jq -r '.platforms["linux-x64"].checksum')

echo "Converting to Nix hash format..."
DARWIN_ARM64_NIX=$(nix hash convert --hash-algo sha256 "$DARWIN_ARM64")
DARWIN_X64_NIX=$(nix hash convert --hash-algo sha256 "$DARWIN_X64")
LINUX_ARM64_NIX=$(nix hash convert --hash-algo sha256 "$LINUX_ARM64")
LINUX_X64_NIX=$(nix hash convert --hash-algo sha256 "$LINUX_X64")

echo ""
echo "Version: $VERSION"
echo ""
echo "Hashes:"
echo "  darwin-arm64: $DARWIN_ARM64_NIX"
echo "  darwin-x64:   $DARWIN_X64_NIX"
echo "  linux-arm64:  $LINUX_ARM64_NIX"
echo "  linux-x64:    $LINUX_X64_NIX"
echo ""

# Read current file
CURRENT_FILE="$SCRIPT_DIR/default.nix"

# Create backup
cp "$CURRENT_FILE" "$CURRENT_FILE.bak"
echo "Created backup: $CURRENT_FILE.bak"

# Update the file
sed -i.tmp \
  -e "s/version = \".*\";/version = \"$VERSION\";/" \
  -e "s|\"darwin-x64\" = \"sha256-[^\"]*\";|\"darwin-x64\" = \"$DARWIN_X64_NIX\";|" \
  -e "s|\"darwin-arm64\" = \"sha256-[^\"]*\";|\"darwin-arm64\" = \"$DARWIN_ARM64_NIX\";|" \
  -e "s|\"linux-x64\" = \"sha256-[^\"]*\";|\"linux-x64\" = \"$LINUX_X64_NIX\";|" \
  -e "s|\"linux-arm64\" = \"sha256-[^\"]*\";|\"linux-arm64\" = \"$LINUX_ARM64_NIX\";|" \
  "$CURRENT_FILE"

rm "$CURRENT_FILE.tmp"

echo ""
echo "✅ Updated $CURRENT_FILE"
echo ""
echo "Changes:"
git diff --no-index "$CURRENT_FILE.bak" "$CURRENT_FILE" || true
echo ""
echo "To apply the update, rebuild your nix-darwin configuration:"
echo "  darwin-rebuild switch --flake ~/.config/nix-darwin"
echo ""
echo "To revert changes, restore from backup:"
echo "  mv $CURRENT_FILE.bak $CURRENT_FILE"
