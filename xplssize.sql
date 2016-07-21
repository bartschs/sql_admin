rem NAME
rem   plssize.sql
rem FUNCTION
rem   gets info about PL/SQL object size in the DB
rem NOTE
rem   start from specified user
rem MODIFIED
rem   06.11.95 SBartsch - made it  
rem

set verify off

clear columns
clear breaks
clear computes

ttitle off
btitle off

column name            format a30
column type            format a12      heading 'TYPE' 
column source_size     format 999999 heading 'SOURCE'
column parsed_size     format 999999 heading 'PARSED'
column code_size       format 999999 heading 'CODE'
column error_size      format 999999 heading 'ERROR'

spool &TMPDIR.plssize

prompt
prompt -----------------------------------------------------------;
prompt PL/SQL Object Size Report
prompt -----------------------------------------------------------;
prompt
accept objname  char prompt 'PL/SQL Object: [] ';

select name, type, source_size, parsed_size, code_size, error_size 
  from user_object_size 
 where name like upper(nvl('%&&objname.%','%'));

spool off;

rem pause Press <Return> to continue;
   
rem exit
