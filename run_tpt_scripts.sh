#!/usr/bin/ksh

echo "------------------------------------------------------------------"
echo "STARTING TPT SCRIPTS EXECUTION"
echo "------------------------------------------------------------------"

# Prefix
file_prefix=""

# Get list of file
files=$(ls "$file_prefix"* 2>/dev/null)

# check  if list is empty
if [ -z "$files" ]; then
    echo "No files found with prefix '$file_prefix'."
    exit 1
fi

# run tpt scripts
for file in $files
do 
    echo "Running $file....."
    tbuild -f "$file" -C
    echo "Done running $file. Moving to archive"
    mv $file ./archive/
    echo "$file ------>  Moved to archive"
done

echo "------------------------------------------------------------------"
echo "ENDING TPT SCRIPTS EXECUTION"
echo "------------------------------------------------------------------"
