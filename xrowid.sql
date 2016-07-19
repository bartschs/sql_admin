rem NAME
rem   rowid.sql
rem FUNCTION
rem   gets info about ROWID for a given row
rem NOTE
rem   start from specified user with Admin priviledge
rem MODIFIED
rem   16.04.10 SBartsch - made it  
rem

set verify off;
set heading off;
set trimspool on;
set feedback off;
set pagesize 2000
set linesize 200 

clear columns
clear breaks
clear computes

ttitle off
btitle off

column SID              format 99999 heading "SID"
column CHILD_NUMBER     format 99999 heading "CHILD"
column SQL_TEXT         format a15   heading "SQL_TEXT"

prompt
prompt -----------------------------------------------------------;
prompt ROWID Report;
prompt -----------------------------------------------------------;
prompt
accept v_rowid       char prompt 'Oracle ROWID........ : ' ;
accept filename      char prompt 'Spool to <filename>. : ' default '&TMPDIR.rowid.lst';

rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&filename

select '------------------------------------------------------'|| chr(10) ||
       'ROWID Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Oracle ROWID  :  &&v_rowid'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select DBMS_ROWID.ROWID_OBJECT('&&v_rowid') "OBJECT",
       DBMS_ROWID.ROWID_RELATIVE_FNO('&&v_rowid') "FILE",
       DBMS_ROWID.ROWID_BLOCK_NUMBER('&&v_rowid') "BLOCK",
       DBMS_ROWID.ROWID_ROW_NUMBER('&&v_rowid') "ROW"
 from dual
/

spool off;

undefine v_rowid
undefine filename

set pagesize 22
set linesize 120

rem pause Press <Return> to continue;

rem exit
