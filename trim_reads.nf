process trim_reads {

    container 'genomicpariscentre/cutadapt:1.8.3'

    input:
    tuple val(sample), file(fastq_in) 
    path(output_dir)

    output:
    tuple val(sample), path("${output_dir}/${sample}/cutadapt_${sample}*.fastq"), emit: reads

    script:
    """
    if [ -d "${output_dir}/${sample}" ]; then
        echo "${sample} results directory exists"
    else
        mkdir "${output_dir}/${sample}"
    fi

    cutadapt -b file:/scicomp/groups/OID/NCIRD-OD/OI/ncbs/team/GABRIEL/Strep_Container/GitLabDir/strep-containerization/tests/SPN-Primers2Trim.fasta \
    -q 20 --minimum-length 50 \
    --paired-output ${output_dir}/${sample}/cutadapt_${sample}_S1_L001_R2_001.fastq -o ${output_dir}/${sample}/cutadapt_${sample}_S1_L001_R1_001.fastq ${fastq_in.get(0)} ${fastq_in.get(1)}
    """ 
    
}