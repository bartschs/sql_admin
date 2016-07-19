rem NAME
rem    objdrop.sql
rem FUNCTION
rem    drop Schema objects of specified user
rem NOTE
rem    call from sqlplus as specified user
rem MODIFIED
rem    15.03.99 SBartsch  - add "decode(upper(nvl('&&objname','####'))..." to avoid dropping all objects
rem    06.11.95 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Drop Schema Objects Reports
prompt ----------------------------------------------------------------------;
prompt
prompt ----------------------------------------------------------------------;
prompt Available Types:; 
prompt -> PACKAGE, PACKAGE BODY, PROCEDURE, FUNCTION, TRIGGER;
prompt -> DATABASE LINK, SYNONYM, SEQUENCE,; 
prompt -> INDEX, TABLE, TABLE PARTITION, VIEW;
prompt ----------------------------------------------------------------------;
prompt
rem accept owner char prompt 'Owner Name: ..... [USER] ';
accept objname   char prompt 'Object Name: ........ [] ';
accept objtype   char prompt 'Object Type: ........ [] ';
accept stat      char prompt 'Object Status: [INVALID] ';


set heading off;
set linesize 80;
set pagesize 0;
set pause off;
set termout off;
set feedback off;
set concat on;
set verify off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line1 format a75
column command_line2 format a75

spool &TMPDIR.objdrop.sql

select 'prompt '|| chr(10) ||
       'prompt Drop '|| object_type || ' ' || object_name ||'...' || chr(10) ||
	   -- 'DROP ' || decode(object_type, 'PACKAGE BODY', 'PACKAGE', object_type)
	   'DROP ' || object_type
       || ' ' || object_name || ';'  command_line1
  from user_objects
 where object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER',
                       'DATABASE LINK', 'INDEX', 'SEQUENCE', 'SYNONYM', 'TABLE', 'TABLE PARTITION', 'VIEW')
   and object_name like decode(upper(nvl('&&objname','####')),
                               '####', '####',
                               upper('%&&objname.%'))
   and object_type like decode(upper('&&objtype'),
                               'BODY', 'PACKAGE BODY',
                               'SPEC', 'PACKAGE',
                               'LINK', 'DATABASE LINK',
                               upper(nvl('%&&objtype.%','%')))
   and object_type != 'UNDEFINED'
   and status like decode(upper('&&stat'),
                          'ALL', '%',
                          upper(nvl('&&stat','INVALID')))
order by object_type 
/
rem    and object_type like upper(nvl('%&&objtype.%','%'))
rem    and status = upper(nvl('&&stat','INVALID'))

spool off
set heading on
set feedback 6
set termout on
set verify on

spool   &TMPDIR.objdrop.lst
start   &TMPDIR.objdrop.sql
rem host rm &TMPDIR.objdrop.sql
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
 where object_name like decode(upper(nvl('&&objname','####')),
                               '####', '####',
                               upper('%&&objname.%'))
   and object_type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE', 'TRIGGER', 'UNDEFINED',
                       'DATABASE LINK', 'INDEX', 'SEQUENCE', 'SYNONYM', 'TABLE', 'TABLE PARTITION', 'VIEW')
 order by object_name;

set heading on;
undefine objname
undefine objtype
undefine stat

rem pause Press <Return> to continue;

rem exit
