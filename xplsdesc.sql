rem NAME
rem    plsdesc.sql
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
prompt User PL/SQL Objects Description Report
prompt ------------------------------------------------------;
prompt
accept owner     char prompt 'PL/SQL Package Owner:  [] ';
accept objname   char prompt 'PL/SQL Package Name:   [] ';
accept procname  char prompt 'PL/SQL Proc/Func Name: [] ';
accept filename  char prompt 'Spool to <filename>:   [] ' default '&TMPDIR.plsdesc.lst';
prompt ------------------------------------------------------;
prompt

set heading off
set pause off
set termout off
set feedback off
set concat on
set verify off
set trimspool on

set long 20000;
set maxdata 60000;


clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a75
column pkg_name noprint
column obj_name noprint


rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
--set termout on

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt User Non-PL/SQL Objects Description Report;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Database Name :  &&dbname'|| chr(10) ||
       'prompt User Name     :  '||user||' '|| chr(10) ||
       'prompt Owner Name    :  &&owner'|| chr(10) ||
       'prompt Package Name  :  &&objname'|| chr(10) ||    
       'prompt Proc/Func Name:  &&procname'|| chr(10) ||
       'prompt Spool File    :  &&filename'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) from dual
/

--select 'prompt'|| chr(10) ||
--       'prompt ------------------------------------------------------;'|| chr(10) ||
--       'prompt User PL/SQL Objects Description Report;'|| chr(10) ||
--       'prompt ------------------------------------------------------;'|| chr(10) ||
--       'prompt'|| chr(10) from dual;
--
spool off

spool &TMPDIR.tmp_desc.sql

select  distinct(
       'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner Name    : '|| owner || chr(10) ||
       'prompt Package Name  : '|| package_name || chr(10) ||
       'prompt Proc/Func Name: '|| object_name || chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'desc ' || package_name )   command_line
       ,package_name pkg_name, object_name obj_name
  from all_arguments
 where owner like upper(nvl('%&&owner.%', '%'))
   and package_name like upper(nvl('%&&objname.%','%'))
   and object_name like upper(nvl('%&&procname.%','%'))
order by package_name asc, object_name asc
--order by package_name asc, object_name desc
/

--     'desc ' || package_name ||'.'|| object_name)   command_line
spool off

set heading on
set feedback 6
set termout on
set pause off
set verify off
spool &&filename
rem spool &TMPDIR.plsdesc.lst
start &TMPDIR.tmp_head.sql
start &TMPDIR.tmp_desc.sql
rem host rm &TMPDIR.tmp_head.sql
rem host rm &TMPDIR.tmp_desc.sql
spool off

undefine objname
undefine procname
undefine filename

rem exit
