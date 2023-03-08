#!/bin/bash
set -u

# TODO: Reformat script into functions and better handling
sample=$1
out_dir=$2

###Output the emm type/MLST/drug resistance data for this sample to it's results output file###
tabl_out="${out_dir}/TABLE_Isolate_Typing_results.txt"
bin_out="${out_dir}/BIN_Isolate_Typing_results.txt"

HEADERS="Sample\tWGS_Serotype\tPili\tST\taroe\tgdh\tgki\trecP\tspi\txpt\tddl\tPBP1A\tPBP2B\tPBP2X\t\
WGS_PEN_SIGN\tWGS_PEN\tWGS_PEN_SIR_Meningitis\tWGS_PEN_SIR_Nonmeningitis\tWGS_AMO_SIGN\tWGS_AMO\t\
WGS_AMO_SIR\tWGS_MER_SIGN\tWGS_MER\tWGS_MER_SIR\tWGS_TAX_SIGN\tWGS_TAX\tWGS_TAX_SIR_Meningitis\t\
WGS_TAX_SIR_Nonmeningitis\tWGS_CFT_SIGN\tWGS_CFT\tWGS_CFT_SIR_Meningitis\tWGS_CFT_SIR_Nonmeningitis\t\
WGS_CFX_SIGN\tWGS_CFX\tWGS_CFX_SIR\tWGS_AMP_SIGN\tWGS_AMP\tWGS_AMP_SIR\tWGS_CPT_SIGN\tWGS_CPT\tWGS_CPT_SIR\t\
WGS_ZOX_SIGN\tWGS_ZOX\tWGS_ZOX_SIR\tWGS_FOX_SIGN\tWGS_FOX\tWGS_FOX_SIR\tEC\tWGS_ERY_SIGN\tWGS_ERY\tWGS_ERY_SIR\t\
WGS_CLI_SIGN\tWGS_CLI\tWGS_CLI_SIR\tWGS_SYN_SIGN\tWGS_SYN\tWGS_SYN_SIR\tWGS_LZO_SIGN\tWGS_LZO\tWGS_LZO_SIR\t\
WGS_ERY/CLI\tCot\tWGS_COT_SIGN\tWGS_COT\tWGS_COT_SIR\tTet\tWGS_TET_SIGN\tWGS_TET\tWGS_TET_SIR\t\
WGS_DOX_SIGN\tWGS_DOX\tWGS_DOX_SIR\tFQ\tWGS_CIP_SIGN\tWGS_CIP\tWGS_CIP_SIR\tWGS_LFX_SIGN\tWGS_LFX\tWGS_LFX_SIR\t\
Other\tWGS_CHL_SIGN\tWGS_CHL\tWGS_CHL_SIR\tWGS_RIF_SIGN\tWGS_RIF\tWGS_RIF_SIR\tWGS_VAN_SIGN\tWGS_VAN\tWGS_VAN_SIR\t\
WGS_DAP_SIGN\tWGS_DAP\tWGS_DAP_SIR\tContig_Num\tN50\tLongest_Contig\tTotal_Bases\tReadPair_1\tContig_Path\n"

# Creates final TABLE file with headers if it doesn't exist. 
# More logic should be added to main.nf or somewhere else to handle creating a new output file.
if [[ ! -f "${out_dir}/TABLE_Isolate_Typing_results.txt" ]]; then
    printf "${HEADERS}" > "${out_dir}/TABLE_Isolate_Typing_results.txt"
fi

printf "$sample\t" >> "$tabl_out"
printf "$sample," >> "$bin_out"

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
done <<< "$(sed 1d "${out_dir}/${sample}/OUT_SeroType_Results.txt")"
printf "$sero_out\t$pili_out\t" >> "$tabl_out"
printf "$sero_out,$pili_out\t" >> "$bin_out"

###MLST OUTPUT###
sed 1d "${out_dir}/${sample}/MLST_${sample}__mlst__Streptococcus_pneumoniae__results.txt" | while read -r line
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
if [[ ! "$pbpID" =~ .*NF.* ]]
then
    echo "No NF outputs for PBP Type"
    bLacTab=$(tail -n1 "${out_dir}/${sample}/BLACTAM_MIC_RF_with_SIR.txt" | tr ' ' '\t')
    printf "$bLacTab\t" >> "$tabl_out"

else
    echo "One of the PBP types has an NF"
    printf "NF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\tNF\t" >> "$tabl_out"

fi

###Resistance Targets###
while read -r line
do
    printf "$line\t" | tr ',' '\t' >> "$tabl_out"
done < "${out_dir}/${sample}/RES-MIC_${sample}"

if [[ -e $(echo ${out_dir}/${sample}/velvet_output/*_Logfile.txt) ]]
then
    vel_metrics=$(echo ${out_dir}/${sample}/velvet_output/*_Logfile.txt)
    printf "velvet metrics file: $vel_metrics\n";
    velvetMetrics.pl -i "$vel_metrics";
    line=$(cat ${out_dir}/${sample}/velvet_output/velvet_qual_metrics.txt | tr ',' '\t')
    printf "$line\t" >> "$tabl_out"

    printf "$readPair_1\t" >> "$tabl_out";

    echo "${out_dir}/${sample}/velvet_output/contigs.fa" >> "$tabl_out"
else
    printf "NA\tNA\tNA\tNA\t$readPair_1\tNA\n" >> "$tabl_out"
fi

cleanup_array=("*.pileup" "*.*sorted.*am" "*.scores" "*ARGannot_r1.*" "ARG-RESFI_fullgenes_results.txt" "BIN_Isolate_Typing_results.txt" "BLACTAM_MIC_RF_with_SIR.txt" "Serotype_Extraction_Sequence.fna" "velvet_qual_metrics.txt" "velvet_output/Sequences" "velvet_output/stats.txt" "velvet_output/Log" "BLACTAM_MIC_RF.txt" "RES-MIC*" "cutadapt_*_R*" "FOLP_target_*" "OUT_*" "TEMP_*" "velvet_output/*Graph*" "PBP_to_MIC_temp/" "*_R1_cut" "*_R2_cut")

#rm *.pileup
#rm *.*sorted.*am
#rm *.scores
#rm *ARGannot_r1.*
#rm *__genes__*
#rm *log
#rm *Results.txt
#rm ARG-RESFI_fullgenes_results.txt BIN_Isolate_Typing_results.txt BLACTAM_MIC_RF_with_SIR.txt Serotype_Extraction_Sequence.fna velvet_qual_metrics.txt ./velvet_output/Sequences ./velvet_output/stats.txt ./velvet_output/Log BLACTAM_MIC_RF.txt
#rm RES-MIC*
#rm cutadapt_*_R*
#rm FOLP_target_*
#rm OUT_*
#rm TEMP_*
#rm velvet_output/*Graph*
#rm -r PBP_to_MIC_temp/
#rm -r *_R1_cut
#rm -r *_R2_cut
#RES-MIC* cutadapt_*_R* FOLP_target_* OUT_* TEMP_* velvet_output/*Graph* PBP_to_MIC_temp/ *_R1_cut *_R2_cut

# Add in logic for flag to enable a debug mode that keeps intermediary files
for i in "${cleanup_array[@]}"
do
    # Searches for pattern from cleanup_array (glob incl.) and removes if it exists
    find "${out_dir}/${sample}" -maxdepth 1 -name "$i" -delete
done
echo "Successfully passed cleanup"

exit