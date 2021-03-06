rem NAME
rem   plsfind.sql
rem FUNCTION
rem   search for text string within stored objects (-> grep)
rem NOTE
rem   start from SQL*Plus as user
rem MODIFIED
rem   03.12.97 SBartsch - made it
rem


set verify off
set linesize 100
set arraysize 4
set long 10000
set maxdata 30000
set pagesize 22;
set heading off
set feedback off

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt Stored Objects String Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Stored Object Owner: [] ';
accept objname  char prompt 'Stored Object Name:  [] ';
accept objtype  char prompt 'Stored Object Type:  [] ';
accept objtext  char prompt 'Stored Object Text:  [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.dbagrep.lst';

column OWNER      format a12 noprint
column name       new_value varname   noprint
column type       new_value vartype   noprint

column varname    format a15
column vartype    format a10

spool &&filename


break on name skip 1 -
      on type skip page

ttitle left '--------------------------------------' skip 1 -
            'Object: ' varname  skip 1 -
            'Type:   ' vartype  skip 1 -
	    '--------------------------------------' skip 1 -
	    '                                      '

select name, type,
      '  '||to_char(line,'99990') ||' '||text outline
from dba_source
   where owner like upper(nvl('%&&ownname.%','%')) 
   and type like decode(upper('&&objtype'),
                          'BODY', 'PACKAGE BODY',
                          'SPEC', 'PACKAGE',
                          upper(nvl('%&&objtype.%','%')))
   and type  in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
   and name  like upper(nvl('%&&objname.%','%'))
   and upper(text)  like upper(nvl('%&&objtext.%','%'))
 order by name, type;

rem  where type  like upper(nvl('%&&objtype.%','%'))
spool off;

set heading on;

undefine ownname
undefine objname
undefine objtype
undefine objtext
undefine varname
undefine vartype
undefine filename

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
