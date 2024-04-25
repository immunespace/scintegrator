process SCANPY_QC {
    conda "${moduleDir}/environment.yml"

    input:
    tuple val(meta), path(matrix)

    output:
    tuple val(meta), path(h5ad), emit: h5ad
    path  "versions.yml"       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    jupyter nbconvert --to notebook --execute pipeline_QC.ipynb
    """
}
