rem NAME
rem   depend.sql
rem FUNCTION
rem   search for SQL objects dependencies 
rem NOTE
rem   start from SQL*Plus as user
rem MODIFIED
rem   27.03.02 SBartsch - made it
rem


set verify off
set linesize 100
set arraysize 4
set long 10000
set maxdata 30000
set pagesize 40;
set heading off
set feedback off

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt SQL Objects Dependencies Report
prompt -----------------------------------------------------------;
prompt
accept objname  char prompt 'Object Name........: [] ';
accept objtype  char prompt 'Object Type........: [] ';
accept objref   char prompt 'Referenced Object..: [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.depend.lst';

set arraysize 1;
rem set colsep ',';
set feedback off;
set heading off;
set line 32000;
set pagesize 0;
set termout off;
rem set termout off;
set termout on;
set trimout on;
set trimspool on;
set verify off;

column name              new_value varname   noprint
column type              new_value vartype   noprint
column referenced_name   new_value varref    noprint

spool &&filename

select distinct name, referenced_name, name || ',' || referenced_name  outline 
  from all_dependencies
 where type like upper(nvl('%&&objtype.%','%'))
   and name like upper(nvl('%&&objname.%','%'))
   and (name not like 'RBI$VI_TMP_%')
   and (referenced_name != 'STANDARD')
   and referenced_name like upper(nvl('%&&objref.%','%'))
order by substr(name, 12), substr(name, 8), referenced_name
/

rem   where type like decode(upper('&&objtype'),
rem                          'BODY', 'PACKAGE BODY',
rem                          'SPEC', 'PACKAGE',
rem                          upper(nvl('%&&objtype.%','%')))
rem   and type  in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')

spool off;

set heading on;
undefine objname
undefine objtype
undefine objref
undefine filename

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
