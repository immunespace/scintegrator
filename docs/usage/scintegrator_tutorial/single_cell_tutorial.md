# immunespace/scintegrator: scRNA-seq data processing tutorial

This tutorial provides a step by step introduction on how to run immunespace/scintegrator on single-cell RNA-seq data.

## Introduction

**immunespace/scintegrator** is a bioinformatics pipeline to analyze single-cell RNA-seq (scRNA-seq) data using the **Scanpy** toolkit. It automates key steps of scRNA-seq data analysis, including data preprocessing, integration, clustering, annotation and visualization, enabling efficient and reproducible workflows.

## Pipeline Summary

Each of these steps in the scintegrator pipeline is customizable, allowing researchers to adjust parameters based on the specific characteristics of their dataset and research questions.

- **Scanpy_QC** - Implements preprocessing steps including doublet removal, rigorous Quality Control (QC), and the generation of comprehensive plot reports.
  - **Cell Filtering**: Remove cells that do not meet certain quality metrics, such as a minimum number of genes expressed or an excessive percentage of mitochondrial gene expression.
  - **Gene Filtering**: Exclude genes that are not detected in a sufficient number of cells, which helps in focusing the analysis on biologically relevant data.
  - **Doublet Detection**: Use Scrublet to identify and remove potential doublets from the data, ensuring that each cell analyzed represents a single biological cell.
  - **Data Summarization**: Generate plots of quality metrics to visually assess the quality of the data and the effectiveness of preprocessing steps.

- **Scanpy_Clustering** - Scanpy clustering workflow, including data normalization, log transformation, removal of TR and IG genes, identification of highly variable genes, PCA analysis, cell clustering, data integration and cell type annotation.
  - **Removal of TR and IG Genes**: Exclude T-cell receptor (TR) and immunoglobulin (IG) genes which can skew analysis due to their high variability and cell-type specific expression.
  - **Data Normalization**: Normalize data to make the gene expression profiles more comparable across cells.
  - **Log Transformation**: Apply log transformation to normalize the distribution of gene expression data.
  - **Highly Variable Genes (HVGs) Identification**: Select genes with high variability across cells which are informative for clustering.
  - **Principal Component Analysis (PCA)**: Reduce dimensionality of the dataset to capture the most significant gene expression changes.
  - **Clustering**: Group cells based on similarities in their gene expression profiles using algorithms like Leiden or Louvain.
  - **Data Integration**: Integrate data from different batches or experiments to correct for variations not related to biological differences using Harmony.
  - **Annotation**: Annotate identified clusters to known cell types based on marker gene expression using CellTypist.

## Pre-requisites

