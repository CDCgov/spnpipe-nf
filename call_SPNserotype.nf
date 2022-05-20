process call_SPNserotype {

    container 'dreramos/spn-ubuntu:v6'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(fastq_in)
    path(output_dir)
    path(allDB_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/SERO_${sample}*Final__results.txt"), emit: sero_out

    script:
    """
    "${scripts_dir}/SPN_Serotyper.pl" \
    -1 "${fastq_in.get(0)}" -2 "${fastq_in.get(1)}" \
    -r "/scicomp/groups/OID/NCIRD-OD/OI/ncbs/team/GABRIEL/Strep_Container/GitLabDir/strep-containerization/Spn_Scripts_Reference/SPN_Reference_DB/SPN_Sero_Gene-DB_Final.fasta"
    #-r "${allDB_dir}/SPN_Sero_Gene-DB_Final.fasta" \
    -n "${sample}" \
    -o "${output_dir}/${sample}"
    """
}