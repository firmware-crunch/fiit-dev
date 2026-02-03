
# fiit Development Utilities

**fiit** development environment is based on podman and Conda with conda-forge
repository.

To bootstrap a development environment for **fiit**, run the following command.

```text
$ git clone https://github.com/firmware-crunch/fiit-dev
$ cd fiit-dev
$ ./env_bootstrap.sh
```

The bootstrap script builds a podman image, run a container and deploy a
development environment in the container with a shared directory (podman volume)
with the container localized to `~/fiit-dev` on the host filesystem. This
shared directory contains a Conda Python environment with the **fiit** python
package source code installed in develop mode.
This environment setup is useful because it allows straightforward access of
**fiit** source code and associated python environment from your favorite host
IDE without any container configuration, while taking advantage to run the
**fiit** development version in the container.

By default, the development environment directory is created to `~/fiit-dev`. To
Change this behaviour, `DEV_DIR` must be specified.

```text
$ DEV_DIR=/path/to/dev/directory ./env_bootstrap.sh
```

To connect to the container, run the following command. At connect time, the
Conda python environment is automatically activated and the `fiit` command
available.

```text
$ cd fiit-dev
$ make connect
podman exec -u fiit -it fiit-dev bash
(/opt/fiit-dev/conda_env_py_3_9_2) fiit@FirmwareCrunch:/opt/fii-dev$ fiit -h
```
