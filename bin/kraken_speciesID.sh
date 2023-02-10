#!/bin/bash -l

temp_path=$(pwd)
export PATH=$PATH:$temp_path

#. /usr/share/Modules/init/bash
###This script validates the input arguments and creates the job-control.txt file which is needed to submit the qsub array job to the cluster.###

ani_flag=''
while getopts :i:f:s:o:a option
do
    case $option in
        i) instr_dir=$OPTARG;;
        f) instr_file=$OPTARG;;
        n) name=$OPTARG;;
	a) ani_flag='TRUE';;
        o) output_dir=$OPTARG;;
    esac
done

###Check if batch directory and reference database directory arguments were given and if they exist###
type="blah"
if [[ -z "$instr_dir" && -z "$instr_file" ]]
then
    echo "Either the instrument directory (-i argument) or a list of R1 read or fasta files in a text file (-f argument) needs to be given."
    exit 1
elif [[ -n "$instr_dir" && -n "$instr_file" ]]
then
    echo "Either the instrument directory (-i argument) or a list of R1 read or fasta files in a text file (-f argument) needs to be given but not both."
    exit 1
else
    if [[ ! -z "$instr_dir" ]]
    then
        if [[ -d "$instr_dir" ]]
        then
            instr_dir=$(echo "$instr_dir" | sed 's/\/$//g')
            echo "The sequence directory is in the following location: $instr_dir"
            type="dir"
        else
            echo "This sequence directory is not in the correct format or doesn't exist."
            echo "Make sure you provide the full directory path (/root/path/sequence_directory)."
            exit 1
        fi
    elif [[ ! -z "$instr_file" ]]
    then
        if [[ -s "$instr_file" ]]
        then
            echo "The input file of R1 read or fasta files is in the following location: $instr_file"
            type="file"
        else
            echo "The input file of R1 read or fasta files is not in the correct format or doesn't exist."
            echo "Make sure you provide the full directory path (/root/path/input_file)."
            exit 1
        fi
    fi
fi

outName="Kraken_SpeciesID_Report.txt"
if [[ -n "$name" ]]
then
    outName="$name"
fi

outDir="./"
if [[ -z "$output_dir" ]]
then
    echo "The files will be saved to current directory"
elif [[ ! -d "$output_dir" ]]
then
    outDir="$output_dir"
    mkdir "$outDir"
    echo "The files will be saved to the following directory: $outDir"
else
    outDir="$output_dir"
    echo "The files will be saved to the following directory: $outDir"
fi

if [[ $ani_flag ]]
then
    echo "Will run FastANI on all Fasta sequences"
fi

###Start Doing Stuff###
cd "$outDir"
module load kraken/1.0.0
echo "Sample,SpeciesID,Read1_%,Read2_%,Diff,Diff_mult,Read_Clade,Read_Taxon,Rank_Code,NCBI_ID,Unclass_Reads,Comment,FastANI_ID,ANI,Match_Frags,Tot_Frags" >> "$outName"

if [[ "$type" == "dir" ]]
then
    ###Will search thru every file in the batch directory and check if it matches the following regexs: _L.*_R1_001.fastq and _L.*_R2_001.fastq###
    ###If both paired end fastq files are found then program will run Kraken tool###
    batch_dir_star="${instr_dir}/*"
    for sample in $batch_dir_star
    do
	if [[ "$sample" =~ _S[0-9]+_L[0-9]+_R._001.fastq ]]
	then
            sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_S[0-9]\+\_.*_001.fastq.gz//g')
	elif [[ "$sample" =~ _[1|2].fastq.gz ]]
	then
            sampl_name=$(echo "$sample" | sed 's/^.*\///g' | sed 's/_[1|2].fastq.gz//g')
	fi
	echo The sample file is: $sample

	if [[ $sampl_name =~ ^Undetermined ]]
	then
            echo "Skipping the 'Undetermined' fastq files"
            continue
	fi

	if [[ $sample =~ _L.*_R1_001.fastq ]]
	then
            readPair_1=$sample
	    readPair_2=$(echo "$readPair_1" | sed 's/_R1_/_R2_/')
	elif [[ $sample =~ .*_1.fastq.gz ]]
	then
            readPair_1=$sample
	    readPair_2=$(echo "$readPair_1" | sed 's/_1.fastq/_2.fastq/g')
	fi

	if [ -n "$readPair_1" -a -n "$readPair_2" ]
	then
            echo "Both Forward and Reverse Read files exist."
            echo "Paired-end Read-1 is: $readPair_1"
            echo "Paired-end Read-2 is: $readPair_2"
            printf "\n"
            ###Run Kraken tool with paired-end Fastq files
	    kraken -db /scicomp/reference/kraken/OLD/0.10.5/urdo_bacteria_and_virus --gzip-compressed --quick --threads 18 --fastq-input --output Kraken_out.txt --paired "$readPair_1" "$readPair_2"
	    kraken-report --db /scicomp/reference/kraken/OLD/0.10.5/urdo_bacteria_and_virus Kraken_out.txt > Kraken_report.txt
	    #speciesID=$(cat Kraken_report.txt | awk -F"\t" '$1 >= 50 {print $0}' | tail -n1 | awk -F"\t" '{print $6}' | sed 's/^ \+//g')
	    speciesID=$(kraken_caller.pl -f Kraken_report.txt |  sed -n 2p)
	    echo "$sampl_name,$speciesID,NA,NA,NA,NA"
	    echo "$sampl_name,$speciesID,NA,NA,NA,NA" >> "$outName"
            ###Prepare script for next sample###
	    if [[ $(echo $speciesID | awk -F"," '{print $10}') != "FLAG" ]]
	    then
		rm Kraken_out.txt Kraken_report.txt
		readPair_1=""
		readPair_2=""
	    else
		echo "DID NOT FIND GOOD MATCH"
		mv Kraken_report.txt "$sampl_name"_Kraken_report.txt
		rm Kraken_out.txt
		readPair_1=""
		readPair_2=""
	    fi
	fi
    done
