# In CI this should be the "last"
# version we built
ARG PLASMA_BASE=plasma
ARG PLASMA_VERSION=latest
FROM ${PLASMA_BASE}:${PLASMA_VERSION}

ARG VERSION=v0.0.0-dev-amd

LABEL \
	org.opencontainers.image.authors="Jo Colina <@jsmrcaga>" \
	org.opencontainers.image.version=${VERSION} \
	org.opencontainers.image.title="plasma-amd"

ARG AMD_GCN_VERSION=4.0
ENV AMD_GCN_VERSION=$AMD_GCN_VERSION

# Copy xorg configs before
COPY ./config/video/xorg/xorg.amdgpu.conf /plasma/config/amd/xorg.amdgpu.conf
COPY ./config/video/xorg/xorg.radeon.conf /plasma/config/amd/xorg.radeon.conf

# Install drivers
COPY --chmod=0755 ./src/setup/amd /plasma/setup/amd
RUN bash /plasma/setup/amd/amd.sh

# Install amdgpu_top
ADD --checksum=sha256:4c35d39d6ce6e60cdd453a84d2c494b23bae6a2bd4d1ca99f33b82f778e46d82 \
	https://github.com/Umio-Yasuno/amdgpu_top/releases/download/v0.11.5/amdgpu-top_without_gui_0.11.5-1_amd64.deb \
	/plasma/amdgpu-top.deb

RUN dpkg -i /plasma/amdgpu-top.deb && \
	rm /plasma/amdgpu-top.deb

# Run glmark2 to prime GPU
ENV GPU_PRIME=yes
