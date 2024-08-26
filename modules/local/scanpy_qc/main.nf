process SCANPY_QC {
    label 'process_medium'

    //build container under the same folder first with
    // docker build . -t scintegrator/scanpy_qc:dev
    container 'docker.io/scintegrator/scanpy_qc:dev'
    publishDir "${params.outdir}/scanpy_qc", mode: 'copy'

    input:
    path(h5_files)
    path(qc_nb)

    output:
    path("*.h5ad"), emit: h5ad
    path("*.html"), emit: html
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    #python -m ipykernel install --user --name pipeline_QC
    papermill ${qc_nb} pipeline_QC_output.ipynb \\
    -p species ${params.scanpy_species} \\
    -p min_genes ${params.scanpy_min_genes} \\
    -p min_cells ${params.scanpy_min_cells}  \\
    -p pct_mt ${params.scanpy_pct_mt}  \\
    -p total_counts ${params.scanpy_total_counts} 
    jupyter nbconvert --to html pipeline_QC_output.ipynb
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
