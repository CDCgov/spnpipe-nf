#!/bin/bash -l

x1="0"
if [ -d "$1" ]; then
if [ -s "$1""/Sample_PBP1A_AA.faa" ]; then
if [ -s "$1""/Sample_PBP2B_AA.faa" ]; then
if [ -s "$1""/Sample_PBP2X_AA.faa" ]; then
x1="1"
fi
fi
fi
fi

if [ "$x1" == "1" ]; then
  AAseqDir=$1
  echo "Data folder is $AAseqDir"
else
  echo "usage bash ./AAtoMICwrapper.sh data_dir"
  echo ""
  echo "data_dir is a directory that must conatin 3 files with the following exact names, respectively:"
  echo "Sample_PBP1A_AA.faa"
  echo "Sample_PBP2B_AA.faa"
  echo "Sample_PBP2X_AA.faa"
  echo ""
  echo "See README.txt for details"
  echo "Program not run"  
  exit 1
fi

faaDir=$AAseqDir"/Sample_AAtoMIC/faa/"
rm -rf   $faaDir
mkdir -p $faaDir
cd $faaDir

cp $AAseqDir"/"*".faa" .
temp_path=$2
Build_PBP_AA_tableR3.2.2.R $faaDir $temp_path

predir=$AAseqDir"/Sample_AAtoMIC/pre/"
rm -rf   $predir
mkdir -p $predir
cp ./Sample_PBP_AA_table.csv $predir

cd $predir
AAtable_To_MIC_MM_RF_EN_2.R $predir $temp_path

cp Sample_PBPtype_MIC2_Prediction.csv  $AAseqDir

echo "MIC pridiction results are in file:"
echo "$AAseqDir""/Sample_PBPtype_MIC2_Prediction.csv"