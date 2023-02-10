process fastqc_trimmed {

    container 'glevdoug/fastqc_0.11.5:v1.0'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(fastq_in)
    path(output_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}_cut/cutadapt_${sample}*fastqc.zip")

    script:
    """
    if [ -d "${output_dir}/${sample}_cut" ]; then
        echo "FASTQC Output directory exists"
    else
        mkdir "${output_dir}/${sample}_cut"
    fi
    fastqc "${output_dir}/${sample}/cutadapt_${sample}_S1_L001_R1_001.fastq" --outdir="${output_dir}/${sample}_cut"
    fastqc "${output_dir}/${sample}/cutadapt_${sample}_S1_L001_R2_001.fastq" --outdir="${output_dir}/${sample}_cut"
    """

}