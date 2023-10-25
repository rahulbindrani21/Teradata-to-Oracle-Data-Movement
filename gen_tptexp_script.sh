#!/usr/bin/ksh
###EDWPROD_EWPMST_PLN_DIVN_LOC_CDV_PRD

echo "------------------------------------------------------------------"
echo "CREATING TPT SCRIPTS"
echo "------------------------------------------------------------------"

dbenv='YOUR_DATABASE_NAME'
export dbenv

DS=`date "+%y%m%d.%H%M%S"`
export DS

cat inputparameters.dat | while read dbname objectname
do
   objectname=$(echo $objectname|tr -d '\n\t\r')
   echo '.run file edwplogon.txt' > tptexport_columns.sql
   sed s/DDD/${dbname}/g gen_column_list.sql > gen_column_list.out.1
   sed s/YYY/${objectname}/g gen_column_list.out.1 > gen_column_list.out.2
   cat gen_column_list.out.2 >> tptexport_columns.sql
   echo '.quit' >> tptexport_columns.sql

   bteq < tptexport_columns.sql
   # outpute list_all_columns_${dbname}_${objectname}.lst

   # Replace <YOUR_LOGIN_FILE> with your file name and provide login details to the teradata db.    
   echo '.run file <YOUR_LOGIN_FILE>' > select_columns.sql
   sed s/DDD/${dbname}/g trim_column_list.sql > select_column_list.out.1
   sed s/YYY/${objectname}/g select_column_list.out.1 > select_column_list.out.2
   cat select_column_list.out.2 >> select_columns.sql
   echo '.quit' >> select_columns.sql

   bteq < select_columns.sql

   echo "DEFINE JOB EXPORT_TABLE_${objectname} DESCRIPTION 'Exporting table from teradata '" > ${dbenv}_${dbname}_${objectname}.tptexp
   echo "(" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "DEFINE SCHEMA ${objectname}_schema (" >>${dbenv}_${dbname}_${objectname}.tptexp

        cat ./column_list/list_all_columns_${dbname}_${objectname}.lst >>${dbenv}_${dbname}_${objectname}.tptexp

   echo ");" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "DEFINE OPERATOR ${objectname}_SQL_SELECTOR TYPE EXPORT SCHEMA ${objectname}_schema ATTRIBUTES ( VARCHAR SpoolMode = 'NoSpool'," >>${dbenv}_${dbname}_${objectname}.tptexp
   # echo "                INTEGER BlockSize = 64330," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                INTEGER TenacityHours = 4," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                INTEGER TenacitySleep = 1," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                INTEGER MaxSessions = 50," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                INTEGER MinSessions = 1," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                INTEGER MaxDecimalDigits = 38," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR PrivateLogName = '${objectname}_src_log'," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR TdpId = ''," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR UserName = ''," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR UserPassword = ''," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR SelectStmt = 'locking row for access select ' ||" >>${dbenv}_${dbname}_${objectname}.tptexp

cat ./trimmed_column_list/trimmed_columns_${dbname}_${objectname}.lst >>${dbenv}_${dbname}_${objectname}.tptexp

   echo "               ' from ${dbname}.${objectname} ; '" >> ${dbenv}_${dbname}_${objectname}.tptexp
   echo ");" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "DEFINE OPERATOR ${objectname}_FILE_WRITER TYPE DATACONNECTOR CONSUMER SCHEMA ${objectname}_schema ATTRIBUTES ( " >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "               INTEGER IOBufferSize = 1048575," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR PrivateLogName = '${objectname}_dest_log'," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR DirectoryPath = 'TD_MOVEMENT/'," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                INTEGER NumInstances = 50," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR Format = 'DELIMITED'," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR OpenMode = 'write'," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR FileName = '${dbenv}_${dbname}_${objectname}.csv'," >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "                VARCHAR TextDelimiter = '<tpt>'" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo ");" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "APPLY TO OPERATOR (${objectname}_FILE_WRITER [50])" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "SELECT  *" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "FROM  OPERATOR (${objectname}_SQL_SELECTOR [1]); );" >>${dbenv}_${dbname}_${objectname}.tptexp
   echo "" >>${dbenv}_${dbname}_${objectname}.tptexp
   mv ${dbenv}_${dbname}_${objectname}.tptexp ./tpt_scripts/   
done 
rm gen_column_list.out*
rm select_column_list.out*
echo "------------------------------------------------------------------"
echo "TPT SCRIPTS CREATED"
echo "------------------------------------------------------------------"
