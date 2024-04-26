FROM continuumio/miniconda3:24.3.0-0
LABEL authors="gisela.gabernet@yale.edu" \
      description="Docker image containing all requirements for the nfcore/rnaseq pipeline"
RUN apt-get update \
    && apt-get install -y procps \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Instruct R processes to use these empty files instead of clashing with a local version
RUN touch .Rprofile
RUN touch .Renviron

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/scanpy_qc/bin:$PATH
