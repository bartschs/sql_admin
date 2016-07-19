rem NAME
rem    plsddl.sql
rem FUNCTION
rem    This script extracts a PL/SQL object definition from the
rem    data dictionary and spools it to an operating system file.
rem    This version runs against the USER_* views:
rem    for use by application developers.
rem    Usage:    sqlplus -s un/pw @plsddl.sql
rem NOTE
rem    call from sqlplus as specified user
rem MODIFIED
rem    06.11.95 SBartsch  - made it
rem

set space 0;
set verify off;
set numwidth 4;
set heading off;
set linesize 256;
set pagesize 0;
set feedback off;
set recsep off;
set trimspool on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line2 format a256;

prompt
prompt ------------------------------------------------------;
prompt PL/SQL Object Creation Script Generator:
prompt ------------------------------------------------------;
prompt
rem accept objowner char prompt 'PL/SQL Object Owner: [] ';
accept objname  char prompt 'PL/SQL Object Name:  [] ';
accept objtype  char prompt 'PL/SQL Object Type:  [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.plsddl.lst';
prompt ------------------------------------------------------;
prompt Working...;

column remarks format a80;
column col1 format a256;

rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&filename;

rem Create a file header.
select rpad('rem '||'Filename: &&filename',80,' ')||
       rpad('rem '||'DBName  : &&dbname',80,' ')||
       rpad('rem '||'Auto-generated on '||sysdate||' by '||user||'.',80,' ')||
       rpad('rem '||' PL/SQL Object: '||upper('&&objtype') || ' '
	   ||upper('&&objname'),80,' ')||
       rpad(' ',80,' ') ||
       rpad('set scan off;',80,' ') remarks
from   dual;
rem       rpad('rem '||'Script to create the '||'&&objowner'||'.'||

rem Get the procedure source body.
select   rtrim(decode(line, 1,'create or replace '||text, text)) col1
  from   user_source
 where   name like upper(nvl('&&objname.%','%')) 
   and   type  = decode(upper('&&objtype'), 'BODY', 'PACKAGE BODY', 'SPEC', 'PACKAGE', upper('&&objtype'))
   and   type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
 order   by name, line;

rem where    owner = upper('&&objowner')
rem   and   type  like decode(upper(nvl('%&&objtype.%','%')), 'BODY', 'PACKAGE BODY', upper(nvl('%&&objtype.%','%')))
rem   and   type  = decode(upper('&&objtype'), 'BODY', 'PACKAGE BODY', upper('%&&objtype.%'))
rem   and   type = upper('&&objtype')

rem Add a slash at the end of the script to make it runnable.
select   '/'
from     dual;

rem Add a SHOW ERRORS at the end of the script for debugging reasons.
select 'SHOW ERRORS '
  from dual;

set heading on;
spool off;

rem pause Press <Return> to continue;

rem exit;
