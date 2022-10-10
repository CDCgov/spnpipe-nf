process extract_MLST {
    
    container 'dreramos/spn-ubuntu:v8'
    containerOptions = "--user root"

    input:
    tuple val(sample), path(mlst_results), path(mlst_bam)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    // Monkeyfixed multiple output (new/no new MLST alleles) by putting touch command for final output
    // TODO: Setup notifications for results (instead of manually checking log files/results)
    tuple val(sample), path("${output_dir}/${sample}/Check_Target_Sequence.txt")

    script:
    """
    "MLST_allele_checkr.pl" \
    "${output_dir}/${sample}/MLST_${sample}__mlst__Streptococcus_pneumoniae__results.txt" \
    "${output_dir}/${sample}/MLST_${sample}__*.Streptococcus_pneumoniae.sorted.bam" \
    "${allDB_dir}/Streptococcus_pneumoniae.fasta"
    """

}