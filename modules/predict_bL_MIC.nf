process predict_bL_MIC {
    container 'dreramos/r-centos7:v01'
    containerOptions = "--user root"

    input:
    tuple val(sample), path(pbp_extract)
    path(output_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/BLACTAM_MIC_RF_with_SIR.txt")

    script:
    """
    # Cleanup temp dir used for NextFlow
    if [ -d "${output_dir}/${sample}/temp_PBP" ]; then
        rm -r "${output_dir}/${sample}/temp_PBP"
    fi

    "PBP_AA_sampledir_to_MIC_20180710.sh" "\$PWD/${output_dir}/${sample}" "\$PWD/${scripts_dir}"

    """
}