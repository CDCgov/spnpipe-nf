#!/bin/bash -l

#. /usr/share/Modules/init/bash

## This refactor takes out the reliance on a job-control file in order to run samples sans HPC
###This wrapper script validates the input arguments and creates the job-control.txt file which is needed to submit the qsub array job to the cluster.###

## getopts should be native in linux installation. Can keep for now and switch to $@ if necessary
while getopts :s:r:o: option
do
    case $option in
        s) batch_dir=$OPTARG;;
        r) allDB_dir=$OPTARG;;
        o) output_dir=$OPTARG;;
    esac
done

## Batch and reference database directories can stay until the container folder structure is forged
###Check if batch directory and reference database directory arguments were given and if they exist###
if [[ ! -z "$batch_dir" ]]
then
    if [[ -d "$batch_dir" ]]
    then
        batch_dir=$(echo "$batch_dir" | sed 's/\/$//g')
        echo "The sequence directory is in the following location: $batch_dir"
    else
        echo "This sequence directory is not in the correct format or doesn't exist."
        echo "Make sure you provide the full directory path (/root/path/sequence_directory)."
        exit 1
    fi
else
    echo "No sequence data directory path argument given."
    exit 1
fi

# Keeping this in-case any bioinformatics user wishes to supply their own
# Container will default to Spn_Scripts_Reference/SPN_Reference_DB
if [[ ! -z "$allDB_dir" ]]
then
    if [[ -d "$allDB_dir" ]]
    then
        allDB_dir=$(echo "$allDB_dir" | sed 's/\/$//g')
        echo "The references directory is in the following location: $allDB_dir"
    else
        echo "This reference directory is not in the correct format or doesn't exist."
        echo "Make sure you provide the full directory path (/root/path/reference_directory)."
        exit 1
    fi
else
    echo "No reference database directory path argument given."
    exit 1
fi

## Default output directory will follow git repo structure as home ~ for easier container deployment
# Figure out where wrapr is run to determine if $(pwd -P) is okay

# One liner which will return the directory of wherever the script is run
START_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

###Check if the output directory argument has been given. If yes, create the 'GBS_Typing_Output' and 'qsub_files' folders within the output dir###
###If no, output the results into the directory where this script was invoked. The subdirectory name is extracted from the batch sequence full path###
if [[ -z "$output_dir" ]]
then
    echo "The files will be output into the default directory 'SPN_Typing_Analysis'."
    if [[ ! -d "${START_DIR}/SPN_Typing_Analysis" ]]
    then
        mkdir "${START_DIR}/SPN_Typing_Analysis"
        out_dir="${START_DIR}/SPN_Typing_Analysis"
        eval out_dir=$out_dir
        echo "The output directory has been created: $out_dir"
    else
        out_dir="${START_DIR}/SPN_Typing_Analysis"
        eval out_dir=$out_dir
    fi

    batch_name=$(echo "$batch_dir" | awk -F"/" '{print $(NF-3)}')
    out_analysis="${out_dir}"/"${batch_name}"/SPN_Typing_Output
    eval out_analysis=$out_analysis

    # Refactored out to not rely on HPC for any external user to use
    #out_qsub="${out_dir}"/"${batch_name}"/qsub_files/
    #eval out_qsub=$out_qsub
    # Utilize job control to iterate through sample paths
    out_jobCntrl="${out_dir}/${batch_name}"
    

    eval out_jobCntrl=$out_jobCntrl
    mkdir -p "$out_analysis"

    # Check where this is needed and refactor
    #mkdir -p "$out_qsub"

elif [[ ! -d "$output_dir" ]]
then
    output_dir=$(echo "$output_dir" | sed 's/\/$//g')
    mkdir "$output_dir"
    out_dir="$output_dir"
    eval out_dir=$out_dir
    echo "The output directory has been created: $out_dir"
    out_analysis="${out_dir}"/SPN_Typing_Output
    eval out_analysis=$out_analysis
    
    # Refactored out
    out_jobCntrl="${out_dir}/"
    eval out_jobCntrl=$out_jobCntrl
    mkdir -p "$out_analysis"
    #out_qsub="${out_dir}"/qsub_files/
    #eval out_qsub=$out_qsub
    #mkdir -p "$out_qsub"
else
    output_dir=$(echo "$output_dir" | sed 's/\/$//g')
    out_dir="$output_dir"
    eval out_dir=$out_dir
    out_analysis="${out_dir}"/SPN_Typing_Output
    eval out_analysis=$out_analysis

    # Refactored out
    out_jobCntrl="${out_dir}/"
    eval out_jobCntrl=$out_jobCntrl
    mkdir -p "$out_analysis"
    #out_qsub="${out_dir}"/qsub_files/
    #eval out_qsub=$out_qsub
    #mkdir -p "$out_qsub"
