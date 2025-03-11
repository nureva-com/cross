# `cross` Nureva custom changes

`cross` hasn't really changed much with the 0.2.5 having a builder for Ubuntu Xenial (16.04) and `main` being on
Focal (20.04). Nureva needed to have a cross-compilation chain for Ubuntu Noble (24.04) as we have native dependencies
that are targeted for that version. So, we added support for building this chain and specifically for `arm64`. We
didn't want to try to integrate across different architectures so we made copies of the necessary files and change
accordingly:
- `docker/Dockerfile.aarch64-unknown-linux-gnu` -> `docker/Dockerfile.aarch64-unknown-linux-gnu`
- `docker/qemu.sh` -> `docker/qemu-ubuntu-nostatic.sh`
- `docker/linux-image.sh` -> `docker/linux-image_ubuntu2404.sh`

Note that all of these kinds of custom changes that we don't see going upstream should go onto the `nureva-main` branch.
This is the version we will use internally. For anything that can go upstream, it should be targeting `main`.

## How to build cross-compile image for Ubuntu 24.04 on `arm64`

As from the instruction in the [`cross` wiki](https://github.com/cross-rs/cross/wiki/Contributing#building-and-testing),
just need to run `cargo build-docker-image aarch64-unknown-linux-gnu_24.04`. This builds a tagged docker image called
`ghcr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:local`.

## Publish to Nureva Azure Container Registry

Since we want to share this `cross` image with the development team and build pipelines, we need to publish it when
we have a new version. We rename the image so we can push to the Azure container registry and tag twice: for `latest`
and the specific build date of the image, e.g. `20250311`.

### Tagging

```bash
docker tag ghcr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:local nurevaromedev.azurecr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:latest
docker tag ghcr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:local nurevaromedev.azurecr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:<build_date>
```

### Pushing

```bash
az login
az acr login --name nurevaromedev
docker push nurevaromedev.azurecr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:latest
docker push nurevaromedev.azurecr.io/cross-rs/aarch64-unknown-linux-gnu_24.04:<build_date>
```
