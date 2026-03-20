#!/usr/bin/env bash
set -euo pipefail

# Update script for Helm 4 Nix package
# Usage: ./update.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Fetching latest Helm 4 release..."
VERSION=$(curl -fsSL https://api.github.com/repos/helm/helm/releases | \
  jq -r '[.[] | select(.tag_name | startswith("v4")) | select(.prerelease == false)] | .[0].tag_name' | \
  sed 's/^v//')

echo "Latest Helm 4 version: $VERSION"

echo ""
echo "Fetching checksums..."

# Fetch checksums for each platform
DARWIN_ARM64=$(curl -fsSL "https://get.helm.sh/helm-v${VERSION}-darwin-arm64.tar.gz.sha256sum" | cut -d' ' -f1)
DARWIN_AMD64=$(curl -fsSL "https://get.helm.sh/helm-v${VERSION}-darwin-amd64.tar.gz.sha256sum" | cut -d' ' -f1)
LINUX_AMD64=$(curl -fsSL "https://get.helm.sh/helm-v${VERSION}-linux-amd64.tar.gz.sha256sum" | cut -d' ' -f1)
LINUX_ARM64=$(curl -fsSL "https://get.helm.sh/helm-v${VERSION}-linux-arm64.tar.gz.sha256sum" | cut -d' ' -f1)

echo "Converting to Nix hash format..."
DARWIN_ARM64_NIX=$(nix hash convert --hash-algo sha256 "$DARWIN_ARM64")
DARWIN_AMD64_NIX=$(nix hash convert --hash-algo sha256 "$DARWIN_AMD64")
LINUX_AMD64_NIX=$(nix hash convert --hash-algo sha256 "$LINUX_AMD64")
LINUX_ARM64_NIX=$(nix hash convert --hash-algo sha256 "$LINUX_ARM64")

echo ""
echo "Version: $VERSION"
echo ""
echo "Hashes:"
echo "  darwin-arm64: $DARWIN_ARM64_NIX"
echo "  darwin-amd64: $DARWIN_AMD64_NIX"
echo "  linux-amd64:  $LINUX_AMD64_NIX"
echo "  linux-arm64:  $LINUX_ARM64_NIX"
echo ""

# Read current file
CURRENT_FILE="$SCRIPT_DIR/default.nix"

# Create backup
cp "$CURRENT_FILE" "$CURRENT_FILE.bak"
echo "Created backup: $CURRENT_FILE.bak"

# Update the file
sed -i.tmp \
  -e "s/version = \".*\";/version = \"$VERSION\";/" \
  -e "s|\"darwin-amd64\" = \"sha256-[^\"]*\";|\"darwin-amd64\" = \"$DARWIN_AMD64_NIX\";|" \
  -e "s|\"darwin-arm64\" = \"sha256-[^\"]*\";|\"darwin-arm64\" = \"$DARWIN_ARM64_NIX\";|" \
  -e "s|\"linux-amd64\" = \"sha256-[^\"]*\";|\"linux-amd64\" = \"$LINUX_AMD64_NIX\";|" \
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
