rem NAME
rem    alldesc.sql
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
prompt User Non-PL/SQL Objects Description Report
prompt ------------------------------------------------------;
accept owner      char prompt 'Owner Name:          [] ';
accept tablename  char prompt 'Table Name:          [] ';
accept filename   char prompt 'Spool to <filename>: [] ' default '&TMPDIR.alldesc.lst';
prompt ------------------------------------------------------;
prompt

set heading off;
set pause off;
set termout off;
set feedback off;
set concat on;
set verify off;
set trimspool on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a75
column table_name noprint

rem
rem get current DB Name
rem

rem set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
rem set termout on

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt User Non-PL/SQL Objects Description Report;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Database Name :  &&dbname'|| chr(10) ||
       'prompt User Name     :  '||user||' '|| chr(10) ||
       'prompt Owner Name    :  &&owner'|| chr(10) ||
       'prompt Object Name   :  &&tablename'|| chr(10) ||
       'prompt Spool File    :  &&filename'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) from dual
/
spool off

spool &TMPDIR.tmp_desc.sql

select  distinct(
       'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner  Name: '|| owner || chr(10) ||
       'prompt Object Name: '|| table_name || chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'desc ' || table_name) command_line
      ,table_name
  from all_catalog
 where owner like upper(nvl('%&&owner.%','%'))
   and table_name like upper(nvl('%&&tablename.%','%'))
   and table_type in ('TABLE', 'VIEW', 'SYNONYM')
 order by table_name;

spool off

set heading on
set feedback 6
set termout on
set pause off
set verify off
spool &&filename
start &TMPDIR.tmp_head.sql
start &TMPDIR.tmp_desc.sql
rem host rm &TMPDIR.tmp_head.sql
rem host rm &TMPDIR.tmp_desc.sql
spool off

undefine dbname
undefine owner
undefine tablename
undefine filename

rem exit