You can run this tutorial using the Github Codespaces platform. To create a Codespace instance for immunespace/scintegrator, first click on the button labelled `Code` at the top of [immunespace/scintegrator](https://github.com/immunespace/scintegrator).

In the dropdown menu, go to the `Codespaces` tab. Click the `...` sign, then select `+ New with options...`.

<p align="center">
<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/codespaces_1.png" width="800" alt="Create Codespaces with options">
</p>

After that, you’ll be directed to the configuration page. Select "4-core" for `machine type`, which will give you 4 CPUs, 16GB RAM and 32GB space.

<p align="center">
<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/codespaces_2.png" width="800" alt="Chose 4-core">
</p>

If you want to know more about Codespaces, check [the Codespaces overview](https://docs.github.com/en/codespaces/about-codespaces/what-are-codespaces) or the Codespaces section in nf-core documentation [the Devcontainers overview](https://nf-co.re/docs/tutorials/devcontainer/overview).

When running this tutorial on your local machine, you'll first have to set up Nextflow and a container engine (Docker or Singularity).

> [!NOTE]
> If you want to run this tutorial on your local machine, please refer to [this page](https://nf-co.re/docs/usage/installation) on how to set up Nextflow and a container engine needed to run this pipeline. At the moment, immunespace/scintegrator does NOT support using conda virtual environments for dependency management, only containers are supported. To install Docker, follow the [instructions](https://docs.docker.com/engine/install/). After installation Docker on Linux, don't forget to check the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/).


### Install Nextflow

Once the Codespaces environment is ready, install Nextflow by running the following commands in the terminal:

```bash
curl -s https://get.nextflow.io | bash
mv nextflow /usr/local/bin/
```

You can verify the installation was successful by checking the Nextflow version:

```bash
nextflow -version
```

## Testing the pipeline with built-in tests

Once you have set up Nextflow and container (Docker or Singularity) for your local machine or Codespaces environment, test nf-core/airrflow with the built-in test data.

```bash
nextflow run immunespace/scintegrator -profile test,docker --outdir test_results
```


> [!NOTE]
> Because Codespaces provides limited CPU and RAM resources, the test run may take 10-15 minutes. The process will be faster on systems with greater CPU and RAM capacity.

If the tests run through correctly, you should see this output in your command line:

```bash
-[immunespace/scintegrator] Pipeline completed successfully-
Completed at: 29-May-2026 18:05:59
Duration    : 9m 22s
CPU hours   : 0.3
Succeeded   : 3
```

## Tutorial Data and Results

The complete input data and pre-computed results for this tutorial are publicly available on Zenodo. If you would like to explore the results without running the pipeline yourself, you can download them directly from the link below:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)

> [!TIP]
> Downloading the pre-computed results is recommended if you want to quickly explore the pipeline outputs before committing to a full run.

## Datasets

The input data for this pipeline is in h5 format. The h5 file is the standard output of the Cell Ranger pipeline and can be found at `cellranger/outs/sample_filtered_feature_bc_matrix.h5` after running Cell Ranger on your raw sequencing data. For this tutorial, the sample h5 files are available on [Zenodo](https://doi.org/10.5281/zenodo.XXXXXXX) and the links are already provided in the samplesheet — Nextflow will retrieve the data automatically when running the pipeline.

## Preparing the Samplesheet and Configuration File

To run the pipeline, a comma-separated samplesheet providing the paths to the h5 files must be prepared. The samplesheet collects sample identifiers and experimental details that are important for the data analysis.

The samplesheet should look like this:

`samplesheet.csv`:

| sample | path_to_h5_file | study_id |
|---|---|---|
| sample1 | /path/to/cellranger/outs/sample1_filtered_feature_bc_matrix.h5 | study_A |
| sample2 | /path/to/cellranger/outs/sample2_filtered_feature_bc_matrix.h5 | study_A |

- `sample`: Sample identifiers.
- `path_to_h5_file`: Path to the h5 file output by Cell Ranger, typically found at `cellranger/outs/sample_filtered_feature_bc_matrix.h5`.
- `study_id`: Study identifier for grouping samples.

> [!NOTE]
> When running immunespace/scintegrator with your own data, provide the full absolute path to your h5 input files under the `path_to_h5_file` column.

The resource configuration file sets the compute infrastructure maximum available number of CPUs, RAM memory and running time. This ensures that no pipeline process requests more resources than available in the compute infrastructure where the pipeline is running. The resource config should be provided with the `-c` option. In this example we set the maximum RAM memory to 15GB, restrict the pipeline to use 4 CPUs and allow a maximum runtime of 24 hours.

```json title="resource.config"
process {
    resourceLimits = [ memory: 15.GB, time: 24.h, cpus: 4 ]
}
```

> [!TIP]
> Before setting memory and CPUs in the configuration file, we recommend verifying the available memory and CPUs on your system. Exceeding the system's capacity may result in an error indicating that you requested more CPUs than available or that you have run out of memory. You can also remove the `time` parameter from the configuration file to allow for unlimited runtime for large datasets.

## Running the Pipeline

With all the files ready, you can start the pipeline with the following command:

```bash
nextflow run immunespace/scintegrator \
   -profile docker \
   --input samplesheet.csv \
   --outdir scintegrator_results \
   -c resource.config \
   -resume
```

> [!TIP]
> When launching a Nextflow pipeline with the `-resume` option, any processes that have already been run with the exact same code, settings and inputs will be cached and the pipeline will resume from the last step that changed or failed with an error. We include `-resume` in our Nextflow command as a precaution in case anything goes wrong during execution — after fixing the issue, you can relaunch the pipeline with the same command and it will resume from the point of failure, significantly reducing runtime and resource usage.

> [!WARNING]
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those provided by the `-c` Nextflow option can be used to provide any configuration **except for parameters** — see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).


After launching the pipeline, the following will be printed to the console output, followed by the default parameters used by the pipeline and an execution log of the pipeline processes:

```bash
 N E X T F L O W   ~  version 26.04.2

Launching `./main.nf` [amazing_bernard] revision: 58c415dc5f

------------------------------------------------------
                                        ,--./,-.
        ___     __   __   __   ___     /,-._.--~'
  |\ | |__  __ /  ` /  \ |__) |__         }  {
  | \| |       \__, \__/ |  \ |___     \`-._,-`-,
                                        `._,._,'
  immunespace/scintegrator v1.0
------------------------------------------------------
```

Once the pipeline has finished successfully, the following message will appear:

```bash
-[immunespace/scintegrator] Pipeline completed successfully-
Completed at: 11-Mar-2025 13:18:13
Duration    : 10m 32s
CPU hours   : 0.5
Succeeded   : 28
```

## Parameters

### Scanpy_QC

| Parameter | Type | Description | Default |
|---|---|---|---|
| `--scanpy_species` | string | Species of the data | `human` |
| `--scanpy_min_genes` | integer | Minimum number of genes expressed required for a cell to pass filtering | `300` |
| `--scanpy_min_cells` | integer | Minimum number of cells expressed required for a gene to pass filtering | `5` |
| `--scanpy_pct_mt` | integer | Maximum percentage of counts in mitochondrial genes required for a cell to pass filtering | `20` |
| `--scanpy_total_counts` | integer | Minimum number of total counts required for a cell to pass filtering | `200` |
| `--qc_nb` | string | Path to the QC notebook | `assets/pipeline_QC.ipynb` |

### Scanpy_Clustering

| Parameter | Type | Description | Default |
|---|---|---|---|
| `--expected_doublet_rate` | number | The estimated doublet rate for the data | `0.06` |
| `--ensembl_ig_tr_genes` | string | Immunoglobulin (IG) and T cell receptor (TR) genes list | `assets/tr_ig_genes_ensembl_v111_human.csv` |
| `--ensembl_species` | string | Species of the data | `human` |
| `--clustering_n_neighbors` | integer | Size of local neighborhood used for manifold approximation | `10` |
| `--clustering_n_pcs` | integer | Number of PCs | `40` |
| `--clustering_resolution` | number | The resolution of the clustering | `0.5` |
| `--hvg_min_mean` | number | Cutoff for the min means | `0.0125` |
| `--hvg_max_mean` | integer | Cutoff for the max means | `3` |
| `--hvg_min_disp` | number | Cutoff for the normalized dispersions | `0.5` |
| `--cluster_nb` | string | Path to the clustering notebook | `assets/pipeline_cluster.ipynb` |
| `--Anno_model` | string | Reference model used for CellTypist annotation. See [CellTypist models](https://www.celltypist.org/models) | — |

### Input/Output Options

| Parameter | Type | Description |
|---|---|---|
| `--input` | string | Path to comma-separated file containing information about the samples in the experiment |
| `--outdir` | string | The output directory where the results will be saved. Use absolute paths for cloud infrastructure |
| `--email` | string | Email address for completion summary |
| `--multiqc_title` | string | MultiQC report title. Printed as page header, used for filename if not otherwise specified |


## Understanding the Results

After running the pipeline, several sub-folders are available under the results folder:

```
scintegrator_results/
├── scanpy_qc/
│   ├── pipeline_QC_out.html
│   └── {sample_name}.h5ad
├── scanpy_cluster/
│   ├── pipeline_cluster_out.html
│   └── concat.h5ad
├── multiqc/
└── pipeline_info/
```

The analysis steps and their corresponding output folders are described in detail below:

### 1. Quality Control (`scanpy_qc/`)

The `scanpy_qc/` folder contains two types of output:

- **`<sample_name>_filtered_feature_bc_matrix.h5ad`**: An AnnData h5ad file named after each sample (e.g. `F15_7_filtered_feature_bc_matrix.h5ad`), storing the single-cell expression data after quality control processing. These per-sample h5ad files can be loaded directly in Python with Scanpy for further custom downstream analysis.
- **`pipeline_QC_out.html`**: An interactive HTML report documenting all quality control steps and plots. The following plots are generated to help you assess the quality of your data and the effectiveness of the preprocessing steps:

#### Cell Count Plot
This plot visualizes the count of cells analyzed across different samples after cell filtering that does not meet certain quality metrics, such as a minimum number of genes expressed or an excessive percentage of mitochondrial gene expression.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_cell_count_plot.png" width="400">

#### Number of Genes per Cell Plot
This plot shows the distribution of the number of genes detected in each cell across different samples after excluding genes that are not detected in a sufficient number of cells.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_ngenes_plot.png" width="400">

#### Percentage of Mitochondrial Genes Plot
This plot displays the percentage of mitochondrial genes found in each cell across samples after filtering the cells with a high percentage of mitochondrial genes.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_pct_counts_mt_plot.png" width="400">

#### Total Counts vs. Number of Genes
This plot visualizes the relationship between the total number of transcript counts and the number of genes detected in cells across samples that have passed all quality controls.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_totalcounts_ngenes.png" width="600">

#### Number of Genes vs. Percentage of Mitochondrial Genes
This plot compares the number of genes per cell with the percentage of mitochondrial genes across samples that have passed all quality controls.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_ngenes_pctcountsmt.png" width="600">

### 2. Clustering and Annotation (`scanpy_cluster/`)

The `scanpy_cluster/` folder contains two types of output:

- **`concat.h5ad`**: A single merged AnnData h5ad file containing all samples after clustering and cell type annotation. This file stores the fully processed dataset including cluster assignments, Harmony batch-corrected embeddings, UMAP coordinates, and CellTypist annotations, and can be loaded directly in Python with Scanpy for further custom downstream analysis.
- **`pipeline_cluster_out.html`**: An interactive HTML report documenting all clustering and annotation steps and plots. The Scanpy clustering step performs data normalization, log transformation, removal of TR and IG genes, identification of highly variable genes, PCA analysis, cell clustering, batch integration with Harmony, and cell type annotation with CellTypist. The following plots are generated:

#### Highly Variable Genes
This plot shows the genes selected as highly variable across cells, which are used as the basis for dimensionality reduction and clustering.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_highly_variable_genes.png" width="400">

#### Clustering and Cell Type Annotation
This UMAP plot displays the identified cell clusters and their corresponding CellTypist annotations, allowing you to explore the cell type composition of your dataset.

<img src="https://raw.githubusercontent.com/immunespace/scintegrator/master/docs/images/F15_clustering.png" width="1000">

### 3. MultiQC (`multiqc/`)

A MultiQC report summarizing QC metrics across all samples. This report aggregates quality metrics from the whole pipeline into a single interactive HTML report.

### 4. Pipeline Info (`pipeline_info/`)

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors and provide information such as launch commands, run times and resource usage. The following files are produced:

- `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`: Reports generated by Nextflow.
- `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`: Reports generated by the pipeline. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameters are used when running the pipeline.
- `samplesheet.valid.csv`: Reformatted samplesheet files used as input to the pipeline.
- `params.json`: Parameters used by the pipeline run.


## Subsetting B Cell Populations

After the pipeline has completed, you may want to subset specific cell populations from the fully annotated `concat.h5ad` file for further downstream analysis. The following Python script shows how to extract all B cell populations from the dataset using Scanpy:

```python
import scanpy as sc

# Load the annotated data
adata = sc.read_h5ad('scintegrator_results/scanpy_cluster/concat.h5ad')

# Define B cell populations
b_cell_types = [
    'Age-associated B cells',
    'B cells',
    'Cycling B cells',
    'Follicular B cells',
    'Germinal center B cells',
    'Large pre-B cells',
    'Memory B cells',
    'Naive B cells',
    'Plasma cells',
    'Plasmablasts',
    'Pre-pro-B cells',
    'Pro-B cells',
    'Proliferative germinal center B cells',
    'Small pre-B cells',
    'Transitional B cells'
]

# Subset B cells
adata_bcells = adata[adata.obs['cell_type'].isin(b_cell_types)].copy()

# Save the B cell subset
adata_bcells.write_h5ad('scintegrator_results/scanpy_cluster/concat_bcells.h5ad')

print(f"Total cells: {adata.n_obs}")
print(f"B cells subset: {adata_bcells.n_obs}")
```

The resulting `concat_bcells.h5ad` file contains only the B cell populations and can be used for further B cell-specific downstream analyses such as re-clustering, differential expression, or trajectory analysis.

> [!TIP]
> You can adapt this script to subset any other cell population of interest by modifying the `b_cell_types` list with the cell type labels present in your dataset. To see all available cell types in your data, run:
> ```python
> print(adata.obs['cell_type'].unique().tolist())
> ```


```
nextflow run nf-core/scrnaseq \
   -profile <docker/singularity/.../institute> \
   --input samplesheet.csv \
   --genome_fasta GRCm38.p6.genome.chr19.fa \
   --gtf gencode.vM19.annotation.chr19.gtf \
   --aligner cellranger \
   --outdir
```
