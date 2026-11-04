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
    path("bcelldb_summary_out.html"), emit: html
    path("statistics/*"),          emit: stats
    path("All_samples__repertoire-pass_merged.tsv"),  emit: merged
    path "versions.yml",           emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    papermill ${notebook} bcelldb_summary_out.ipynb \\
        -p adata_path ${adata} \\
        -p scbcr_path ${scbcr} \\
        -p outdir statistics

    jupyter nbconvert --to html bcelldb_summary_out.ipynb \\
    --no-input --no-prompt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