fi

###Create the batch output files###

# Redundant
#batch_name=$(echo "$batch_dir" | awk -F"/" '{print $(NF-3)}')
#printf "Sample\tSerotype\tPili\tST\taroe\tgdh\tgki\trecP\tspi\txpt\tddl\tPBP1A\tPBP2B\tPBP2X\tPEN_SIGN\tPEN\tAMO_SIGN\tAMO\tMER_SIGN\tMER\tTAX_SIGN\tTAX\tCFT_SIGN\tCFT\tCFX_SIGN\tCFX\tEC\tCot\tTet\tFQ\tOther\n" >> "$out_analysis"/TABLE_SPN_"$batch_name"_Typing_Results.txt
printf "Sample\tWGS_Serotype\tPili\tST\taroe\tgdh\tgki\trecP\tspi\txpt\tddl\tPBP1A\tPBP2B\tPBP2X\
\tWGS_PEN_SIGN\tWGS_PEN\tWGS_PEN_SIR_Meningitis\tWGS_PEN_SIR_Nonmeningitis\tWGS_AMO_SIGN\tWGS_AMO\
\tWGS_AMO_SIR\tWGS_MER_SIGN\tWGS_MER\tWGS_MER_SIR\tWGS_TAX_SIGN\tWGS_TAX\tWGS_TAX_SIR_Meningitis\
\tWGS_TAX_SIR_Nonmeningitis\tWGS_CFT_SIGN\tWGS_CFT\tWGS_CFT_SIR_Meningitis\tWGS_CFT_SIR_Nonmeningitis\
\tWGS_CFX_SIGN\tWGS_CFX\tWGS_CFX_SIR\tWGS_AMP_SIGN\tWGS_AMP\tWGS_AMP_SIR\tWGS_CPT_SIGN\tWGS_CPT\
\tWGS_CPT_SIR\tWGS_ZOX_SIGN\tWGS_ZOX\tWGS_ZOX_SIR\tWGS_FOX_SIGN\tWGS_FOX\tWGS_FOX_SIR\tEC\tWGS_ERY_SIGN\
\tWGS_ERY\tWGS_ERY_SIR\tWGS_CLI_SIGN\tWGS_CLI\tWGS_CLI_SIR\tWGS_SYN_SIGN\tWGS_SYN\tWGS_SYN_SIR\
\tWGS_LZO_SIGN\tWGS_LZO\tWGS_LZO_SIR\tWGS_ERY/CLI\tCot\tWGS_COT_SIGN\tWGS_COT\tWGS_COT_SIR\tTet\
\tWGS_TET_SIGN\tWGS_TET\tWGS_TET_SIR\tWGS_DOX_SIGN\tWGS_DOX\tWGS_DOX_SIR\tFQ\tWGS_CIP_SIGN\tWGS_CIP\
\tWGS_CIP_SIR\tWGS_LFX_SIGN\tWGS_LFX\tWGS_LFX_SIR\tOther\tWGS_CHL_SIGN\tWGS_CHL\tWGS_CHL_SIR\tWGS_RIF_SIGN\
\tWGS_RIF\tWGS_RIF_SIR\tWGS_VAN_SIGN\tWGS_VAN\tWGS_VAN_SIR\tWGS_DAP_SIGN\tWGS_DAP\tWGS_DAP_SIR\tContig_Num\
\tN50\tLongest_Contig\tTotal_Bases\tReadPair_1\tContig_Path\n" >> "$out_analysis"/TABLE_SPN_"$batch_name"_Typing_Results.txt