elif [[ "$type" == "file" ]]
then
    while read readLine
    do
	sampl_name=$(echo $readLine | cut -d, -f1)
	if [[ $(echo $readLine | cut -d, -f2) =~ \.fastq$|\.fastq\.gz$ ]]
	then
	    echo "This is a fastq file"
	    readPair_1=$(echo $readLine | cut -d, -f2)
	    readPair_2=$(echo "$readPair_1" | sed 's/_R1_/_R2_/')
            if [ -n "$readPair_1" -a -n "$readPair_2" ]
            then
		echo "Both Forward and Reverse Read files exist."
		echo "Paired-end Read-1 is: $readPair_1"
		echo "Paired-end Read-2 is: $readPair_2"
		printf "\n"
                ###Run Kraken tool with paired-end Fastq files
		kraken -db /scicomp/reference/kraken/OLD/0.10.5/urdo_bacteria_and_virus --gzip-compressed --quick --threads 18 --fastq-input --output Kraken_out.txt --paired "$readPair_1" "$readPair_2"
		kraken-report --db /scicomp/reference/kraken/OLD/0.10.5/urdo_bacteria_and_virus Kraken_out.txt > Kraken_report.txt
                #speciesID=$(cat Kraken_report.txt | awk -F"\t" '$1 >= 50 {print $0}' | tail -n1 | awk -F"\t" '{print $6}' | sed 's/^ \+//g')
		speciesID=$(kraken_caller.pl -f Kraken_report.txt |  sed -n 2p)
		echo "$sampl_name,$speciesID,NA,NA,NA,NA"
		echo "$sampl_name,$speciesID,NA,NA,NA,NA" >> "$outName"
	    fi
	elif [[ $(echo $readLine | cut -d, -f2) =~ \.fasta$|\.fna$|\.fa$ ]]
	then
	    echo "This is a fasta file"
	    fastaFile=$(echo $readLine | cut -d, -f2)
	    kraken -db /scicomp/reference/kraken/OLD/0.10.5/urdo_bacteria_and_virus --threads 18 --fasta-input --output Kraken_out.txt "$fastaFile"
	    kraken-report --db /scicomp/reference/kraken/OLD/0.10.5/urdo_bacteria_and_virus Kraken_out.txt > Kraken_report.txt
	    speciesID=$(kraken_caller.pl -f Kraken_report.txt |  sed -n 2p)
            ANI_out="NA,NA,NA,NA"
            if [[ $ani_flag || $(echo $speciesID | awk -F"," '{print $11}') == "FLAG" ]]
            then
                echo "RUN FastANI"
		fastANI -q "$fastaFile" --rl /scicomp/groups/OID/NCIRD/DBD/RDB/Strep_Lab/JanOw_Dependencies/fastANI_strep_ref.txt -o "$sampl_name"_fastANI_out.txt
		ANI_out=$(head -n1 "$sampl_name"_fastANI_out.txt | sed 's|/scicomp/home-pure/ycm6/PROJECTS_StrepLab/2021/Kraken_SpeciesID_12-16-2020/genomes/||g' | tr '\t' ',' | cut -d, -f2-)
            fi
	    echo "$sampl_name,$speciesID,$ANI_out"
	    echo "$sampl_name,$speciesID,$ANI_out" >> "$outName"
	fi
        ###Prepare script for next sample###
	if [[ $(echo $speciesID | awk -F"," '{print $11}') != "FLAG" ]]
	then
	    rm Kraken_out.txt Kraken_report.txt
	    #readPair_1=""
	    #readPair_2=""
	else
	    echo "DID NOT FIND GOOD MATCH"
	    mv Kraken_report.txt "$sampl_name"_Kraken_report.txt
	    rm Kraken_out.txt
	    #readPair_1=""
	    #readPair_2=""
	fi
    done < "$instr_file"
fi
