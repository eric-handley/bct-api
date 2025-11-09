#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run this script with sudo or as root." >&2
  exit 1
fi

USER_NAME=${1:-${SUDO_USER:-}}
if [[ -z ${USER_NAME} ]]; then
  echo "Usage: sudo ./scripts/install-docker.sh <username>" >&2
  exit 1
fi

if ! id "${USER_NAME}" &>/dev/null; then
  echo "User '${USER_NAME}' does not exist on this system." >&2
  exit 1
fi

. /etc/os-release
if [[ ${ID} != "ubuntu" ]]; then
  echo "Warning: detected '${ID}', but this script is tailored for Ubuntu." >&2
fi

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

# Remove snap-based Docker install if present to avoid conflicts
if command -v snap &>/dev/null && snap list docker &>/dev/null; then
  echo "Removing snap-based docker package to prevent conflicts."
  snap remove docker
fi

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  ${VERSION_CODENAME:-$(lsb_release -cs)} stable" \
  | tee /etc/apt/sources.list.d/docker.list >/dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker
systemctl --no-pager status docker

if ! id -nG "${USER_NAME}" | grep -qw docker; then
  usermod -aG docker "${USER_NAME}"
  echo "Added ${USER_NAME} to the docker group. Log out/in or run 'newgrp docker' to apply." >&2
else
  echo "${USER_NAME} already in docker group; skipping." >&2
fi

if ! docker run --rm hello-world >/dev/null 2>&1; then
  echo "Docker installed but sample container failed. Check network access and rerun 'docker run hello-world'." >&2
else
  echo "Docker Engine installation verified via hello-world container."
fi
