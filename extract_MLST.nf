process extract_MLST {
    
    container 'dreramos/spn-a:v6'

    input:
    tuple val(sample), path(mlst_results), path(mlst_bam)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/Check_Target_Sequence.txt")

    script:
    """
    "${scripts_dir}/MLST_allele_checkr.pl \
    "${output_dir}/${sample}/MLST_${sample}__mlst__Streptococcus_pneumoniae__results.txt" \
    "${output_dir}/${sample}/MLST_${sample}__*.Streptococcus_pneumoniae.sorted.bam" \
    "${allDB_dir}/Streptococcus_pneumoniae.fasta"
    """

}