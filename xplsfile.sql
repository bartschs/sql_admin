rem NAME
rem    plsfile.sql
rem FUNCTION
rem    run given SQL script to create/replace PL/SQL source(s)
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    06.11.95 SBartsch  - made it
rem

set pause off
rem set termout off
set feedback off
set concat on
set verify off

rem spool &&2/&&3

start &&1

rem spool off

rem pause Press <Return> to continue;

exit
