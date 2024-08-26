process SCANPY_CLUSTER {
    label 'process_medium'
    //build container under the same folder first with
    // docker build . -t scintegrator/scanpy_cluster:dev
    container 'docker.io/scintegrator/scanpy_qc:dev'
    publishDir "${params.outdir}/scanpy_cluster", mode: 'copy'

    input:
    path(h5ad)
    path(qc_nb)

    output:
    path("*.h5ad"), emit: h5ad
    path("*.html"), emit: html
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    //TODO: update code to provide parameters
    """
    papermill ${qc_nb} pipeline_cluster_out.ipynb \\
    -p ensemble_release ${params.ensembl_release} \\
    -p ensembl_cache ${params.ensembl_cache} \\
    -p n_neighbors ${params.n_neighbors} \\
    jupyter nbconvert --to html pipeline_cluster_out.ipynb
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
