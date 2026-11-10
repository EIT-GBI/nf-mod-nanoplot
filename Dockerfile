FROM mambaorg/micromamba:1.5.8

USER root

# procps for `ps`: Nextflow's task wrapper shells out to it to collect metrics,
# and without it every task dies with
#   Command 'ps' required by nextflow to collect task metrics cannot be found
# The micromamba base is debian-slim and does not carry it. apt, not
# conda-forge::procps-ng, because Nextflow parses real procps output.
RUN apt-get update \
    && apt-get install -y --no-install-recommends procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG NANOPLOT_VERSION=1.43.0

# kaleido must stay below 1.0: NanoPlot's nanoplotter imports
# `kaleido.scopes.plotly`, which 1.x removed. Python is pinned too, since an
# unpinned solve drags in a release NanoPlot has never been tested against.
RUN micromamba install -y -n base -c bioconda -c conda-forge \
        python=3.12 \
        nanoplot=${NANOPLOT_VERSION} \
        'python-kaleido<1.0' \
    && micromamba clean --all --yes

ENV PATH=/opt/conda/bin:${PATH}

CMD ["nanoplot"]
