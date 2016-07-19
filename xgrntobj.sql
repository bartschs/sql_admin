
Rem 
Rem NAME
Rem   grntobj.sql 
Rem FUNCTION 
rem NAME
rem    rbm_grant.sql
rem FUNCTION
rem    grant SQL Objects of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    09.04.98 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Grant Stored Objects Reports
prompt ----------------------------------------------------------------------;
prompt
accept ownname    char prompt 'Owner Name:   [USER] ';
accept objname    char prompt 'Object Name:      [] ';
accept objtype    char prompt 'Object Type:      [] ';
accept privs      char prompt 'Privilege(s):     [] ';
accept grantee    char prompt 'Grantee:          [] ';
accept option     char prompt 'Grant Option:     [] ';
accept scriptfile char prompt 'Script File:      [] ' default '&TMPDIR.tmpgrant.sql';
accept spoolfile  char prompt 'Spool  File:      [] ' default '&TMPDIR.tmpgrant.lst';

set serveroutput on size 1000000 format wrapped;
set trimspool on;

set heading off
set linesize 100
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

column command_line format a90

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Grant Non-PL/SQL Objects ;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner  Name:   &&objname'|| chr(10) ||
       'prompt Object Name:   &&objname'|| chr(10) ||
       'prompt Object Type:   &&objtype'|| chr(10) ||
       'prompt Privilege:     &&privs'|| chr(10) ||
       'prompt Grantee:       &&grantee'|| chr(10) ||
       'prompt Script File:   &&scriptfile'|| chr(10) ||
       'prompt'|| chr(10) from dual;

spool off

spool &&scriptfile

declare
   i_ownname   varchar2(30) := NVL('&&ownname', USER);
   i_objname   varchar2(30) := '&&objname';
   i_objtype   varchar2(30) := '&&objtype';
   i_privs     varchar2(30) := '&&privs';
   i_grantee   varchar2(255) := '&&grantee';
   i_option    varchar2(255) := '&&option';
   i_scriptfile  varchar2(255) := '&&scriptfile';
   --l_stmt      all$pa_types.sql_stmnt;
   l_stmt      VARCHAR2(32767);
   --l_processed all$pa_types.cur_rows;
   l_processed INTEGER;
   l_grantee   varchar2(255) := i_grantee||',';
   l_all_grantee   varchar2(255);
   l_tmp_grantee varchar2(255);
   l_tmp_instr INTEGER;
   --------------------------------------
--
   cursor c_objects (
       i_ownname   varchar2
      ,i_objname   varchar2
      ,i_objtype   varchar2
   ) 
   IS
   select object_name
     from all_objects
    where owner like upper(nvl('%'||i_ownname||'%', USER))
 -- where owner like upper(nvl('%'||i_ownname||'%','%'))
      and object_name like upper(nvl(''||i_objname||'%','%'))
      and object_type like upper(nvl(''||i_objtype||'%','%'))
    order by owner, object_name;

--
   FUNCTION execute_DynSQL(
      i_stmt  IN VARCHAR2
   )
   RETURN INTEGER
   IS
      l_rows_processed      INTEGER;
      l_cursor              INTEGER;
      l_rc INTEGER;
--
   BEGIN
       l_cursor := dbms_sql.open_cursor;
       dbms_sql.parse(l_cursor, i_stmt, dbms_sql.native);
       l_rows_processed := dbms_sql.execute(l_cursor);
       dbms_sql.close_cursor(l_cursor);
--
      RETURN l_rows_processed;
--
    EXCEPTION
      WHEN OTHERS THEN
            raise;

   END; -- execute_DynSQL;
--
begin
   l_all_grantee := replace(l_grantee,' ', '');
   l_tmp_grantee := l_all_grantee;
   --
   dbms_output.put_line(rpad('------------------------------------------------------- ',80,' '));
   dbms_output.put_line(rpad('-- ',80,' '));
   dbms_output.put_line(rpad('-- '||'$file:       '||i_scriptfile,80,' '));
   dbms_output.put_line(rpad('-- ',80,' '));
   dbms_output.put_line(rpad('-- '||'$comment:    ',80,' '));
   dbms_output.put_line(rpad('-- ',80,' '));
   dbms_output.put_line(rpad('-- '||'Object Name: '||upper(i_objtype)
                                  ||' '||upper(i_objname),80,' '));
   dbms_output.put_line(rpad('-- ',80,' '));
   dbms_output.put_line(rpad('-- '||'Generated on '||sysdate||' by '||user,80,' '));
   dbms_output.put_line(rpad('-- ',80,' '));
   dbms_output.put_line(rpad('------------------------------------------------------- ',80,' '));
   dbms_output.put_line('PROMPT ');
   --
   for list_obj in c_objects(i_ownname, i_objname, i_objtype)
   loop
       while instr(l_tmp_grantee, ',') > 0
       loop
          l_tmp_instr := instr(l_tmp_grantee, ',');
          l_grantee := substr(l_tmp_grantee, 1, l_tmp_instr -1);
          dbms_output.put_line('PROMPT Grant '||i_privs||' on '||i_ownname||'.'|| list_obj.object_name);
          dbms_output.put_line('PROMPT  to '||l_grantee||' '||i_option||';');
          dbms_output.put_line('grant '||i_privs||' on '||i_ownname||'.'|| list_obj.object_name);
          dbms_output.put_line(' to '||l_grantee||' '||i_option||';');
--        l_stmt := 'grant '||i_privs||' on '||i_ownname||'.'|| list_obj.object_name;
--        l_stmt := l_stmt||' to '||l_grantee||' '||i_option;
--        l_processed := execute_DynSQL(l_stmt);
--        dbms_output.put_line('PROMPT '|| l_processed ||' rows processed ...;');
          dbms_output.put_line('PROMPT ');
          dbms_output.put_line(' ');
          l_tmp_grantee := substr(l_tmp_grantee, l_tmp_instr +1 );
       end loop;
       l_tmp_grantee := l_all_grantee;
       --
   end loop;
end;
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
undefine privs
undefine grantee
undefine option

rem pause Press <Return> to continue;

rem exit