# Check uses standard Illumina fastq naming convention. Will exit out earlier if batch_dir DNE
###Will search thru every file in the batch directory and check if it matches the following regexs: _L.*_R1_001.fastq and _L.*_R2_001.fastq###
###If both paired end fastq files are found then the full paths of each file will be written to the 'job-control.txt' file###
batch_dir_star="${batch_dir}/*"
for sample in $batch_dir_star
do
    if [[ "$sample" =~ _S[0-9]+_L[0-9]+_R._001.fastq ]]
    then
	sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_S[0-9]\+\_.*_001.fastq.gz//g')
    elif [[ "$sample" =~ _[1|2].fastq.gz ]]
    then
	sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_[1|2].fastq.gz//g')
    fi
    sampl_out="${out_analysis}"/"${sampl_name}"
    eval sampl_out=$sampl_out
    echo The sample file is: $sample

    # Where does Undetermined come from?
    if [[ $sampl_name =~ ^Undetermined ]]
    then
	echo "Skipping the 'Undetermined' fastq files"
	continue
    fi

    # Should stay the same
    if [[ $sample =~ _L.*_R1_001.fastq && ! $sample =~ S[0-9]+ ]]
    then
	readPair_1=$(echo "$sample" | sed 's/_L\([0-9]\+\)_R1/_S1_L\1_R1/g')
	mv $sample $readPair_1
    elif [[ $sample =~ _L.*_R1_001.fastq && $sample =~ S[0-9]+ ]]
    then
	readPair_1=$sample
    elif [[ $sample =~ .*_1.fastq.gz ]]
    then
	readPair_1=$sample
    fi

    if [[ $sample =~ _L.*_R2_001.fastq && ! $sample =~ S[0-9]+ ]]
    then
	readPair_2=$(echo "$sample" | sed 's/_L\([0-9]\+\)_R2/_S1_L\1_R2/g')
	mv $sample $readPair_2
    elif [[ $sample =~ _L.*_R2_001.fastq && $sample =~ S[0-9]+ ]]
    then
	readPair_2=$sample
    elif [[ $sample =~ .*_2.fastq.gz ]]
    then
	readPair_2=$sample
    fi

    # The purpose of this loop is to confirm the existence of Illumina PE reads;
    # Then echo path data to job-control
    if [ -n "$readPair_1" -a -n "$readPair_2" ]
    then
	    if [[ ! -d "$sampl_out" ]]
	    then
	        mkdir "$sampl_out"
	    fi
	    echo "Both Forward and Reverse Read files exist."
	    echo "Paired-end Read-1 is: $readPair_1"
	    echo "Paired-end Read-2 is: $readPair_2"
	    printf "\n"

        # Keep job-control.txt for simple distribution of fastq pathing
	    echo "$readPair_1 $readPair_2 $allDB_dir $out_analysis $sampl_out" >> $out_jobCntrl/job-control.txt
        ###Prepare script for next sample###
	    readPair_1=""
	    readPair_2=""
    fi
done

###Send the jobs out on the cluster with each sample running in parallel###
#qsub -sync y -q dbd.q -t 1-$(cat $out_jobCntrl/job-control.txt | wc -l) -cwd -o "$out_qsub" -e "$out_qsub" ./StrepLab-JanOw_SPN-Typer.sh $out_jobCntrl

# Starting out with linear job distribution.
# Next step would be to find a good balance for background jobs with & / wait 
BATCH_LEN=$(wc -l ${out_jobCntrl}/job-control.txt | grep -Eo "[0-9]+")

# Remove linearflow.sh if present
if [[ -f "./linearflow.sh" ]]; then
    rm "./linearflow.sh"
fi

# Initialize flow script
echo "#!/bin/bash -l" >> linearflow.sh

seq 1 $BATCH_LEN | while IFS= read -r line_num; 
do

    echo "$START_DIR/StrepLab-JanOw_SPN-Typer.sh $out_jobCntrl $line_num" >> $START_DIR/linearflow.sh </dev/null 2>&1
    # Working on background/lazy parallelization 
    #pids[${line_num}]=$!
done
echo "Executing linear flow.."
bash "$START_DIR/linearflow.sh"
#for pid in ${pids[*]};
#do 
#    "Waiting for $pid .."
#    wait $pid
#done 
echo "MADE IT TO THE FINISH!"
#echo "Now.. we wait.."
#wait

# Uses job-control to output results
###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
while read -r line
do
    batch_name=$(echo $line | awk -F" " '{print $1}' | awk -F"/" '{print $(NF-4)}')
    final_outDir=$(echo $line | awk -F" " '{print $5}')
    final_result_Dir=$(echo $line | awk -F" " '{print $4}')
    cat $final_outDir/TABLE_Isolate_Typing_results.txt >> $final_result_Dir/TABLE_SPN_"$batch_name"_Typing_Results.txt
    #cat $final_outDir/BIN_Isolate_Typing_results.txt >> $final_result_Dir/BIN_GBS_"$batch_name"_Typing_Results.txt
    if [[ -e $final_outDir/TEMP_newPBP_allele_info.txt ]]
    then
        cat $final_outDir/TEMP_newPBP_allele_info.txt >> $final_result_Dir/UPDATR_SPN_"$batch_name"_Typing_Results.txt
    fi
done < $out_jobCntrl/job-control.txt