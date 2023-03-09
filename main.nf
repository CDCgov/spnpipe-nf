nextflow.enable.dsl=2

// import modules for each process
// Each module can define a container, input, output and execution script(s)

include { trim_reads } from './modules/trim_reads.nf'
include { fastqc_trimmed } from './modules/fastqc_trimmed.nf'
include { call_MLST } from './modules/call_MLST.nf'
include { extract_MLST } from './modules/extract_MLST.nf'
include { call_SPNserotype } from './modules/call_SPNserotype.nf'
include { call_PBPgenetype } from './modules/call_PBPgenetype.nf'
include { predict_bL_MIC } from './modules/predict_bL_MIC.nf'
include { call_SPNrestype } from './modules/call_SPNrestype.nf'
include { target2MIC_SPNrestype } from './modules/target2MIC_SPNrestype.nf'
include { cleanup_results } from './modules/cleanup_results.nf'

workflow {
    
    // TODO: Improve conditional/error handling

    // Catch missing output directory and exit before anything 
    if (params.results_dir == ""){
      println("Please specify a results directory with '--results_dir /path/to/out'")
      System.exit(1)
    }       

    // Creates empty results directory if params.results_dir DNE
    def out_dir = new File(params.results_dir)
    if (!out_dir.exists()) {
      out_dir.mkdir()
    }

    results_dir = file(params.results_dir)

    raw_reads = params.read_dir
    
    Channel
    .fromFilePairs( ["${raw_reads}/*R[1,2]_001.fastq.gz", "${raw_reads}/*_{1,2}.fastq.gz"], type: 'file' ) 
    //.fromPath(params.manifest, checkIfExists: true)
    .set { SPNtyping_input_file_ch }
    
 
    //if (!file(params.db_dir).exists()) {
        // can execute module/process here that checks for latest SPN_Reference_DB
    //    }

    trim_reads(SPNtyping_input_file_ch, results_dir, params.script_dir)
    fastqc_trimmed(trim_reads.out.fastq, results_dir)
    
    call_MLST(trim_reads.out.fastq, results_dir, params.db_dir)
    extract_MLST(call_MLST.out, results_dir, params.db_dir, params.script_dir)
    
    call_SPNserotype(trim_reads.out.fastq, results_dir, params.db_dir, params.script_dir)

    call_PBPgenetype(trim_reads.out.fastq, results_dir, params.db_dir, params.script_dir)
    predict_bL_MIC(call_PBPgenetype.out.pbp_extract, results_dir, params.script_dir)

    call_SPNrestype(trim_reads.out.fastq, results_dir, params.db_dir, params.script_dir)
    target2MIC_SPNrestype(call_SPNrestype.out.spn_res, results_dir, params.script_dir)

    // Group key outputs into single channel for cleanup_results to trigger
    // Join needs a common key (aka input manifest) but is using val(sample) for now
    all_results = call_SPNserotype.out.sero_out
      .join(call_MLST.out)
      .join(predict_bL_MIC.out)
      .join(target2MIC_SPNrestype.out)
    
    cleanup_results(all_results, results_dir)   
}
