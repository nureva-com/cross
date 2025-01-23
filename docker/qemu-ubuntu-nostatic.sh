#!/usr/bin/env bash

set -x
set -euo pipefail

# shellcheck disable=SC1091
. lib.sh

main() {
    local version=5.1.0

    local arch="${1}" \
        softmmu="${2:-}"

    install_packages \
        autoconf \
        automake \
        bison \
        bzip2 \
        curl \
        flex \
        libtool \
        make \
        patch \
        python3 \

    install_packages \
        g++ \
        pkg-config \
        xz-utils \
        libattr1-dev \
        libcap-ng-dev \
        libffi-dev \
        libglib2.0-dev \
        libpixman-1-dev \
        libselinux1-dev \
        zlib1g-dev

    # if we have python3.6+, we can install qemu 7.0.0, which needs ninja-build
    # ubuntu 16.04 only provides python3.5, so remove when we have a newer qemu.
    is_ge_python36=$(python3 -c "import sys; print(int(sys.version_info >= (3, 6)))")
    if [[ "${is_ge_python36}" == "1" ]]; then
        version=7.0.0
        install_packages ninja-build
    fi

    # if we have python3.8+, we can install qemu 8.2.2, which needs ninja-build,
    # meson, python3-pip and libslirp-dev.
    # ubuntu 16.04 only provides python3.5, so remove when we have a newer qemu.
    is_ge_python38=$(python3 -c "import sys; print(int(sys.version_info >= (3, 8)))")
    if [[ "${is_ge_python38}" == "1" ]]; then
        version=8.2.2
        install_packages ninja-build meson python3-pip libslirp-dev
    fi

    local td
    td="$(mktemp -d)"

    pushd "${td}"

    curl --retry 3 -sSfL "https://download.qemu.org/qemu-${version}.tar.xz" -O
    tar --strip-components=1 -xJf "qemu-${version}.tar.xz"

    local targets="${arch}-linux-user"
    local virtfs=""
    case "${softmmu}" in
        softmmu)
            if [ "${arch}" = "ppc64le" ]; then
                targets="${targets},ppc64-softmmu"
            else
                targets="${targets},${arch}-softmmu"
            fi
            virtfs="--enable-virtfs"
            ;;
        "")
            true
            ;;
        *)
            echo "Invalid softmmu option: ${softmmu}"
            exit 1
            ;;
    esac

    ./configure \
        --disable-kvm \
        --disable-vnc \
        --disable-guest-agent \
        --enable-linux-user \
        ${virtfs} \
        --target-list="${targets}"
    make "-j$(nproc)"
    make install

    purge_packages

    popd

    rm -rf "${td}"
    rm "${0}"
}

main "${@}"
