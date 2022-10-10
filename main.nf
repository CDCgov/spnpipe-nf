nextflow.enable.dsl=2

// import modules for each process
// Each module can define a container, input, output and execution script
// include { <module_name> } from './modules/<module_name>'
include { trim_reads } from './modules/trim_reads.nf'
include { fastqc_trimmed } from './modules/fastqc_trimmed.nf'
include { call_MLST } from './modules/call_MLST.nf'
include { extract_MLST } from './modules/extract_MLST.nf'
include { call_SPNserotype } from './modules/call_SPNserotype.nf'
include { call_PBPgenetype } from './modules/call_PBPgenetype.nf'
include { predict_bL_MIC } from './modules/predict_bL_MIC.nf'
include { call_SPNrestype } from './modules/call_SPNrestype.nf'
include { MIC_SPNrestype } from './modules/MIC_SPNrestype.nf'

workflow {
    
    // handle output directory 
    // if not exist, then make based on execution directory 
    raw_reads = params.read_dir

    Channel
    .fromFilePairs("${raw_reads}/*R[1,2]_001.fastq.gz", type: 'file')
    //.fromPath(params.manifest, checkIfExists: true)
    .set { SPNtyping_input_file_ch }
    
    // Automate database updates here
    //if (!file(params.db_dir).exists()) {
        // can execute module/process here that checks for latest SPN_Reference_DB
    //    }

    //SPNtyping_input_file_ch.subscribe { println "Got: $it" }
    trim_reads(SPNtyping_input_file_ch, params.results_dir, params.script_dir)
    fastqc_trimmed(trim_reads.out.fastq, params.results_dir)
    
    call_MLST(trim_reads.out.fastq, params.results_dir, params.db_dir)
    extract_MLST(call_MLST.out.mlst_out, params.results_dir, params.db_dir, params.script_dir)
    
    call_SPNserotype(trim_reads.out.fastq, params.results_dir, params.db_dir, params.script_dir)

    call_PBPgenetype(trim_reads.out.fastq, params.results_dir, params.db_dir, params.script_dir)
    predict_bL_MIC(call_PBPgenetype.out.pbp_extract, params.results_dir, params.script_dir)

    call_SPNrestype(trim_reads.out.fastq, params.results_dir, params.db_dir, params.script_dir)
    MIC_SPNrestype(call_SPNrestype.out.spn_res, params.results_dir, params.script_dir)

}
