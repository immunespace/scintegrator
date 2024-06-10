FROM continuumio/miniconda3:24.3.0-0
LABEL authors="gisela.gabernet@yale.edu"
LABEL description="Docker image containing all requirements for the nfcore/rnaseq pipeline"

# Update system packages and install dependencies
RUN apt-get update \
    && apt-get install -y procps \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Instruct R processes to use these empty files instead of clashing with a local version
RUN touch .Rprofile
RUN touch .Renviron

# Create a non-root user and setup the environment
# RUN groupadd -r appuser && \
#    useradd --no-log-init -r -g appuser appuser && \
#    mkdir -p /home/appuser && \
#    chown -R appuser:appuser /home/appuser

# Set work directory
# WORKDIR /home/appuser

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

ENV PATH /opt/conda/envs/scanpy_qc/bin:$PATH

# Create a cache directory within the user's home and set appropriate ownership
# RUN mkdir -p /home/appuser/.cache && \
#     chown -R appuser:appuser /home/appuser/.cache

# ENV CACHE_DIRECTORY=/home/appuser/.cache
# ENV XDG_CACHE_HOME=/home/appuser/.cache


# RUN python -m ensurepip --upgrade
# RUN python -m pip install --upgrade setuptools
# RUN python -m pip install scimap


