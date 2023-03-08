process trim_reads {

    container 'glevdoug/cutadapt_1.8.3:v1.0'
    containerOptions = "--user root"

    input:
    tuple val(sample), file(fastq_in) 
    path(output_dir)
    path(script_dir)

    output:
    tuple val(sample), file("${output_dir}/${sample}/cutadapt_${sample}*.fastq"), emit: fastq

    script:
    """
    if [ -d "${output_dir}/${sample}" ]; then
        echo "${sample} results directory exists"
    else
        mkdir "${output_dir}/${sample}"
    fi

    cutadapt -b file:${script_dir}/SPN_Reference_DB/SPN-Primers2Trim.fasta \
    -q 20 --minimum-length 50 \
    --paired-output ${output_dir}/${sample}/cutadapt_${sample}_S1_L001_R2_001.fastq -o ${output_dir}/${sample}/cutadapt_${sample}_S1_L001_R1_001.fastq ${fastq_in.get(0)} ${fastq_in.get(1)}
    """ 
    
}
