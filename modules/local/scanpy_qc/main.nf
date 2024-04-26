process SCANPY_QC {
    conda '${moduleDir}/environment.yml'
    container 'docker.io/scintegrator/scanpy_qc:dev'
    publishDir "${params.outdir}/scanpy_qc", mode: 'copy'

    input:
    tuple val(meta), path(matrix)
    path(qc_nb)

    output:
    tuple val(meta), path("*.h5ad"), emit: h5ad
    tuple val(meta), path("*.html"), emit: html
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    #python -m ipykernel install --user --name pipeline_QC
    papermill ${qc_nb} pipeline_QC_output.ipynb \\
    -p species human \\
    -p subject sub2049 \\
    -p min_genes 33 \\
    -p min_cells 5 \\
    -p pct_mt 15 \\
    -p total_counts 200
    jupyter nbconvert --to html pipeline_QC_output.ipynb
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
