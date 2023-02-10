process target2MIC_SPNrestype {
    
    container 'dreramos/spn:v04'
    containerOptions = "--user root"

    input:
    tuple val(sample), path(res_results)
    path(output_dir)
    path(scripts_dir)

    output:
    tuple val(sample), file("${output_dir}/${sample}/RES-MIC_*")

    script:
    """
    "SPN_Target2MIC.pl" "${res_results}" "${sample}" "${output_dir}/${sample}/"

    """

}