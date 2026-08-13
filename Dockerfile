FROM mambaorg/micromamba:1.5.8

ARG NANOPLOT_VERSION=1.43.0

RUN micromamba install -y -n base -c bioconda -c conda-forge \
        nanoplot=${NANOPLOT_VERSION} \
    && micromamba clean --all --yes

ENV PATH=/opt/conda/bin:${PATH}

CMD ["nanoplot"]
