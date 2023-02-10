process extract_MLST {
    
    container 'dreramos/spn:v04'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(mlst_results)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    file("${output_dir}/${sample}/Check_Target_Sequence.txt") optional true

    script:
    """
    "MLST_allele_checkr.pl" \
    "${output_dir}/${sample}/MLST_${sample}__mlst__Streptococcus_pneumoniae__results.txt" \
    "${output_dir}/${sample}/MLST_${sample}__*.Streptococcus_pneumoniae.sorted.bam" \
    "${allDB_dir}/Streptococcus_pneumoniae.fasta"
    
    """

}