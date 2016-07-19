rem NAME
rem   dbatab.sql
rem FUNCTION
rem   gets info about  user's tables
rem NOTE
rem   start from specified user
rem MODIFIED
rem   06.11.95 SBartsch - made it  
rem

set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column OWNER             format a12
column table_name        format a20 heading 'TABLE'
column tablespace_name   format a15 heading 'TBS' 
column timestamp         format 99999999 heading 'ROWS'
column blocks            format 99999999
column chain_cnt         format 99999999 heading 'CHAINED'

prompt
prompt -----------------------------------------------------------;
prompt User DB-Objects Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name: [] ';
accept tabname  char prompt 'Table Name: [] ';
accept tabspace char prompt 'Tablespace: [] ';
accept filename char prompt 'Spool File: [] ' default '&TMPDIR.sqltab.lst';

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
       'User DB-Tables Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Table Name    :  &&tabname'|| chr(10) ||
       'Tablespace    :  &&tabspace'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select owner, table_name, tablespace_name, num_rows, blocks, chain_cnt, last_analyzed
  from dba_tables 
 where owner like upper(nvl('%&&ownname.%','%'))
   and table_name like upper(nvl('%&&tabname.%','%'))
   and NVL(tablespace_name,'%') like upper(nvl('%&&tabspace.%','%'))      
 order by owner, table_name
/

spool off;

undefine dbname
undefine ownname
undefine tabname
undefine tabspace
undefine status
undefine ordcrit
undefine filename

rem pause Press <Return> to continue;

rem exit
