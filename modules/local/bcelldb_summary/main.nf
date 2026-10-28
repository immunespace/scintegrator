process BCELLDB_SUMMARY {
    label 'process_medium'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://github.com/immunespace/scintegrator/releases/download/v1.2_containers/immcantation-scintegrator-1.2.sif' :
    'docker.io/immcantation/scintegrator:1.2' }"
    publishDir "${params.outdir}/bcelldb_summary", mode: 'copy'

    input:
    path(adata)
    path(scbcr)
    path(notebook)

    output:
    path("bcelldb_summary.ipynb"), emit: report
    path("statistics/*"),          emit: stats
    path "versions.yml",           emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    papermill ${notebook} bcelldb_summary.ipynb \\
        -p adata_path ${adata} \\
        -p scbcr_path ${scbcr} \\
        -p outdir statistics

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
