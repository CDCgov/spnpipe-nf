# SPN NextFlow Pipeline

## Overview  

This project is an ongoing effort to create a unified _Streptococcus pneumoniae_ isolate and filtered-read identification + characterization pipeline. Each sample is characterized by assembly metrics, serotype, MLST and AMR predictions with an emphasis on beta-lactamase resistance genes. The original SPN pipeline, developed by the Strep Lab at the CDC, was refactored for env independence. NextFlow is the workflow manager used to create distinct analysis "modules" wrapped around custom Docker images to maintain software versions for all users. Most relatively modern consumer-level computers can run this pipeline as long as NextFlow and Docker are installed. 

Original SPN pipeline developed by [Ben Metcalf](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference).

## NextFlow Installation
Requirements (from https://www.nextflow.io/docs/latest/getstarted.html);  
Nextflow can be used on any POSIX compatible system (Linux, OS X, etc).  
It requires Bash 3.2 (or later) and Java 11 (or later, up to 18) to be installed.  

Install easily by following below commands to; 
1) Download/configure NextFlow
2) Make the `nextflow` binary executable
3) Move `nextflow` binary to a directory within your `$PATH` (/usr/bin or other)  

`wget -qO- https://get.nextflow.io | bash`  
`chmod +x nextflow` 
`cp nextflow </path/in/your/$PATH>` 

## Docker Installation
Please follow install instructions on https://docs.docker.com/engine/install/ pertaining to your Linux/WSL or MacOS distribution 

## Usage  
Ensure Docker is running by entering `docker --version` in your command line interface. 

Input is expected as Illumina format paired-end raw reads `*R[1,2]_001.fastq.gz` or `*_{1,2}.fastq.gz` within `read_dir` 

Provide your local directories as CLI arguments to run the pipeline;  
```
nextflow run main.nf --read_dir </input/path> --results_dir </output/path> --script_dir </path/to/spnpipe-nf> --db_dir </path/to/spnpipe-nf/SPN_Reference_DB/>  
```
`--read_dir` is the path of your input raw reads  
`--results_dir` is the path specified for output results  
`--script_dir` is the path where this repository lives in your local machine  
`--db_dir` is the path where the reference database lives 

You should now see processes generate in your terminal.

When the pipeline is complete, you should be able to find: `TABLE_Isolate_Typing_results.txt` within your specified `results_dir`  

**Notes:**
- NextFlow produces many intermediary files within it's default work directory. To remove them and free space on your system, you should use `nextflow clean -f` command to remove the latest run.  
- It can be useful to look through a work directory to see logs produced by NextFlow (use `ls -a`)  
- To resume analysis using cached data stored in existing work directories: `nextflow run main.nf -resume`   
 
## Contributing + Standard Notices
To contribute, please refer to [contributing to this repository](https://github.com/CDCgov/template/blob/master/CONTRIBUTING.md).  


[public domain notices and disclaimers](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)  
[code of conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md)
