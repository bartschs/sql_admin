rem NAME
rem   sqlcol.sql
rem FUNCTION
rem   gets info about table-columns relations 
rem NOTE
rem   start from specified user
rem MODIFIED
rem   28.05.99 SBartsch - made it  
rem

set verify off;
set heading off;
set feedback off;
set trimspool on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column OWNER         format a15
column TABLE_NAME    format a30 
column COLUMN_NAME   format a30 
 
prompt
prompt -----------------------------------------------------------;
prompt User Non-PL/SQL Columns Report
prompt -----------------------------------------------------------;
prompt
accept owner      char prompt 'Owner Name: .......... [] ';
accept tablename  char prompt 'Table Name: .......... [] ';
accept colname    char prompt 'Column Name: ......... [] ';
accept colid      char prompt 'Column ID: ........... [] ';
accept ordcrit    char prompt 'Order by (Name|ID) [Name] ';
accept filename   char prompt 'Spool to <filename>:   [] ' default '&TMPDIR.sqlcol.lst';
rem prompt ------------------------------------------------------;

rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&filename

select '------------------------------------------------------'|| chr(10) ||
       'User Non-PL/SQL Columns Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Owner Name    :  &&owner'|| chr(10) ||
       'Table Name    :  &&tablename'|| chr(10) ||
       'Column Name   :  &&colname'|| chr(10) ||
       'Column ID     :  &&colid'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select table_name, column_id, column_name, owner  
  from all_tab_columns 
 where table_name like upper(nvl('%&&tablename.%','%'))
   and column_name like upper(nvl('%&&colname.%','%'))
   and column_id = nvl('&&colid', column_id)
   and owner like upper(nvl('%&&owner.%','%'))
 group by owner, table_name, column_id, column_name
 order by decode (nvl('&&ordcrit', 'name')
                  ,'name', table_name
                  ,'id', column_id
                  ,table_name)
/
 
-- order by table_name, column_name;
spool off;

undefine dbname
undefine owner
undefine tablename
undefine colname
undefine filename

rem pause Press <Return> to continue;

rem exit
  
