
----------DDD.XXX.YYY -----------------------------------------
.os rm ./column_list/list_all_columns_DDD_YYY.lst
.export file  ./column_list/list_all_columns_DDD_YYY.lst


SELECT
case 
    when ColumnType IN ('CF', 'CV') 
        then '      '||trim(ColumnName)||' '||
              'VARCHAR(' || trim(ColumnLength) || ')'
    else
        '      '||trim(ColumnName)||' '||
                     sysudf.DataTypeString
                     (ColumnType,
                     ColumnLength,
                     DecimalTotalDigits,
                     DecimalFractionalDigits,
                     CharType,
                     ColumnUDTName)
end 
|| case when b.maxid <> a.columnid
then ','
else ''
end (title '') 
---,

---   ColumnType,
---   ColumnLength,
---   DecimalTotalDigits,
---   DecimalFractionalDigits,
---   CharType
FROM dbc.ColumnsV a,
     (select max(columnid) as maxid from dbc.ColumnsV  
       WHERE databasename ='DDD' 
       and tablename = 'YYY') b
WHERE
databasename ='DDD' and 
tablename = 'YYY'
ORDER BY COLUMNID
;

.export reset
