
rem NAME
rem   sqlcomp.sql
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

set long 40000;
set maxdata 60000;
--set pagesize 2000;
set pagesize 0;
set linesize 100;

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt User DB-Object Columns Report
prompt -----------------------------------------------------------;
prompt
accept owner      char prompt 'Schema Name:           [] ';
accept tablename  char prompt 'Table Name:            [] ';
accept colname    char prompt 'Column Name:           [] ';
accept consname   char prompt 'Constraint:            [] ';
accept filename   char prompt 'Spool to <filename>:   [] ' default '&TMPDIR.compare.lst';
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
       'User DB-Object Columns Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name   :  &&dbname'|| chr(10) ||
       'User Name       :  '||user||' '|| chr(10) ||
       'Run On          :  '||sysdate||' '|| chr(10) ||
       'Schema Name     :  &&owner'|| chr(10) ||
       'Table Name      :  &&tablename'|| chr(10) ||
       'Column Name     :  &&colname'|| chr(10) ||
       'Constraint Name :  &&consname'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/


column DB_NAME            format a10  heading 'DB_NAME'
column OWNER              format a15  heading 'OWNER'
column TABLE_NAME         format a30  heading 'TABLE_NAME'
COLUMN COLUMN_ID          FORMAT 99   heading 'ID'
column COLUMN_NAME        format a30  heading 'COLUMN_NAME'
COLUMN data_type          FORMAT A10  heading 'TYPE'
COLUMN data_length        FORMAT 99   heading 'LEN'
COLUMN data_precision     FORMAT 99   heading 'PRE'
COLUMN data_scale         FORMAT 99   heading 'SCL'
COLUMN position           FORMAT 99   heading 'POS'
column CONS_COLUMN_NAME   format a30  heading 'CONS_COLUMN_NAME'
column CONSTRAINT_NAME    format a30  heading 'CONS_NAME'
column CONSTRAINT_TYPE    format a1   heading 'CT'
column STATUS             format a7   heading 'STATUS'

set heading off;
set feedback on;

select 
       o.db_name
      ,o.table_name
      ,o.column_id 
      ,o.column_name
      ,o.data_type
      ,o.data_length
      ,o.data_precision
      ,o.data_scale
      ,o.position
      ,o.cons_column_name
	  ,o.constraint_name
      ,o.constraint_type
      ,o.status
from
(
 select /* Tables having constrainted columns */
       (select substr(substr(global_name,1,instr(global_name,'.')-1),1,30) db_name from global_name) db_name
      ,col.table_name
      ,col.column_id 
      ,col.column_name
      ,substr(col.data_type,1,15) data_type
      ,col.data_length
      ,col.data_precision
      ,col.data_scale
      ,NVL(acc.position, 0) position
      ,substr(acc.column_name,1,30) cons_column_name
	  ,decode(substr(ac.constraint_name,1,3), 'SYS', 'SYSTEM', ac.constraint_name) constraint_name
      ,ac.constraint_type
      ,ac.status
  from all_tab_columns     col 
      ,all_constraints     ac
      ,all_cons_columns    acc
 where col.owner = ac.owner
   and ac.owner = acc.owner
   and col.table_name = ac.table_name
   and ac.table_name = acc.table_name
   and col.column_name = acc.column_name
   and ac.constraint_name = acc.constraint_name
   and col.owner like upper(nvl('&&owner.%','%'))
   and col.table_name like upper(nvl('&&tablename.%','%'))
-- and col.column_name like upper(nvl('%&&colname.%','%'))
-- and ac.constraint_name like upper(nvl('%&&consname.%','%'))
UNION
 select /* Generate dummy constraint info for all tables */
       (select substr(substr(global_name,1,instr(global_name,'.')-1),1,30) db_name from global_name) db_name
      ,col.table_name
      ,col.column_id 
      ,col.column_name
      ,substr(col.data_type,1,15) data_type
      ,col.data_length
      ,col.data_precision
      ,col.data_scale
      ,0     position
      ,NULL  cons_column_name
	  ,NULL  constraint_name
      ,NULL  constraint_type
      ,NULL  status
  from all_tab_columns     col 
 where col.owner like upper(nvl('&&owner.%','%'))
   and col.table_name like upper(nvl('&&tablename.%','%'))
MINUS
 select /* Remove dummy constraint info for tables having constrainted columns */
       (select substr(substr(global_name,1,instr(global_name,'.')-1),1,30) db_name from global_name) db_name
      ,col.table_name
      ,col.column_id 
      ,col.column_name
      ,substr(col.data_type,1,15) data_type
      ,col.data_length
      ,col.data_precision
      ,col.data_scale
      ,0     position
      ,NULL  cons_column_name
	  ,NULL  constraint_name
      ,NULL  constraint_type
      ,NULL  status
  from all_tab_columns     col 
      ,all_constraints     ac
      ,all_cons_columns    acc
 where col.owner = ac.owner
   and ac.owner = acc.owner
   and col.table_name = ac.table_name
   and ac.table_name = acc.table_name
   and col.column_name = acc.column_name
   and ac.constraint_name = acc.constraint_name
   and col.owner like upper(nvl('&&owner.%','%'))
   and col.table_name like upper(nvl('&&tablename.%','%'))
-- and col.column_name like upper(nvl('%&&colname.%','%'))
-- and ac.constraint_name like upper(nvl('%&&consname.%','%'))
) o
order by o.table_name ,o.column_id 
/

spool off;

undefine dbname
undefine owner
undefine tablename
undefine colname
undefine consname
undefine filename

rem pause Press <Return> to continue;

rem exit
  

