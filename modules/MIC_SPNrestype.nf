process MIC_SPNrestype {
    
    container 'glevdoug/spn:v06'
    containerOptions = "--user root"

    input:
    tuple val(sample), path(res_results)
    path(output_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/RES-MIC_*")

    script:
    """
    "SPN_Target2MIC.pl" "${res_results}" "${sample}" "${output_dir}/${sample}/"

    """

}