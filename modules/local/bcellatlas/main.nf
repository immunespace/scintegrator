process BCELLATLAS {
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://github.com/immunespace/scintegrator/releases/download/v1.1-containers/immcantation-scintegrator-1.1.sif' :
    'docker.io/immcantation/scintegrator:1.1' }"

    publishDir "${params.outdir}/bcellatlas", mode: 'copy'

    input:
    path(h5ad)
    path(bcellatlas_nb)

    output:
    path("*.ipynb"), emit: notebook
    path("*.html"), emit: html
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    papermill ${bcellatlas_nb} bcellatlas_out.ipynb

    jupyter nbconvert --to html bcellatlas_out.ipynb
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
