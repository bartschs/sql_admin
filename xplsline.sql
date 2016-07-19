rem NAME
rem   plsline.sql
rem FUNCTION
rem   gets complete info about all stored objects within a range of lines
rem NOTE
rem   start from user with DBA role
rem MODIFIED
rem   06.11.95 SBartsch - made it
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
prompt Stored Objects Source Line Report
prompt -----------------------------------------------------------;
prompt
accept objname  char prompt 'Stored Object Name : [] ';
accept objtype  char prompt 'Stored Object Type : [] ';
accept scanline char prompt 'Scan Area (+5/-5)  : [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.plsline.lst';

column name       new_value varname   noprint
column type       new_value vartype   noprint
column varname    format a15
column vartype    format a10
column varline    format 99999
column outline    format a105

spool &&filename


break on name skip 1 -
      on type skip page

ttitle left '--------------------------------------' skip 1 -
            'Object: ' varname  skip 1 -
            'Type:   ' vartype  skip 1 -
	    '--------------------------------------' skip 1 -
	    '                                      '

select name, type,
       decode('&&scanline',
	          to_char(line) ,' --> '||to_char(line,'99990')  ||' '||text,
	          '     '||to_char(line,'99990') ||' '||text) outline
from user_source
 where type  like decode(upper(nvl('%&&objtype.%','%')), 'BODY', 'PACKAGE BODY', upper(nvl('%&&objtype.%','%')))
   and type  in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'PROCEDURE')
   and name  like upper(nvl('%&&objname.%','%'))
   and line between (&&scanline - 5) and (&&scanline + 5)
 order by name, type, line;

spool off;

set heading on;
undefine objname
undefine objtype
undefine scanline
undefine varname
undefine vartype

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
