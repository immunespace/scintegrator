[![GitHub Actions CI Status](https://github.com/immunespace/scintegrator/actions/workflows/ci.yml/badge.svg)](https://github.com/immunespace/scintegrator/actions/workflows/ci.yml)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=00SSS0000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**immunespace/scintegrator** is a bioinformatics pipeline to analyze single-cell RNA-seq (scRNA-seq) data using the **Scanpy** toolkit. It automates key steps of scRNA-seq analysis, such as data preprocessing, integration, clustering, annotation and visualization, enabling efficient and reproducible workflows.

## Pipeline summary

Each of these steps in scintegration pipeline is customizable, allowing researchers to adjust parameters based on the specific characteristics of their dataset and research questions.

- **Scanpy_QC** - Detail the preprocessing steps implemented in Scanpy, including doublet removal, rigorous Quality Control (QC), and the generation of comprehensive plot reports.
  - Cell Filtering: Remove cells that do not meet certain quality metrics, such as a minimum number of genes expressed or an excessive percentage of mitochondrial gene expression.
  - Gene Filtering: Exclude genes that are not detected in a sufficient number of cells, which helps in focusing the analysis on biologically relevant data.
  - Doublet Detection: Use Scrublet to identify and remove potential doublets from the data, ensuring that each cell analyzed represents a single biological cell.
  - Data Summarization: Generate plots of quality metrics to visually assess the quality of the data and the effectiveness of preprocessing steps.

- **Scanpy_Clustering** - Scanpy clustering workflow, including data normalization, log transformation, removal of TR and IG genes, identification of highly variable genes, PCA analysis, cell clustering, data integrtion and cell type annotation.
  - Removal of TR and IG Genes: Exclude T-cell receptor (TR) and immunoglobulin (IG) genes which can skew analysis due to their high variability and cell-type specific expression.
  - Data Normalization: Normalize data to make the gene expression profiles more comparable across cells.
  - Log Transformation: Apply log transformation to normalize the distribution of gene expression data.
  - Highly Variable Genes (HVGs) Identification: Select genes with high variability across cells which are informative for clustering.
  - Principal Component Analysis (PCA): Reduce dimensionality of the dataset to capture the most significant gene expression changes.
  - Clustering: Group cells based on similarities in their gene expression profiles using algorithms like Leiden or Louvain.
  - Data Integration: Integrate data from different batches or experiments to correct for variations not related to biological differences using Harmony.
  - Annotation: Annotate identified clusters to known cell types based on marker gene expression.

## Quickstart

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow and a container engine such as docker or apptainer. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

First, prepare a samplesheet in CSV format with your single-cell expression data in `h5` format. The file should look like this:

`samplesheet.csv`:

```csv
sample_id,path,study_id
sample1,sample1.h5,test
sample2,sample2.h5,test
```

- `sample`: Sample identifiers.
- `path`: path to h5 file of scRNA-seq data.
- `study_id`: Cumstom study name. 


Now, you can run the pipeline using:

```bash
nextflow run immunespace/scintegrator \
   -profile docker \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

For further usage details, please refer to the [Usage](./docs/usage.md) documentation.
To understand the pipeline outputs, please refer to the [Output](./docs/output.md) documentation.
A full list of the pipeline parameters is available in the next section.

### Parameters

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

**Scanpy_QC**
- --scanpy_species [string] Species of the data. [default: human]
- --scanpy_min_genes [integer] Minimum number of genes expressed required for a cell to pass filtering. [default: 300]
- --scanpy_min_cells [integer] Minimum number of cells expressed required for a gene to pass filtering. [default: 5]
- --scanpy_pct_mt [integer] Maximun percentage of counts in mitochondrial genes required for a cell to pass filtering.  [default: 20]
- --scanpy_total_counts [integer] Minimum number of the total counts required for a cell to pass filtering. [default: 200]
- --qc_nb [string]  Path to the qc notebook. [default: assets/pipeline_QC.ipynb]

**Scanpy_clustering**
- --expected_doublet_rate [number]  The estimated doublet rate for the data. [default: 0.06]
- --ensembl_ig_tr_genes [string]  Immunogloblin (IG) and T cell receptor (TR) genes list. [default: assets/tr_ig_genes_ensembl_v111_human.csv]
- --ensembl_species [string]  Species of the data. [default: human]
- --clustering_n_neighbors [integer] Size of local neighborhood used for manifold approximation. [default: 10]
- --clustering_n_pcs [integer] Number of PCs. [default: 40]
- --clustering_resolution [number]  The resolution of the clustering. [default: 0.5]
- --hvg_min_mean [number]  Cutoff for the min means. [default: 0.0125]
- --hvg_max_mean [integer] Cutoff for the max means. [default: 3]
- --hvg_min_disp [number]  Cutoff for the normalized dispersions. [default: 0.5]
- --cluster_nb [string]  Path to the clustering notebook. [default: assets/pipeline_cluster.ipynb]

**Input/output options**
- --input [string]  Path to comma-separated file containing information about the samples in the experiment.
- --outdir [string]  The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure.
- --email [string]  Email address for completion summary.
- --multiqc_title [string]  MultiQC report title. Printed as page header, used for filename if not otherwise specified.

**Generic options**
- --multiqc_methods_description [string]  Custom MultiQC yaml file containing HTML including a methods description.


## Credits

immunespace/scintegrator was originally written by Jian Xing, Gisela Gabernet.

<!-- We thank the following people for their extensive assistance in the development of this pipeline: -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

## Citations

<!-- TODO nf-core: Add citation for pipeline after first release. Uncomment lines below and update Zenodo doi and badge at the top of this file. -->
<!-- If you use immunespace/scintegrator for your analysis, please cite it using the following doi: [10.5281/zenodo.XXXXXX](https://doi.org/10.5281/zenodo.XXXXXX) -->

<!-- TODO nf-core: Add bibliography of tools and data used in your pipeline -->

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).


<!--nextflow run immunespace/scintegrator \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR> -->