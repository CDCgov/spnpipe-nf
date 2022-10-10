#!/bin/bash

just_name=$1
out_dir=$2

if [ ! -d "${output_dir}/temp_final" ]; then
        mkdir "${output_dir}/temp_final"
fi
###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
tabl_out="${out_dir}/temp_final/TABLE_Isolate_Typing_results.txt"
bin_out="${out_dir}/BIN_Isolate_Typing_results.txt"
printf "$just_name\t" >> "$tabl_out"
printf "$just_name," >> "$bin_out"

###Serotype Output###
sero_out="NF"
pili_out="neg"
while read -r line
do
    if [[ -n "$line" ]]
    then
        justTarget=$(echo "$line" | awk -F"\t" '{print $4}')
	if [[ "$justTarget" == "PI-1" ]]
	then
            if [[ "$pili_out" == "neg" ]]
            then
		pili_out="1"
            elif [[ "$pili_out" == "2" ]]
	    then
		pili_out="1:2"
            fi
	elif [[ "$justTarget" == "PI-2" ]]
	then
            if [[ "$pili_out" == "neg" ]]
            then
                pili_out="2"
            elif [[ "$pili_out" == "1" ]]
	    then
                pili_out="1:2"
            fi
        else
            if [[ "$sero_out" == "NF" ]]
            then
		sero_out="$justTarget"
            else
		sero_out="$sero_out;$justTarget"
            fi
	fi
    fi
done <<< "$(sed 1d "${output_dir}/${just_name}/OUT_SeroType_Results.txt")"
printf "$sero_out\t$pili_out\t" >> "$tabl_out"
printf "$sero_out,$pili_out\t" >> "$bin_out"

###MLST OUTPUT###
sed 1d "${out_dir}/${sample}/MLST_${just_name}__mlst__Streptococcus_pneumoniae__results.txt" | while read -r line
do
    MLST_tabl=$(echo "$line" | cut -f2-9)
    echo "MLST line: $MLST_tabl\n";
    printf "$MLST_tabl\t" >> "$tabl_out"
    MLST_val=$(echo "$line" | awk -F" " '{print $2}')
    printf "$MLST_val," >> "$bin_out"
done

###PBP_ID Output###
justPBPs="NF"
sed 1d "${out_dir}/${sample}/TEMP_pbpID_Results.txt" | while read -r line
do
    if [[ -n "$line" ]]
    then
        justPBPs=$(echo "$line" | awk -F"\t" '{print $2}' | tr ':' '\t')
        justPBP_BIN=$(echo "$line" | awk -F"\t" '{print $2}' | tr ':' ',')
    fi
    printf "$justPBPs\t" >> "$tabl_out"
    printf "$justPBP_BIN," >> "$bin_out"
done


pbpID=$(tail -n1 "${out_dir}/${sample}/TEMP_pbpID_Results.txt" | awk -F"\t" '{print $2}')
if [[ ! "$pbpID" =~ .*NF.* ]] #&& [[ ! "$pbpID" =~ .*NEW.* ]]
then
    echo "No NF outputs for PBP Type"
    bLacTab=$(tail -n1 "${out_dir}/${sample}/BLACTAM_MIC_RF_with_SIR.txt" | tr ' ' '\t')
    printf "$bLacTab\t" >> "$tabl_out"

else
    echo "One of the PBP types has an NF"
    printf "NF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\t" >> "$tabl_out"
    #printf "NF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF," >> "$bin_out"
fi

###Resistance Targets###
while read -r line
do
    printf "$line\t" | tr ',' '\t' >> "$tabl_out"
done < "${out_dir}/${sample}/RES-MIC_${just_name}"

if [[ -e $(echo ${out_dir}/${sample}/velvet_output/*_Logfile.txt) ]]
then
    vel_metrics=$(echo ${out_dir}/${sample}/velvet_output/*_Logfile.txt)
    printf "velvet metrics file: $vel_metrics\n";
    velvetMetrics.pl -i "$vel_metrics";
    line=$(cat velvet_qual_metrics.txt | tr ',' '\t')
    printf "$line\t" >> "$tabl_out"

    printf "$readPair_1\t" >> "$tabl_out";
    #pwd | xargs -I{} echo {}"/velvet_output/contigs.fa" >> "$tabl_out"
    echo "${out_dir}/${sample}/velvet_output/contigs.fa" >> "$tabl_out"
else
    printf "NA\tNA\tNA\tNA\t$readPair_1\tNA\n" >> "$tabl_out"
fi
