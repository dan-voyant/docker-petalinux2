#!/bin/bash
# SPDX-FileCopyrightText: 2021-2023, Carles Fernandez-Prades <carles.fernandez@cttc.es>
# SPDX-FileCopyrightText: 2024, Max Wipfli <mail@maxwipfli.ch>
# SPDX-License-Identifier: MIT

# Default version 2020.2
XILVER=${1:-2020.2}

cd installers || exit

# Check for Petalinux installer
PLNX="petalinux-v${XILVER}-final-installer.run"
if [ ! -f "$PLNX" ] ; then
    echo "$PLNX installer not found"
    cd ..
    exit 1
fi

cd ..

# shellcheck disable=SC2009
if ! ps -fC python3 | grep "http.server" > /dev/null ; then
    python3 -m "http.server" &
    HTTPID=$!
    echo "HTTP Server started as PID $HTTPID"
    trap 'kill $HTTPID' EXIT QUIT SEGV INT HUP TERM ERR
fi

echo "Creating Docker image docker_petalinux2:$XILVER..."
time docker build --build-arg USERNAME=petalinux --build-arg UID=$(id -u) --build-arg GID=$(id -g) --build-arg PETA_VERSION="${XILVER}" --build-arg PETA_RUN_FILE="${PLNX}" -t docker_petalinux2:"${XILVER}" .

[ -n "$HTTPID" ] && kill "$HTTPID" && echo "Killed HTTP Server"
