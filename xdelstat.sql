
Rem 
Rem NAME
Rem   delstat.sql 
Rem FUNCTION 
rem NAME
rem    cresyn.sql
rem FUNCTION
rem    delete statistics for tables of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    07.07.99 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Delete Statistics for Stored Objects Reports
prompt ----------------------------------------------------------------------;
prompt
accept ownname   char prompt 'Owner Name:   [] ';
accept objname   char prompt 'Object Name:  [] ';
accept objtype   char prompt 'Object Type:  [] ';

set heading off
set linesize 80
set pause off
set termout off
set feedback off
set concat on
set verify off

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a80

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Delete Statistics for Non-PL/SQL Objects ;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner  Name:    &&objname'|| chr(10) ||
       'prompt Object Name:    &&objname'|| chr(10) ||
       'prompt Object Type:    &&objtype'|| chr(10) ||
       'prompt'|| chr(10) from dual;

spool off

spool &TMPDIR.tmpdstat.sql

select 'prompt '|| chr(10) ||
       'prompt Analyze table '||object_name|| chr(10) ||
       'prompt  delete statistics ...;' || chr(10) ||
       'analyze table '||object_name|| chr(10) ||
       ' delete statistics ;' command_line
  from all_objects
where owner like upper(nvl('%&&ownname.%','%'))
  and object_name like upper(nvl('&&objname.%','%'))
  and object_type like upper(nvl('%&&objtype.%','%'))
 order by owner, object_name
/

spool off
set heading on
set feedback 6
set termout on
set verify on

spool &TMPDIR.tmpdstat.lst;
start &TMPDIR.tmpdstat.sql
rem host rm &TMPDIR.tmpdstat.sql
spool off

set verify off
set linesize 100

set heading on; 

undefine ownname
undefine objname
undefine objtype

rem pause Press <Return> to continue;

rem exit
