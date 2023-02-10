process call_PBPgenetype {
    container 'dreramos/spn:v04'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(fastq_in)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/temp_PBP/EXTRACT_*.fasta"), emit: pbp_extract

    script:
    """
    cp -r /opt/VelvetOptimiser-2.2.6/VelvetOpt/ /usr/share/perl/5.30.0

    "PBP-Gene_Typer.pl" \
    -1 "\$PWD/${fastq_in.get(0)}" -2 "\$PWD/${fastq_in.get(1)}" \
    -r "\$PWD/SPN_Reference_DB/MOD_bLactam_resistance.fasta" \
    -n "${sample}" -s SPN -p 1A,2B,2X \
    -o "${output_dir}/${sample}";

    if [ ! -d "${output_dir}/${sample}/temp_PBP" ]; then
        mkdir "${output_dir}/${sample}/temp_PBP"
    fi
    cp "${output_dir}/${sample}/EXTRACT_"*.fasta "${output_dir}/${sample}/temp_PBP/"
    """
}