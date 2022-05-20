process call_SPNrestype {
    container ''

    input:
    tuple val(sample), path(fastq_in)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/OUT_Res_Results.txt"), emit: spn_res

    script:
    """
    "${scripts_dir}/SPN_Res_Typer.pl" \
    -1 "${fastq_in.get(0)}}" -2 "${fastq_in.get(1)}" \
    -d "${allDB_dir}" -r "${allDB_dir}/SPN_Res_Gene-DB_Final.fasta" \
    -n "${sample}" -o "${output_dir}/"${sample}
    """
}