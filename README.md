[![GitHub Actions CI Status](https://github.com/immunespace/scintegrator/actions/workflows/ci.yml/badge.svg)](https://github.com/immunespace/scintegrator/actions/workflows/ci.yml)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=00SSS0000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

## Introduction

**immunespace/scintegrator** is a bioinformatics pipeline to analyze single-cell RNA-seq (scRNA-seq) data using the **Scanpy** toolkit. It automates key steps of scRNA-seq analysis, such as data preprocessing, integration, clustering, annotation and visualization, enabling efficient and reproducible workflows.

Optionally, if single-cell BCR (scBCR) repertoire data are available, the pipeline can also run a **B cell summary** that integrates the BCR repertoire with the annotated scRNA-seq data and reports isotype usage, clonal expansion, somatic hypermutation and V/J gene usage per B cell subtype.

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
  - Annotation: Annotate identified clusters to known cell types based on marker gene expression using CellTypist.

- **B cell summary (BCELL_SUMMARY)** *(optional)* - Integrates the annotated scRNA-seq object with single-cell BCR (scBCR) repertoire data (AIRR format) and summarizes the B cell repertoire. Runs a parameterized notebook (`bcell_summary.ipynb`) with Papermill and renders an HTML report.
  - scBCR/scRNA integration: Match BCR barcodes to scRNA cells by sample and barcode, and report BCR+/BCR- cells per sample and per lineage (B, T, NK, DC).
  - B cell annotation: Collapse fine-grained CellTypist labels into major cell types and subset B cell subtypes (naive, memory, germinal center, plasma cells, etc.).
  - Marker expression: Dot plots of lineage markers (e.g. MS4A1, CD19, CD3E, GNLY, CST3) split by BCR status.
  - Isotype assignment: Derive the isotype of each cell from the heavy chain constant region (IGHM, IGHD, IGHG, IGHA, IGHE); light chain calls are assigned the cell's heavy chain isotype.
  - Repertoire statistics: Chain counts, isotype usage, clone size, somatic hypermutation frequency (`mu_freq`), CDR3 length, and V/J allele usage, summarized per study, subject, sample, B cell subtype and isotype.
  - Combined output: All summary tables are saved together in a single file (`D3_statistics.db`, SQLite by default; Excel optional).

<!-- TODO nf-core:
   Complete this sentence with a 2-3 sentence summary of what types of data the pipeline ingests, a brief overview of the
   major pipeline sections and the types of output it produces. You're giving an overview to someone new
   to nf-core here, in 15-20 seconds. For an example, see https://github.com/nf-core/rnaseq/blob/master/README.md#introduction
-->

<!-- TODO nf-core: Include a figure that guides the user through the major workflow steps. Many nf-core
     workflows use the "tube map" design for that. See https://nf-co.re/docs/contributing/design_guidelines#examples for examples.   -->
<!-- TODO nf-core: Fill in short bullet-pointed list of the default steps in the pipeline -->



### Input Data

Prepare a samplesheet in CSV format with your single-cell expression data. The file should look like this:

`samplesheet.csv`:

```csv
sample,path_to_h5_file,subject_id,study_id
sample1,sample1.h5,F15,test
sample2,sample2.h5,F15,test
```

- `sample`: Sample identifiers.
- `path_to_h5_file`: h5 file of scRNA-seq data.
- `subject_id`: Subject identifiers.
- `study_id`: Study identifiers.

## Usage

> [!NOTE]
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline) with `-profile test` before running the workflow on actual data.

<!-- TODO nf-core: Describe the minimum required steps to execute the pipeline, e.g. how to prepare samplesheets.
     Explain what rows and columns represent. For instance (please edit as appropriate):

First, prepare a samplesheet with your input data that looks as follows:

`samplesheet.csv`:

```csv
sample,fastq_1,fastq_2
CONTROL_REP1,AEG588A1_S1_L002_R1_001.fastq.gz,AEG588A1_S1_L002_R2_001.fastq.gz
```

Each row represents a fastq file (single-end) or a pair of fastq files (paired end).

-->

Now, you can run the pipeline using:

<!-- TODO nf-core: update the following command to include all required parameters for a minimal example -->

```bash
nextflow run immunespace/scintegrator \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --outdir <OUTDIR>
```

### Run the B cell summary

The B cell summary is optional. To run it as part of the full pipeline, add the scBCR repertoire table:

```bash
nextflow run immunespace/scintegrator \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --scbcr All_samples__repertoire-pass.tsv \
   --outdir <OUTDIR>
```

If you have already run QC and clustering, you can run only the B cell summary from the clustered object. No samplesheet is needed:

```bash
nextflow run immunespace/scintegrator \
   -profile <docker/singularity/.../institute> \
   --scrna concat.h5ad \
   --scbcr All_samples__repertoire-pass.tsv \
   --outdir <OUTDIR>
```

> [!NOTE]
> `--scrna` requires `--scbcr`. Results are written to `<OUTDIR>/bcell_summary/`.

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

### Parameters

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
- --Anno_model [string] Choose the reference model used for CellTypist annotation. Check https://www.celltypist.org/models.

**Bcell summary (optional)**
- --scbcr [string]  scBCR repertoire table in AIRR format (`All_samples__repertoire-pass.tsv`). On its own, runs the B cell summary after the main pipeline.
- --scrna [string]  Clustered AnnData file (`concat.h5ad`). Together with `--scbcr`, runs only the B cell summary, without a samplesheet.
- --bcell_nb [string]  Path to the B cell summary notebook. [default: assets/bcell_summary.ipynb]

**Input/output options**
- --input [string]  Path to comma-separated file containing information about the samples in the experiment.
- --outdir [string]  The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure.
- --email [string]  Email address for completion summary.
- --multiqc_title [string]  MultiQC report title. Printed as page header, used for filename if not otherwise specified.

**Generic options**
- --multiqc_methods_description [string]  Custom MultiQC yaml file containing HTML including a methods description.


### B cell summary (optional)

The B cell summary is optional and only runs when the scBCR repertoire table is provided with `--scbcr`. It combines the clustered, annotated scRNA-seq object (`concat.h5ad`) with the scBCR repertoire table (AIRR format, `All_samples__repertoire-pass.tsv`).

- `concat.h5ad`: its `obs` must contain `sample_id`, `barcode`, `cell_type` (CellTypist labels) and `study_id`.
- `All_samples__repertoire-pass.tsv`: needs at least `sample_id`, `subject_id`, `cell_id`, `locus`, `c_call`, `v_call`, `j_call`, `cdr3`, `clone_id` and `mu_freq`.

There are two ways to run it (see [Run the B cell summary](#run-the-b-cell-summary)):

1. **After the main pipeline**: add `--scbcr`. The summary uses the `concat.h5ad` produced by the clustering step.
2. **On its own**: give both `--scrna` and `--scbcr`. No samplesheet is needed and QC and clustering are skipped.

**Outputs** (published to `<OUTDIR>/bcell_summary/`)

- `statistics/SUBJECT_*.csv`, `statistics/SAMPLE_*.csv` (and `STUDY_*.csv` where generated): summary tables for each grouping level
  - `*_SUMMARY`: BCR counts, light chain pairing, isotype counts and clone size statistics
  - `*_CHAIN_SUMMARY`: mutation frequency and CDR3 length per chain (locus)
  - `*_CHAIN_ISOTYPE_SUMMARY`, `*_CELLTYPE_SUMMARY`, `*_CHAIN_CELLTYPE_SUMMARY`, `*_CHAIN_CELLTYPE_ISOTYPE_SUMMARY`: the same statistics split by isotype and/or B cell subtype
  - `*_VJ_ALLELE`, `*_VJ_ALLELE_CELLTYPE`: V and J allele usage
- `statistics/D3_statistics.db`: all of the tables above in one SQLite file. Subject, sample and study tables are stacked per table name, with a `level` column (`STUDY`, `SUBJECT` or `SAMPLE`) and an `id` column. Setting `OUTPUT_FORMAT = "xlsx"` in the final notebook cell writes `D3_statistics.xlsx` instead, with one sheet per table.
- `All_samples__repertoire-pass_merged.tsv`: the scBCR table merged with scRNA B cell annotations.
- `bcell_summary_out.html`: the executed notebook rendered as an HTML report (plots and tables).

To read the combined file in Python:

```python
import sqlite3, pandas as pd
con = sqlite3.connect("<OUTDIR>/bcell_summary/statistics/D3_statistics.db")
pd.read_sql("SELECT * FROM CHAIN_SUMMARY WHERE level='SAMPLE'", con)
```

## Credits

immunespace/scintegrator was originally written by Jian Xing, Gisela Gabernet.

We thank the following people for their extensive assistance in the development of this pipeline:

<!-- TODO nf-core: If applicable, make list of people who have also contributed -->

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
