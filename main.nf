nextflow.enable.dsl=2

// import modules for each process
// Each module can define a container, input, output and execution script
// include { <module_name> } from './modules/<module_name>'
include { trim_reads } from './modules/trim_reads.nf'
include { fastqc_trim } from './modules/fastqc_trim.nf'
include { run_MLST } from './modules/run_MLST.nf'
//include { extract_MLST } from './modules/extract_MLST.nf'
//include { call_SPNserotype } from './modules/call_SPNserotype.nf'
include { call_PBPgenetype } from './modules/call_PBPgenetype.nf'
include { predict_bL_MIC } from './modules/predict_bL_MIC.nf'
//include { call_SPNrestype } from './modules/call_SPNrestype.nf'
//include { MIC_SPNrestype } from './modules/MIC_SPNrestype.nf'

workflow {
    
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
    trim_reads(SPNtyping_input_file_ch, params.results_dir)
    //trim_reads.out.view()
    //Channel 
    //.fromFilePairs("${params.results_dir}/cutadapt_*R[1,2]_001.fastq", type: 'file')
    //.set { TRIMMED_READS_ch }

    fastqc_trim(trim_reads.out.reads, params.results_dir)
    //fastqc_trim.out.view()

    run_MLST(trim_reads.out.reads, params.results_dir, params.db_dir)
    
    //extract_MLST(run_MLST.out.mlst_out, params.results_dir, params.db_dir, params.script_dir)
    
    //call_SPNserotype(trim_reads.out.reads, params.results_dir, params.db_dir, params.script_dir)

    call_PBPgenetype(trim_reads.out.reads, params.results_dir, params.db_dir, params.script_dir)

    predict_bL_MIC(trim_reads.out.reads, params.results_dir, params.script_dir)

    //call_SPNrestype(trim_reads.out.reads, params.results_dir, params.db_dir, params.script_dir)

    //MIC_SPNrestype(call_SPNrestype.out.spn_res, params.results_dir, params.script_dir)

    // Create module for parsing final outputs into table (can use expected outputs from analysis modules)

}