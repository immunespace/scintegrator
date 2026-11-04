#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    immunespace/scintegrator
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/immunespace/scintegrator
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { SCINTEGRATOR  } from './workflows/scintegrator'
include { BCELL_SUMMARY as BCELL_SUMMARY_ONLY } from './modules/local/bcell_summary/main'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_scintegrator_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_scintegrator_pipeline'

include { getGenomeAttribute      } from './subworkflows/local/utils_nfcore_scintegrator_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// TODO nf-core: Remove this line if you don't need a FASTA file
//   This is an example of how to use getGenomeAttribute() to fetch parameters
//   from igenomes.config using `--genome`
params.fasta = getGenomeAttribute('fasta')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow IMMUNESPACE_SCINTEGRATOR {

    take:
    samplesheet // channel: samplesheet read in from --input

    main:

    //
    // WORKFLOW: Run pipeline
    //
    SCINTEGRATOR (
        samplesheet
    )

    emit:
    multiqc_report = SCINTEGRATOR.out.multiqc_report // channel: /path/to/multiqc_report.html

}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    // the summary always needs the BCR table
    if (params.bcell_scrna && !params.bcell_scbcr) {
        error "--bcell_scrna requires --bcell_scbcr"
    }

    if (params.bcell_scrna && params.bcell_scbcr) {
        //
        // Both files given: summary only, no samplesheet, no QC/clustering
        //
        if (!params.outdir) {
            error "Please provide --outdir"
        }
        BCELL_SUMMARY_ONLY (
            Channel.value(file(params.bcell_scrna, checkIfExists: true)),
            file(params.bcell_scbcr, checkIfExists: true),
            Channel.fromPath(params.bcell_nb, checkIfExists: true).collect()
        )

    } else {
        //
        // SUBWORKFLOW: Run initialisation tasks
        //
        PIPELINE_INITIALISATION (
            params.version,
            params.help,
            params.validate_params,
            params.monochrome_logs,
            args,
            params.outdir,
            params.input
        )

        //
        // WORKFLOW: Run main workflow
        //
        IMMUNESPACE_SCINTEGRATOR (
            PIPELINE_INITIALISATION.out.samplesheet
        )

        //
        // SUBWORKFLOW: Run completion tasks
        //
        PIPELINE_COMPLETION (
            params.email,
            params.email_on_fail,
            params.plaintext_email,
            params.outdir,
            params.monochrome_logs,
            params.hook_url,
            IMMUNESPACE_SCINTEGRATOR.out.multiqc_report
        )
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
