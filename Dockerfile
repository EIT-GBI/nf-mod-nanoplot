ARG DEBIAN_VERSION=13-slim
ARG NANOPLOT_VERSION=1.43.0

# builder #####################################################################

FROM debian:${DEBIAN_VERSION} AS builder

ARG NANOPLOT_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        python3 \
        python3-dev \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

# A venv rather than the system interpreter: Debian marks its python as
# externally managed, and pip into /usr refuses without --break-system-packages.
#
# Two upstream pins, both found by running NanoPlot rather than by --version:
#   kaleido < 1.0  - nanoplotter imports `kaleido.scopes.plotly`, removed in 1.x
#   plotly  < 6    - nanoplotter calls `figure_factory.create_2d_density`,
#                    removed in 6.x, which kills the scatter plot
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir \
        "NanoPlot==${NANOPLOT_VERSION}" \
        "kaleido<1.0" \
        "plotly<6"

# runtime #####################################################################

FROM debian:${DEBIAN_VERSION} AS runtime

ARG DEBIAN_VERSION
ARG NANOPLOT_VERSION

LABEL org.opencontainers.image.title="NanoPlot" \
    org.opencontainers.image.description="NanoPlot on debian:${DEBIAN_VERSION}" \
    org.opencontainers.image.version="${NANOPLOT_VERSION}" \
    org.opencontainers.image.source="https://github.com/wdecoster/NanoPlot" \
    org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/venv/bin:${PATH} \
    LC_ALL=C.UTF-8

# procps for `ps`: Nextflow's task wrapper shells out to it to collect metrics,
# and without it every task dies with
#   Command 'ps' required by nextflow to collect task metrics cannot be found
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        procps \
        python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --from=builder /opt/venv /opt/venv

# No ENTRYPOINT: Nextflow invokes the container as `/bin/bash -c ...`, and an
# ENTRYPOINT of ["NanoPlot"] turns that into `NanoPlot /bin/bash`, which fails.
CMD ["NanoPlot", "--help"]
