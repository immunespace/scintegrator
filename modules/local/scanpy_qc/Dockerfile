FROM continuumio/miniconda3:24.3.0-0
LABEL authors="gisela.gabernet@yale.edu"
LABEL description="Docker image containing all requirements for the nfcore/rnaseq pipeline"

# Update system packages and install dependencies
RUN apt-get update \
    && apt-get install -y procps \
    && apt-get install -y procps g++ \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*



# Instruct R processes to use these empty files instead of clashing with a local version
RUN touch .Rprofile
RUN touch .Renviron


COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

RUN /opt/conda/envs/scanpy_qc/bin/pip install \
    --force-reinstall \
    --no-deps \
    --no-cache-dir \
    "setuptools==70.3.0"

RUN /opt/conda/envs/scanpy_qc/bin/python -c \
    "import pkg_resources; print('pkg_resources OK')" && \
    ls /opt/conda/envs/scanpy_qc/lib/python3.10/site-packages/pkg_resources/

ENV PATH /opt/conda/envs/scanpy_qc/bin:$PATH
