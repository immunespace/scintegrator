process SCANPY_QC {
    label 'process_medium'

    //build container under the same folder first with
    // docker build . -t scintegrator/scanpy_qc:dev
    // container 'docker.io/immcantation/scintegrator:1.2'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://github.com/immunespace/scintegrator/releases/download/v1.2_containers/immcantation-scintegrator-1.2.sif' :
    'docker.io/immcantation/scintegrator:1.2' }"

    publishDir "${params.outdir}/scanpy_qc", mode: 'copy'

    input:
    val(sample_ids)
    // Stage each h5 into its own subdirectory so identical filenames don't collide
    path(h5_files, stageAs: 'input_h5_?/*')
    path(sample_metadata)
    path(qc_nb)

    output:
    path("*.h5ad"), emit: h5ad
    path("*.html"), emit: html
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Link each staged h5 as <sample_id>.h5; the notebook names outputs after the input file
    def h5_list = h5_files instanceof List ? h5_files : [h5_files]
    def link_h5 = [sample_ids, h5_list].transpose()
        .collect { id, h5 -> "ln -s ${h5} ${id}.h5" }
        .join('\n    ')
    """
    ${link_h5}

    #python -m ipykernel install --user --name pipeline_QC
    papermill ${qc_nb} pipeline_QC_out.ipynb \\
    -p scanpy_species ${params.scanpy_species} \\
    -p expected_doublet_rate ${params.expected_doublet_rate} \\
    -p scanpy_min_genes ${params.scanpy_min_genes} \\
    -p scanpy_min_cells ${params.scanpy_min_cells}  \\
    -p scanpy_pct_mt ${params.scanpy_pct_mt}  \\
    -p scanpy_total_counts ${params.scanpy_total_counts}  \\
    -p sample_metadata_path ${sample_metadata}

    jupyter nbconvert --to html pipeline_QC_out.ipynb \\
    --no-input --no-prompt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}
