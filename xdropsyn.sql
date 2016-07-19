
Rem 
Rem NAME
Rem   dropsyn.sql 
Rem FUNCTION 
rem NAME
rem    dropsyn.sql
rem FUNCTION
rem    drop (public) synonym for Objects of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    07.07.99 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Drop Synonym for Stored Objects Reports
prompt ----------------------------------------------------------------------;
prompt
accept ownname   char prompt 'Owner Name:   [] ';
accept objname   char prompt 'Object Name:  [] ';
accept objtype   char prompt 'Object Type:  [] ';
accept option    char prompt 'Scope:        [] ';

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
       'prompt Drop Synonym for Non-PL/SQL Objects ;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner  Name:    &&objname'|| chr(10) ||
       'prompt Object Name:    &&objname'|| chr(10) ||
       'prompt Object Type:    &&objtype'|| chr(10) ||
       'prompt Public/Private: &&option'|| chr(10) ||
       'prompt'|| chr(10) from dual;

spool off

spool &TMPDIR.tmpdsyn.sql

select 'prompt '|| chr(10) ||
       'prompt Drop &&option. synonym '||object_name|| ' ...;' || chr(10) ||
       'drop &&option. synonym '||object_name|| ';' command_line
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

spool &TMPDIR.tmpdsyn.lst;
start &TMPDIR.tmpdsyn.sql
rem host rm &TMPDIR.tmpdsyn.sql
spool off

set verify off
set linesize 100

set heading on; 

undefine ownname
undefine objname
undefine objtype
undefine option

rem pause Press <Return> to continue;

rem exit
