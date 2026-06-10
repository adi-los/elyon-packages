#!/bin/sh
# Elyon installer â€” downloads the pre-built binary for macOS or Linux
# Usage:
#   curl -fsSL https://install.elyon.cloud | bash

set -e

PAGES_BASE="${ELYON_INSTALL_BASE:-https://adi-los.github.io/elyon-packages}"
INSTALL_DIR="${ELYON_INSTALL_DIR:-/usr/local/bin}"
BINARY="elyon"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  arm64)   ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

case "$OS" in
  linux)
    # On Linux, prefer the package manager repos (they run postinstall which sets everything up)
    if command -v dnf >/dev/null 2>&1; then
      echo "Tip: For full platform setup use: curl -fsSL ${PAGES_BASE}/setup-dnf.sh | bash"
    elif command -v apt-get >/dev/null 2>&1; then
      echo "Tip: For full platform setup use: curl -fsSL ${PAGES_BASE}/setup-apt.sh | bash"
    fi
    DOWNLOAD_URL="${PAGES_BASE}/linux/${ARCH}/elyon"
    ;;
  darwin)
    DOWNLOAD_URL="${PAGES_BASE}/mac/${ARCH}/elyon"
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Installing elyon for $OS/$ARCH..."
echo "  from: $DOWNLOAD_URL"
echo "  to:   $INSTALL_DIR/$BINARY"

# Download
TMP=$(mktemp)
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$DOWNLOAD_URL" -o "$TMP"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$TMP" "$DOWNLOAD_URL"
else
  echo "Error: curl or wget is required"
  exit 1
fi

chmod +x "$TMP"

# Install (use sudo if not root)
if [ "$(id -u)" = "0" ]; then
  mv "$TMP" "$INSTALL_DIR/$BINARY"
else
  echo "  (requires sudo to write to $INSTALL_DIR)"
  sudo mv "$TMP" "$INSTALL_DIR/$BINARY"
fi

echo ""
echo "elyon installed successfully!"
echo ""
elyon --version 2>/dev/null || true
echo ""
echo "Edge onboarding:"
echo "  elyon edge enroll --token <token>"
echo "  sudo elyon edge install-service"
echo "  elyon edge logs -f"
echo ""
echo "Developer mode:"
echo "  elyon store seed"
echo "  elyon new my-api --type=api --db=postgres"
echo "  cd my-api && elyon install && elyon dev"
