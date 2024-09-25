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

FROM debian:bookworm-20240904

ARG USERNAME=fiit
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG CONTAINER_DEV_DIR=/opt/fiit-dev

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y locales

RUN echo "C.UTF-8 en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen C.UTF-8
RUN dpkg-reconfigure locales

ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

RUN useradd -m -d /home/$USERNAME -s /bin/bash -c "$USERNAME user" -U $USERNAME
RUN usermod -L $USERNAME
RUN echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir $CONTAINER_DEV_DIR
RUN chown -R $USER_UID:$USER_GID $CONTAINER_DEV_DIR
WORKDIR $CONTAINER_DEV_DIR

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
