#!/bin/bash -l

# This file contains functions for each software dependency load in SPN-Typer.sh
# The functions are called by the switch case depending on the argument provided.
# This provides modular structure for ease of integration with container environment

# This file will be modified in future development to integrate within the container's software environment 


load_main () {
    module load perl/5.22.1
    module load ncbi-blast+/2.2.29
    module load BEDTools/2.17.0
    module load freebayes/0.9.21
    module load prodigal/2.60
    module load cutadapt/1.8.3
    module load srst2/0.1.7
    module load vcftools
}

unload_main () {
    module unload perl/5.22.1
    module unload ncbi-blast+/2.2.29
    module unload BEDTools/2.17.0
    module unload freebayes/0.9.21
    module unload prodigal/2.60
    module unload cutadapt/1.8.3
    module unload srst2/0.1.7
    module unload vcftools
}

load_fastqc () {
    module load java/latest
    module load fastqc/0.11.5
}

unload_fastqc () {
    module unload java/latest
    module unload fastqc/0.11.5
}

switch_to_perl5.16.1-MT () {
    module unload perl/5.22.1
    module load perl/5.16.1-MT
}

switch_to_perl5.22.1 () {
    module unload perl/5.16.1-MT
    module load perl/5.22.1
}

load_EMBOSS_R () {
    module load EMBOSS/6.4.0
    module load  R/3.3.2
    }

unload_EMBOSS_R () {
    module unload EMBOSS/6.4.0
    module unload  R/3.3.2
}

case $1 in
    load_main)
    load_main
    ;;

    unload_main)
    unload_main
    ;;

    load_fastqc)
    load_fastqc
    ;;

    unload_fastqc)
    unload_fastqc
    ;;

    switch_to_perl5.16.1-MT)
    switch_to_perl5.16.1-MT
    ;;

    switch_to_perl5.22.1)
    switch_to_perl5.22.1
    ;;

    load_EMBOSS_R)
    load_EMBOSS_R
    ;;
    
    unload_EMBOSS_R)
    unload_EMBOSS_R
    ;;
esac