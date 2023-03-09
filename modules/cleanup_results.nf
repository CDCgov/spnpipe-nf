process cleanup_results {

    container 'dreramos/spn:v04'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(sero_results), file(mlst_results), file(bL_MIC), file(res_mic)
    path(output_dir)

    output:
    file("${output_dir}/TABLE_Isolate_Typing_results.txt") optional true

    script:
    """
    "cleanup_results.sh" "${sample}" "${output_dir}"
    """

}
