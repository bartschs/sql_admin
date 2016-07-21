rem NAME
rem    sqlrow.sql
rem FUNCTION
rem    This script describes all object definitions from the
rem    data dictionary and spools it to an operating system file.
rem    This version runs against the USER_* views:
rem    for use by application developers.
rem    -- Usage:    sqlplus -s un/pw @sqldesc.sql
rem NOTE
rem    call from sqlplus as specified user
rem MODIFIED
rem    14.02.96 SBartsch  - made it
rem

prompt
prompt ------------------------------------------------------;
prompt User SQL Row Count Description Report
prompt ------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name ........: [] ';
accept tabname  char prompt 'Object Name .......: [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.sqlrow.lst';
prompt ------------------------------------------------------;
prompt

set heading off
set pause off
set termout off
set feedback off
set concat on
set verify off
set trimspool on

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a75

rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt User SQL Row Count Report;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Database Name :  &&dbname'|| chr(10) ||
       'prompt User Name     :  '||user||' '|| chr(10) ||
       'prompt Run On        :  '||sysdate||' '|| chr(10) ||
       'prompt Owner Name    :  &&ownname'|| chr(10) ||		   
       'prompt Object Name   :  &&tabname'|| chr(10) ||	   
       'prompt Spool File    :  &&filename'|| chr(10) ||
	   'prompt'|| chr(10) from dual
/

spool off

spool &TMPDIR.tmp_row.sql

select  distinct(
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Object Name: '|| table_name || chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'select count(*) from ' || owner || '.' || table_name || ';') command_line
  from all_catalog
 where owner like upper(nvl('%&&ownname.%','%'))
   and table_name like upper(nvl('&&tabname.%','%'))
   and table_type in ('TABLE', 'VIEW', 'SYNONYM')
/
rem order by table_name;

spool off

set heading on
set feedback 6
set termout on
set pause off
set verify off
rem spool &TMPDIR.&&filename.lst
rem spool &TMPDIR.sqlrow.lst
spool &filename
start &TMPDIR.tmp_head.sql
start &TMPDIR.tmp_row.sql
rem host rm &TMPDIR.tmp_head.sql
rem host rm &TMPDIR.tmp_row.sql
spool off

undefine ownname
undefine tabname
undefine filename

rem exit
