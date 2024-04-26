process SCANPY_QC {
    conda '${moduleDir}/environment.yml'
    container 'docker.io/scintegrator/scanpy_qc:dev'

    input:
    tuple val(meta), path(matrix)

    output:
    tuple val(meta), path(h5ad), emit: h5ad
    path ""
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    #python -m ipykernel install --user --name pipeline_QC
    papermill ${projectDir}/assets/pipeline_QC.ipynb pipeline_QC_output.ipynb \\
    -p species human \\
    -p subject sub2049 \\
    -p min_genes 33 \\
    -p min_cells 5 \\
    -p pct_mt 15 \\
    -p total_counts 200
    jupyter nbconvert --to html pipeline_QC_output.ipynb
    """
}
