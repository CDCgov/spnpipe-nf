process call_SPNrestype {
    container 'dreramos/spn-ubuntu:v8'
    containerOptions = "--user root"

    input:
    tuple val(sample), path(fastq_in)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/OUT_Res_Results.txt"), emit: spn_res

    script:
    """
    cp -r /home/builder/VelvetOptimiser-2.2.6/VelvetOpt/ /usr/local/lib/perl/5.18.2/

    "SPN_Res_Typer.pl" \
    -1 "${fastq_in.get(0)}" -2 "${fastq_in.get(1)}" \
    -d "\$PWD/${allDB_dir}" -r "SPN_Res_Gene-DB_Final.fasta" \
    -n "${sample}" -o "${output_dir}/${sample}"
    """
}