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

#ensembl
RUN pip install pyensembl
RUN pyensembl install --release 111 --species human

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a

ENV PATH /opt/conda/envs/scanpy_qc/bin:$PATH

#RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager