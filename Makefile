################################################################################
#
# Copyright 2022-2026 Vincent Dary
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

USER := fiit
IMG_NAME := fiit-dev
CONTAINER_NAME := $(IMG_NAME)
DOCK_BIN := podman

connect:
	$(DOCK_BIN) exec -u $(USER) -it $(CONTAINER_NAME) bash

clean_container_env:
	- $(DOCK_BIN) stop $(CONTAINER_NAME)
	- $(DOCK_BIN) rm $(CONTAINER_NAME)
	- $(DOCK_BIN) image rm $(IMG_NAME)
