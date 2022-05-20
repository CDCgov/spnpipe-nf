process predict_bL_MIC {
    container 'dreramos/spn-ubuntu:v7'
    containerOptions = "--user root"

    input:
    tuple val(sample), path(fastq_in)
    path(output_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/BLACTAM_MIC_RF_with_SIR.txt")

    script:
    """
    #"${scripts_dir}/PBP_AA_sampledir_to_MIC_20171207.sh" "${output_dir}/${sample}" "${scripts_dir}"

    "/scicomp/groups/OID/NCIRD-OD/OI/ncbs/team/GABRIEL/Strep_Container/GitLabDir/strep-containerization/Spn_Scripts_Reference/PBP_AA_sampledir_to_MIC_20180710.sh" "/scicomp/groups/OID/NCIRD-OD/OI/ncbs/team/GABRIEL/Strep_Container/GitLabDir/strep-containerization/test_results/${sample}" "${scripts_dir}"
    """
}