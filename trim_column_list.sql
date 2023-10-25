
----------DDD.XXX.YYY -----------------------------------------
.os rm ./trimmed_column_list/trimmed_columns_DDD_YYY.lst
.export file  ./trimmed_column_list/trimmed_columns_DDD_YYY.lst
.set width 10000
.set format OFF

SELECT 
case 
    when ColumnType IN ('CF', 'CV')     
        then '     '' case when ' || trim(ColumnName) ||
            '       is null then '''' '''' '||
            '       else CAST(sysudf.udf_nospclvarchr(translate(' ||
            trim(ColumnName) || ' USING UNICODE_TO_LATIN WITH ERROR)) AS VARCHAR('  || 
            trim(ColumnLength) || ')) end'
    else
        '     '''||trim(ColumnName)||' '     
end || 
case 
    when b.maxid <> a.columnid
        then ','
    else ''
end ||
' '' || '
(title '') 


FROM dbc.ColumnsV a,
     (select max(columnid) as maxid from dbc.ColumnsV  
        WHERE databasename ='DDD' 
        and tablename = 'YYY') b
    WHERE databasename ='DDD' and tablename = 'YYY'
    ORDER BY COLUMNID;

.export reset
