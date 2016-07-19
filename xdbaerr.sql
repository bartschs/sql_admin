rem NAME
rem   xplserr.sql
rem FUNCTION
rem   gets info about user's stored PL/SQL objects errors
rem NOTE
rem   start from specified user
rem MODIFIED
rem   19.11.97 SBartsch - made it
rem

set verify off;
set heading on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column OWNER           format a12

prompt
prompt -----------------------------------------------------------;
prompt Stored Object Error Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name:    [] ';
accept objname  char prompt 'Stored Object Name: [] ';

column outline format a105 heading 'Error Listing';
break on err_text skip 2;

set linesize 105;
rem set pagesize 0;
rem set pause off;
spool &TMPDIR.plserr

SELECT
decode(to_char(us.line), to_char(ue.line-7),ue.text,
                         to_char(ue.line-6),'',
                         to_char(ue.line+6),'',
                         to_char(ue.line)  ,'   --> '||to_char(us.line,'99990')
                                                     ||' '||us.text
                                           ,'       '||to_char(us.line,'99990')
                                                     ||' '||us.text) outline
  from dba_source us, dba_errors ue
 where us.owner like upper(nvl('%&&ownname.%','%'))
   and us.name like upper(nvl('%&&objname.%','%'))
   and us.line between (ue.line-7) and (ue.line+6)
   and us.owner = ue.owner
   and us.name = ue.name
   and us.type = ue.type
-- This predicate is put here to elminate this useless fallout error
   and ue.text != 'PL/SQL: Statement ignored'
/
spool off

rem set pause on;
rem set pagesize 22;
set heading on;

rem exit
