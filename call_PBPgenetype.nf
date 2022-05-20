process call_PBPgenetype {
    container 'dreramos/spn-ubuntu:v7'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(fastq_in)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/EXTRACT*.fasta")

    script:
    """
    "${scripts_dir}/PBP-Gene_Typer.pl" \
    -1 "${fastq_in.get(0)}" -2 "${fastq_in.get(1)}" \
    -r "${allDB_dir}/MOD_bLactam_resistance.fasta" \
    -n "${sample}" -s SPN -p 1A,2B,2X \
    -o "${output_dir}/${sample}"
    """
}