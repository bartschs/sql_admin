rem
rem NAME
rem     sh_spid.sql
rem FUNCTION
rem     get user's session info
rem NOTE
rem     start from sqlplus/sqldba
rem MODIFIED
rem     11.11.98 SBartsch - made it
rem

set verify off;
set heading on;
set feedback off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column spid  format 9999999 heading "SPID"

prompt -----------------------------------------------------------;
prompt User Session Info Report 
prompt -----------------------------------------------------------;

select SPID
from v$process
where addr = (
      select PADDR
      from v$session
      where AUDSID = SYS_CONTEXT('USERENV', 'SESSIONID')
)
/
prompt
