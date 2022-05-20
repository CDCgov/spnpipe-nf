process run_MLST {
    
    container 'dreramos/spn-a:v6'
    containerOptions = "--user root"


    input: 
    tuple val(sample), file(fastq_in)
    path(output_dir)
    path(allDB_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/MLST_${sample}__mlst__Streptococcus_pneumoniae__results.txt"), path("${output_dir}/${sample}/MLST_${sample}__*.Streptococcus_pneumoniae.sorted.bam"), emit: mlst_out

    script:
    """
    srst2 --samtools_args '\\-A' --mlst_delimiter '_' \
    --input_pe "${fastq_in.get(0)}" "${fastq_in.get(1)}" \
    --output "${output_dir}/${sample}/MLST_${sample}" --save_scores \
    --mlst_db "${allDB_dir}/Streptococcus_pneumoniae.fasta" \
    --mlst_definitions "${allDB_dir}/spneumoniae.txt" \
    --min_coverage 99.999
    """

}