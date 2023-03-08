# SPN NextFlow Pipeline Test Useage

## NextFlow Installation
Requirements (from https://www.nextflow.io/docs/latest/getstarted.html);  
Nextflow can be used on any POSIX compatible system (Linux, OS X, etc).  
It requires Bash 3.2 (or later) and Java 11 (or later, up to 18) to be installed.  

Install easily by downloading the necessary files, and then moving the `nextflow` binary to a directory within your `$PATH` (/usr/bin or other);  

`wget -qO- https://get.nextflow.io | bash`  
`chmod +x nextflow` 
`cp nextflow </path/in/your/$PATH>` 

## Docker Installation
Please follow install instructions on https://docs.docker.com/engine/install/ pertaining to your Linux or MacOS distribution 

## Usage  
The pipeline expects Illumina format paired-end raw reads `*R[1,2]_001.fastq.gz` or `*_{1,2}.fastq.gz` within `read_dir` 


Run the following command and you should begin to see processes queue on your screen. 
`nextflow run main.nf `   


When the pipeline is complete, you should be able to find: `TABLE_Isolate_Typing_results.txt` within your specified `results_dir`  

NextFlow produces many intermediary files within it's default work directory. To remove them and free space on your system, you should use `nextflow clean -f` command to remove the latest run.  

It can be useful to look through a work directory to see logs produced by NextFlow (use `ls -a`)  
To resume analysis using cached data stored in existing work directories: `nextflow run main.nf -resume`   
 
 
## Contributing + Standard Notices
To contribute, please refer to [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md).  


[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)  
[code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md)
