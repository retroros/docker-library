
Example build command (note that arm32 is refered to as arm):
```bash
docker buildx build --platform linux/arm/v5 -f ev3dev-bullseye/ev3-generic.dockerfile ev3dev-bullseye/
```

To build for both arm32v5 and amd64:
```bash
docker buildx build --platform linux/arm/v5,linux/amd64 -f ev3dev-bullseye/ev3-base.dockerfile ev3dev-b
ullseye/
```

This may require buildx support to build for arm32 on amd64; on Ubuntu it can be installed with: `sudo apt install docker-buildx`. For podman/buildah, I believe there is an environment variable that needs to be set:
```bash
# Enable BuildKit (if it isn't already enabled)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```

For docker, you may also need to enable multiplatform building (and the new containerd format), see: https://docs.docker.com/build/building/multi-platform/

To enable QEMU emulation for building, see: https://www.stereolabs.com/docs/docker/building-arm-container-on-x86

To build the complete system without pulling in ev3dev images:
```bash
BASE_OS="bookworm"
BASE_TAG="ev3dev/ev3dev-${BASE_OS}-ev3-base"
# Currently only supports building for ARM
#docker buildx build --platform linux/arm/v5,linux/amd64 -t "$BASE_TAG" -f ev3dev-"${BASE_OS}"/ev3-base.dockerfile ev3dev-"${BASE_OS}"/
docker buildx build --platform linux/arm/v5 -t "$BASE_TAG" -f ev3dev-"${BASE_OS}"/ev3-base.dockerfile ev3dev-"${BASE_OS}"/
```
