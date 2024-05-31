process SCANPY_CLUSTER {
    //build container under the same folder first with
    // docker build . -t scintegrator/scanpy_cluster:dev
    container 'docker.io/scintegrator/scanpy_qc:dev'
    publishDir "${params.outdir}/scanpy_cluster", mode: 'copy'

    input:
    path(h5ad)
    path(cluster_nb)

    output:
    path("*.h5ad"), emit: h5ad
    path("*.html"), emit: html
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    //TODO: update code to provide parameters
    """
    #python -m ipykernel install --user --name pipeline_QC
    papermill ${cluster_nb} pipeline_cluster.ipynb \\
    -p species human \\
    jupyter nbconvert --to html pipeline_QC_output.ipynb
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
