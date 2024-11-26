process ENSEMBL_REF {
    label 'process_medium'
    //build container under the same folder first with
    // docker build . -t scintegrator/scanpy_cluster:dev
    container 'docker.io/immcantation/scintegrator:1.0'
    publishDir "${params.outdir}/scanpy_cluster", mode: 'copy'

    output:
    path("tr_ig_genes_ensembl_v*.csv"), emit: ensembl_tr_ig_genes
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    get_ensembl_ref.py \\
    --species ${params.ensembl_species} \\
    --release ${params.ensembl_release}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
