#!/bin/bash
# One command to install Elyon + App Platform on RHEL / Rocky / Fedora / CentOS
# Usage:
#   curl -fsSL https://adi-los.github.io/elyon-packages/setup-dnf.sh | bash

set -e
PAGES_BASE="${PAGES_BASE:-https://raw.githubusercontent.com/adi-los/elyon-packages/main}"

[ "$EUID" -ne 0 ] && exec sudo bash "$0" "$@"

printf "\n\033[1mâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•\033[0m\n"
printf "\033[1;36m  Elyon â€” Installing on %s\033[0m\n" "$(. /etc/os-release && echo $PRETTY_NAME)"
printf "\033[1mâ•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•\033[0m\n\n"

# â”€â”€ Docker CE repo (so dnf resolves docker-ce as a dependency) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if ! command -v docker >/dev/null 2>&1; then
  echo "Adding Docker CE repository..."
  dnf install -y dnf-plugins-core 2>/dev/null || true
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 2>/dev/null || true
fi

# â”€â”€ Elyon repo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo "Adding Elyon repository..."
cat > /etc/yum.repos.d/elyon.repo <<EOF
[elyon]
name=Elyon - App Platform
baseurl=${PAGES_BASE}/rpm/x86_64
enabled=1
gpgcheck=0
metadata_expire=300
EOF

# â”€â”€ Clean any cached metadata from old repo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
dnf clean metadata --disablerepo="*" --enablerepo="elyon" 2>/dev/null || dnf clean all 2>/dev/null || true

# â”€â”€ Install â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
echo "Installing Elyon..."
dnf install -y elyon

printf "\n\033[1;32m  Done! Run: elyon --help\033[0m\n\n"
