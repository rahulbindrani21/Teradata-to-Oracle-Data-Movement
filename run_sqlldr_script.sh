#!/usr/bin/ksh

echo "------------------------------------------------------------------"
echo "STARTING SQL LOADER SCRIPT EXECUTION"
echo "------------------------------------------------------------------"

# Prefix 
file_prefix=""

# get password
pwd_file=""
sqlldr_password=$(cat "$pwd_file")


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
    file_without_ext="${file%.*}"
	echo "------------------------------------"
    echo "Running $file....."
    # Provide oracle db connection url and replace <ORACLE DB URL> with it.
    sqlldr <ORACLE DB URL> control=$file SKIP_INDEX_MAINTENANCE=TRUE
    echo "Done running $file. Getting logs"
	echo "------------------------------------"
	log_file="${file_without_ext}.log"       
	records_inserted=$(grep -E "[0-9]+ Rows successfully loaded." "$log_file")
	records_discarded=$(grep -E "[0-9]+ Rows not loaded due to data errors" "$log_file")
    run_start=$(grep -E "Run began on .*" "$log_file")
    run_end=$(grep -E "Run ended on .*" "$log_file")
	echo $records_inserted
	echo $records_discarded
    echo $run_start
    echo $run_end
	echo "------------------------------------"
    mv $file ./archive/
    echo "$file ------>  Moved to archive"
done
echo "------------------------------------"
echo "Moving log and bad files to archive"
mv $file_prefix* ./archive/
echo "------------------------------------------------------------------"
echo "ENDING SQL LOADER SCRIPT EXECUTION"
echo "------------------------------------------------------------------"

unset sqlldr_password
