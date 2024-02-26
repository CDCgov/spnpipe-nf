#!/bin/bash

remote_repo="https://github.com/BrandonHuynhProfessional/strepAutomationTest/" 

# Read the list of required files from config.json
required_files=($(jq -r '.start[]' config.json))

# Error Handling for list of files
missing_files=false  # Flag to track if any files are missing

for file in ${required_files[@]}; do 
    if [ ! -f "$file" ]; then
        echo "Error: File $file specified in config.json does not exist."
        missing_files=true  
    fi
done

# Exit with error code if any files were missing
if $missing_files; then
    exit 1
fi

# Update process
git fetch origin

for file in ${required_files[@]}; do
    git checkout origin/main -- "$file"
    echo "Checking out $file"
done

# Output file update dates to run data
run_data_file="run_data.json"  
echo '{"run_data": [' > "$run_data_file" 

first_file=true  # Flag to track if we're adding the first entry
for file in ${required_files[@]}; do
    last_commit_date=$(git log -1 --format="%cd" --date=iso8601 -- "$file")

    # Add comma before entries except the first
    if [ "$first_file" = false ]; then 
        echo "," >> "$run_data_file"
    fi

    echo "  { \"filename\": \"$file\", \"last_commit_date\": \"$last_commit_date\" }" >> "$run_data_file"
    first_file=false
done

echo ']}' >> "$run_data_file"  

# Eventually add in error handling in case we are missing files from config