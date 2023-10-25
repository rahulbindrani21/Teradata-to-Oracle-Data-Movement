#!/usr/bin/ksh

echo "------------------------------------------------------------------"
echo "CREATING SQL LOADER CONTROL FILES"
echo "------------------------------------------------------------------"

dbenv='YOUR_DATABASE_NAME'
export dbenv

DS=`date "+%y%m%d.%H%M%S"`
export DS

cat ../inputparameters.dat | while read dbname objectname
do
    objectname=$(echo $objectname|tr -d '\n\t\r')

    # generate column list
    # Replace <YOUR_LOGIN_FILE> with your file name and provide login details to the teradata db.
    echo '.run file <YOUR_LOGIN_FILE>' > tptexport_columns.sql
    sed s/DDD/${dbname}/g gen_column_list.sql > gen_column_list.out.1
    sed s/XXX/${objectname}/g gen_column_list.out.1 > gen_column_list.out.2
    cat gen_column_list.out.2 >> tptexport_columns.sql
    echo '.quit' >> tptexport_columns.sql
    bteq < tptexport_columns.sql

    file_prefix=${dbenv}_${dbname}_${objectname}.csv

    # Get list of file
    files=$(ls "$file_prefix"* 2>/dev/null)

    # check  if list is empty
    if [ -z "$files" ]; then
        echo "No files found with prefix '$file_prefix'."
        continue
    fi

    # generate sqlloader 
    echo "OPTIONS (DIRECT=TRUE, PARALLEL=TRUE, ERRORS=1)" > ${dbenv}_${dbname}_${objectname}.ctl    
    echo "LOAD DATA" >> ${dbenv}_${dbname}_${objectname}.ctl    
    for file in $files
    do 
        echo "Adding $file....."
        echo "INFILE '$file'" >> ${dbenv}_${dbname}_${objectname}.ctl
        echo "Added $file......"
    done
    echo "APPEND INTO TABLE ${dbname}_${objectname}" >> ${dbenv}_${dbname}_${objectname}.ctl
    echo 'FIELDS TERMINATED BY "<tpt>"' >> ${dbenv}_${dbname}_${objectname}.ctl
    echo 'TRAILING NULLCOLS' >> ${dbenv}_${dbname}_${objectname}.ctl
    echo "(" >> ${dbenv}_${dbname}_${objectname}.ctl
    cat ./column_list/sqlldr_column_list_${dbname}_${objectname}.lst >>${dbenv}_${dbname}_${objectname}.ctl
    echo ")" >>${dbenv}_${dbname}_${objectname}.ctl
    mv ${dbenv}_${dbname}_${objectname}.ctl ./control_files/
done
rm gen_column_list.out*
echo "------------------------------------------------------------------"
echo "SQL LOADER CONTROL FILES CREATED"
echo "------------------------------------------------------------------"
