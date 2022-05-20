process MIC_SPNrestype {
    container ''

    input:
    tuple val(sample), path(res_results)
    path(output_dir)
    path(scripts_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/RES-MIC_*")

    script:
    """
    "${scripts_dir}/SPN_Target2MIC.pl" "${res_results}" "${sample}"
    """

}