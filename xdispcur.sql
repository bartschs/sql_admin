rem NAME
rem   sqlplan.sql
rem FUNCTION
rem   gets info about user's sql plan
rem NOTE
rem   start from specified user with Admin priviledge
rem MODIFIED
rem   30.04.09 SBartsch - made it  
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

column ID               format 99999 heading "ID"
column OPERATION        format a20   heading "OPERATION"
column OPTIONS          format a25   heading "OPTIONS"
column OBJECT_NAME      format a30   heading "OBJECT_NAME"

prompt
prompt -----------------------------------------------------------;
prompt SQL Plan Report;
prompt -----------------------------------------------------------;
prompt
accept sql_id        char prompt 'SQL ID .................. : ' ;
accept child_cursor  char prompt 'Child Cursor ......... [0]: ' default '0';
accept format_param  char prompt 'Format Parameter [typical]: ' default 'typical';
accept filename      char prompt 'Spool to <filename>. .... : ' default '&TMPDIR.dispcur.lst';

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
       'Display Cursor Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'SQL ID        :  &&sql_id'|| chr(10) ||
       'Child Cursor  :  &&child_cursor'|| chr(10) ||
       'Format Param  :  &&format_param'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select * from table(dbms_xplan.display_cursor('&&sql_id',to_number(&&child_cursor), '&&format_param'))
/

spool off;

undefine sql_id
undefine child_cursor
undefine filename

set pagesize 22
set linesize 120

rem pause Press <Return> to continue;

rem exit
