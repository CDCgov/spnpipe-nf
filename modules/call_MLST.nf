process call_MLST {
    
    container 'glevdoug/spn:v06'
    containerOptions = "--user root"


    input: 
    tuple val(sample), file(fastq_in)
    path(output_dir)
    path(allDB_dir)

    output:
    tuple val(sample), file("${output_dir}/${sample}/MLST_${sample}__mlst__Streptococcus_pneumoniae__results.txt")

    // TODO: Automate --threads to improve speed of srst2
    // check ubiquity of grep -c ^processor /proc/cpuinfo 
    script:
    """
    srst2 --samtools_args '\\-A' --mlst_delimiter '_' \
    --input_pe "${fastq_in.get(0)}" "${fastq_in.get(1)}" \
    --output "${output_dir}/${sample}/MLST_${sample}" --save_scores \
    --mlst_db "${allDB_dir}/Streptococcus_pneumoniae.fasta" \
    --mlst_definitions "${allDB_dir}/spneumoniae.txt" \
    --min_coverage 99.999 \
    --threads 4
    """

}