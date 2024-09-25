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

DOCKER_IMG_NAME=fiit-dev
DOCKER_CONTAINER_NAME=${DOCKER_IMG_NAME}

DEV_DIR_CONTAINER=/opt/fiit-dev

if [[ -z "${DEV_DIR}" ]]; then
  user_dir=$(realpath ~)
  DEV_DIR="$user_dir/fiit-dev"
fi

set -e

SCRIPT_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
INSTALLER_DIR_NAME=installer

docker build \
  --build-arg DEV_DIR_CONTAINER="${DEV_DIR_CONTAINER}" \
  --no-cache \
  --progress plain \
  -t ${DOCKER_IMG_NAME} .

mkdir -p "${DEV_DIR}"

DEV_DIR="${DEV_DIR}" \
DEV_DIR_CONTAINER="${DEV_DIR_CONTAINER}" \
DOCKER_IMG_NAME=${DOCKER_IMG_NAME} \
DOCKER_CONTAINER_NAME=${DOCKER_CONTAINER_NAME} \
  docker-compose up -d

cp -r "${SCRIPT_DIR}/${INSTALLER_DIR_NAME}" "${DEV_DIR}"

docker exec -u root -it "${DOCKER_CONTAINER_NAME}" \
  chmod u+x "${DEV_DIR_CONTAINER}/${INSTALLER_DIR_NAME}/install.sh"

docker exec -u root -it "${DOCKER_CONTAINER_NAME}" \
  "${DEV_DIR_CONTAINER}/${INSTALLER_DIR_NAME}/install.sh" \
    fiit "${DEV_DIR_CONTAINER}"
