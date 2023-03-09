process call_SPNserotype {

    container 'dreramos/spn:v04'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(fastq_in)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), file("${output_dir}/${sample}/SERO_${sample}*Final__results.txt"), emit: sero_out

    script:
    """
    "${scripts_dir}/bin/SPN_Serotyper.pl" \
    -1 "\$PWD/${fastq_in.get(0)}" -2 "\$PWD/${fastq_in.get(1)}" \
    -r "\$PWD/SPN_Reference_DB/SPN_Sero_Gene-DB_Final.fasta" \
    -n "${sample}" \
    -o "${output_dir}/${sample}"
    """
}