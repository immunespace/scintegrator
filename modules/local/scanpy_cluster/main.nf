process SCANPY_CLUSTER {
    label 'process_medium'
    //build container under the same folder first with
    // docker build . -t scintegrator/scanpy_cluster:dev
    container 'docker.io/immcantation/scintegrator:1.0'
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
    -p ensemble_species ${params.ensembl_species} \\
    -p ensemble_release ${params.ensembl_release} \\
    -p ensembl_cache ${params.ensembl_cache} \\
    -p clustering_n_neighbors ${params.clustering_n_neighbors} \\
    -p clustering_n_pcs ${params.clustering_n_pcs} \\
    -p clustering_resolution ${params.clustering_resolution} \\
    -p hvg_min_mean ${params.hvg_min_mean} \\
    -p hvg_max_mean ${params.hvg_max_mean} \\
    -p hvg_min_disp ${params.hvg_min_disp}
    jupyter nbconvert --to html pipeline_cluster_out.ipynb
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
