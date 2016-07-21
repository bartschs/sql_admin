rem NAME
rem    plscomp.sql
rem FUNCTION
rem    compiles PL/SQL source of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    06.11.95 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------------;
prompt Stored Objects Source Compile 
prompt ----------------------------------------------------------------------------;
prompt
prompt ----------------------------------------------------------------------------;
prompt Available Types -> Package, Package Body, Procedure, Function, View, Synonym
prompt ----------------------------------------------------------------------------;
prompt
rem accept owner char prompt 'Owner Name:       [USER] ';
accept objname   char prompt 'PL/SQL Object Name:   [] ';
accept objtype   char prompt 'PL/SQL Object Type:   [] ';
accept stat      char prompt 'Object Status: [INVALID] ';


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

column command_line1 format a75
column command_line2 format a75

spool &TMPDIR.allcomp.sql

select 'prompt '|| chr(10) ||
       'prompt Compiling '|| owner ||'.'||object_type || ' ' || object_name ||'...' || chr(10) ||
	   'ALTER ' || decode(object_type, 'PACKAGE BODY', 'PACKAGE', object_type) 
       || ' ' || owner ||'.'|| object_name || ' COMPILE' || ' ' ||
        decode(object_type, 'PACKAGE BODY', 'BODY', ' ') || ';' 
			       command_line1,
		 'SHOW ERRORS ' || object_type || ' ' || object_name
			       command_line2
  from all_objects
 where object_type IN ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER','VIEW','SYNONYM')
   and object_name like upper(nvl('%&&objname.%','%'))
   and object_type like upper(nvl('%&&objtype.%','%'))
   and status = upper(nvl('&&stat','INVALID'))   
/

spool off
set heading on
set feedback 6
set termout on
set verify on

spool   &TMPDIR.allcomp.lst
start   &TMPDIR.allcomp.sql
rem host rm &TMPDIR.allcomp.sql
spool off

set pause off
set verify off
set linesize 100

column object_name     format a30
column object_type     format a12 heading 'TYPE' 
column created         format a10
column last_ddl_time   format a10 heading 'MODIFIED'
column timestamp       format a10 heading 'TIMESTAMP'
column status          format a7

select object_name, object_type, created, last_ddl_time,
       substr(timestamp, nvl(instr(timestamp,':'),0) +1) timestamp, status 
  from user_objects 
 where object_name like upper(nvl('%&&objname.%','%'))
   and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER')
 order by object_name;

set heading on; 
undefine objname
undefine objtype
 
rem pause Press <Return> to continue;

rem exit
