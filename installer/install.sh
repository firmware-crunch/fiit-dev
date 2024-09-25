#!/usr/bin/env bash

################################################################################
#
# Copyright 2022-2025 Vincent Dary
#
# This file is part of fiit.
#
# fiit is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# fiit is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with fiit. If not, see <https://www.gnu.org/licenses/>.
#
################################################################################

################################################################################
# runtime configuration
################################################################################
set -o errexit # Exit on error. Append "|| true" if error expected.
set -o nounset # Disallow undefined vars. Use ${VAR:-} for undefined VAR
set -o pipefail
set -o xtrace # Turn on traces
SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

################################################################################
# Constants
################################################################################
USER=$1
INSTALL_DIR=$2
THIRD_PARTY_DIR="${INSTALL_DIR}/third-party"
USER_ID=$(id -u "$USER")
USER_GID=$(id -g "$USER")
USER_BASHRC=/home/${USER}/.bashrc

################################################################################
# Install
################################################################################

mkdir "${THIRD_PARTY_DIR}"


# Dirty workaround related to container issue with gethostbyname not working
host_ips=$(hostname -I | cut -d\  -f1)
echo "${host_ips} $(hostname)" > /etc/hosts
chown ${USER}: /etc/hosts
{
  echo -e "\n\n#"
  echo "# Dirty workaround related to container issue with gethostbyname"
  echo "#"
  echo 'echo $(hostname -I | cut -d\  -f1) $(hostname) > /etc/hosts'
  echo -e "\n\n"
} >> "${USER_BASHRC}"
chmod ugo=rw /etc/hosts

# main system package bootstrap
echo 'N' | apt-get --yes install sudo
apt-get install --yes $(cat "${SCRIPT_DIR}/debian_packages.txt")


# Git configuration
cp -v "${SCRIPT_DIR}/.gitconfig" /root
sudo -u "${USER}" cp -v "${SCRIPT_DIR}/.gitconfig" "/home/${USER}"


# conda install with conda-forge repository
CONDA_BIN=/opt/conda/bin/conda
curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
install -o root -g root -m 644 conda.gpg /usr/share/keyrings/conda-archive-keyring.gpg
rm -f conda.gpg
gpg --keyring /usr/share/keyrings/conda-archive-keyring.gpg \
    --no-default-keyring  \
    --fingerprint 34161F5BF5EB1D4BFBBB8F0A8AEB4F8B29D82806
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" \
    > /etc/apt/sources.list.d/conda.list
apt-get update
apt-get install --yes conda

sudo -u "${USER}" ${CONDA_BIN} init
sudo -u "${USER}" ${CONDA_BIN} config --set auto_activate_base false
sudo -u "${USER}" ${CONDA_BIN} config --add channels conda-forge
sudo -u "${USER}" ${CONDA_BIN} config --remove channels defaults
sudo -u "${USER}" ${CONDA_BIN} config --show channels
sudo -u "${USER}" ${CONDA_BIN} info


# install python 3.9.2 conda environment
DEFAULT_DEV_PY_ENV_NAME=conda_env_py_3_9_2
DEFAULT_DEV_PY_ENV_PATH="/opt/fiit-dev/${DEFAULT_DEV_PY_ENV_NAME}"
sudo -u "${USER}" bash -c \
  "echo y | ${CONDA_BIN} create --prefix '${DEFAULT_DEV_PY_ENV_PATH}' python==3.9.2"

{
echo -e "\n\n#"
echo -e "\n\n# Activate conda env ${DEFAULT_DEV_PY_ENV_NAME}"
echo "#"
echo "if [ -f '/opt/conda/etc/profile.d/conda.sh' ]; then"
echo "    . '/opt/conda/etc/profile.d/conda.sh'"
echo "    conda activate ${DEFAULT_DEV_PY_ENV_PATH}"
echo "fi"
} >> "${USER_BASHRC}"


# fiit bootstrap from github
cd "${INSTALL_DIR}"
FIIT_GIT_URL="https://github.com/firmware-crunch/fiit.git"
sudo -u "${USER}" bash -c "git clone '${FIIT_GIT_URL}'"
cd fiit
sudo -u "${USER}" ${CONDA_BIN} run -vvv --prefix ${DEFAULT_DEV_PY_ENV_PATH} pip install -e .[DEV]


# ghidra bootstrap from github
GHIDRA_PKG_NAME="ghidra_11.0.1_PUBLIC_20240130.zip"
GHIDRA_PKG_URL="https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.0.1_build/${GHIDRA_PKG_NAME}"

apt-get install -y openjdk-17-jdk
cd "${THIRD_PARTY_DIR}"
wget "${GHIDRA_PKG_URL}"
unzip "${GHIDRA_PKG_NAME}"
rm -f "${GHIDRA_PKG_NAME}"


# Filesystem setting
chown -R ${USER_ID}:${USER_GID} "${INSTALL_DIR}"
rm -rf "${SCRIPT_DIR}"
