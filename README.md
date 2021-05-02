<!-- prettier-ignore-start -->
[comment]: # (
SPDX-License-Identifier: MIT
)

[comment]: # (
SPDX-FileCopyrightText: 2021 Carles Fernandez-Prades <carles.fernandez@cttc.es>
)
<!-- prettier-ignore-end -->

# docker-petalinux2

A somehow generic Xilinx PetaLinux & Vivado Docker image, using Ubuntu 18.04 as
the base image.

PetaLinux version `2020.1` is the first version handled by this release. For
former versions, please check
[docker-petalinux](https://github.com/carlesfernandez/docker-petalinux).

In order to use this tool, you need to
[install Docker](https://docs.docker.com/get-docker/) in your machine. If you
want to use the Vivado graphical interface, you will also need the ipconfig
utility (on Debian/ubuntu: `sudo apt-get install net-tools`).

A Xilinx user ID is required to download the PetaLinux and Vivado installers.

## Download the installers

### Prepare the PetaLinux installer

The PetaLinux Installer is to be downloaded from the
[Xilinx's Embedded Design Tools website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools.html).

Place the downloaded `petalinux-v<VERSION>-final-installer.run` file (where
`<VERSION>` can be `2020.1`, `2020.2`, ...) in the same folder than the
Dockerfile.

### Prepare the Vivado installer (optional)

Optionally, Vivado can be downloaded from the
[Xilinx's Vivado Design Tools website](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html).
Go there and choose the All OS installer Single-File Download (TAR/GZIP).

The file is called something like `Xilinx_Unified_<VERSION>_XXXX_YYYY.tar.gz`.
Place it in the same folder than the Dockerfile. The building script will guess
its exact name automatically.

If this file is present when building the image, the Docker image will be about
120 GB so make sure you have enough space in `/var/lib/docker`. Be aware that
the building process can take some hours.

You can change your Docker disk utilization in the Docker GUI: select the Docker
icon and then Preferences > Resources > Advanced, and then click "Apply &
Restart".

You can tune the Vivado installing configuration by modifying the
`install_config.txt` file. Please do not change the `Destination=/tools/Xilinx`
entry.

If the Vivado installer file is not present in the folder when running the
building script, the petalinux-only image will be about 11 GB and the building
process will be much faster.

## Build the image

Run:

    ./docker_build.sh <VERSION>

> The default for `<VERSION>`, if not specified, is `2020.1`.

## Work with a PetaLinux project

A helper script `petalin2.sh` is provided that should be run _inside_ a
petalinux project directory. It basically is a shortcut to:

    docker run -ti -v "$PWD":"$PWD" -w "$PWD" --rm -u petalinux petalinux:<latest version> $@

When run without arguments, a shell will spawn, _with PetaLinux `settings.sh`
already sourced_, so you can directly execute `petalinux-*` commands.

    user@host:/path/to/petalinux_project$ /path/to/petalin2.sh
    petalinux2@host:/path/to/petalinux_project$ petalinux-build

Otherwise, the arguments will be executed as a command. Example:

    user@host:/path/to/petalinux_project$ /path/to/petalin2.sh \
    "petalinux-create -t project --template zynq --name myproject"

## Using Vivado graphical interface

If the Vivado installer was present when building the Docker image, you can
execute Vivado from the shell spawn when running `petalin2.sh`.

There are some steps on your side if you want to make use of Vivado's graphical
interface before running the Docker container.

- If your local machine is running Linux, adjust the permission of the X server
  host:

      $ sudo apt-get install x11-xserver-utils
      $ xhost +local:root

- If your local machine is running macOS:

  - Do this once:

    - Install the latest [XQuartz](https://www.xquartz.org/) version and run it.
    - Activate the option
      "[Allow connections from network clients](https://blogs.oracle.com/oraclewebcentersuite/running-gui-applications-on-native-docker-containers-for-mac)"
      in XQuartz settings.
    - Quit and restart XQuartz to activate the setting.

  - Then, in the host machine:

    - Get your network IP with `ipconfig getifaddr en1` for wireless, or
      `ipconfig getifaddr en0` for ethernet.
    - Tell XQuartz to accept connections from that IP:

          $ xhost + 127.0.0.1 ; <- YOUR NETWORK IP HERE

- If you are accessing remotely to the machine running the Docker container via
  ssh, you need to enable trusted X11 forwarding with the `-Y` flag:

      $ ssh user@host -Y

Now you can try it:

    user@host:/path/to/petalinux_project$ /path/to/petalin2.sh
    petalinux2@host:/path/to/petalinux_project# vivado

Enjoy!
