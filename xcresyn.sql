
Rem 
Rem NAME
Rem   cresyn.sql 
Rem FUNCTION 
rem NAME
rem    cresyn.sql
rem FUNCTION
rem    create (public) synonym for Objects of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    07.07.99 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Create Synonym for Stored Objects Reports
prompt ----------------------------------------------------------------------;
prompt
accept ownname    char prompt 'Owner Name:  [USER] ';
accept objname    char prompt 'Object Name:     [] ';
accept objtype    char prompt 'Object Type:     [] ';
accept option     char prompt 'Scope:           [] ';
accept scriptfile char prompt 'Script File:     [] ' default '&TMPDIR.tmpcsyn.sql';
accept spoolfile  char prompt 'Spool  File:     [] ' default '&TMPDIR.tmpcsyn.lst';
prompt

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
       'prompt Create Synonym for Non-PL/SQL Objects ;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner  Name:    &&ownname'|| chr(10) ||
       'prompt Object Name:    &&objname'|| chr(10) ||
       'prompt Object Type:    &&objtype'|| chr(10) ||
       'prompt Public/Private: &&option'|| chr(10) ||
       'prompt'|| chr(10) from dual;

spool off

spool &&scriptfile

select rpad('----------------------------------------------------------- ',80,' ')||
       rpad('-- ',80,' ')||
       rpad('-- '||'$file:       &&scriptfile',80,' ')||
       rpad('-- ',80,' ')||
       rpad('-- '||'$comment:    ',80,' ')||
       rpad('-- ',80,' ')||
       rpad('-- '||'Object Name: '||upper('&&objtype') || ' ' ||upper('&&objname'),80,' ')||
       rpad('-- ',80,' ')||
       rpad('-- '||'Generated on '||sysdate||' by '||user,80,' ')||
       rpad('-- ',80,' ')||
       rpad('----------------------------------------------------------- ',80,' ') remarks
from   dual;

select 'prompt '|| chr(10) ||
       'prompt Create &&option. synonym '||object_name|| chr(10) ||
       'prompt  for '||NVL('&&ownname', USER)||'.'||object_name|| ' ...;' || chr(10) ||
       'create &&option. synonym '||object_name|| chr(10) ||
       ' for '||NVL('&&ownname', USER)||'.'||object_name|| ';' command_line
  from all_objects
where owner like upper(nvl('%&&ownname.%', USER))
  and object_name like upper(nvl('&&objname.%','%'))
  and object_type like upper(nvl('%&&objtype.%','%'))
 order by owner, object_name
/

spool off
set heading on
set feedback 6
set termout on
set verify on

spool &&spoolfile
start &&scriptfile
rem host rm &&scriptfile
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
