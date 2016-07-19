rem NAME
rem   sqlfbi.sql
rem FUNCTION
rem   gets info about function-based Index Expression 
rem NOTE
rem   start from specified user
rem MODIFIED
rem   23.07.02 SBartsch - made it  
rem

set verify off;
set heading off;
set feedback off;
set trimspool on;

set long 40000;
set maxdata 60000;
set pagesize 2000;
--set pagesize 0;
set linesize 80;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column INDEX_OWNER   format a12
column INDEX_NAME    format a30 
column TABLE_NAME    format a30 
 
rem spool &TMPDIR.sqlview
prompt
prompt -----------------------------------------------------------;
prompt User SQL Function-Based-Index Report
prompt -----------------------------------------------------------;
prompt
accept ownname   char prompt 'Owner Name: [] ';
accept indname   char prompt 'Index Name: [] ';
accept filename  char prompt 'Spool File: [] ' default '&TMPDIR.sqlfbi.lst' ;
prompt
prompt ------------------------------------------------------;
prompt

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
       'User SQL Function-Based-Index Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Owner Name    :  &&ownname'|| chr(10) ||
       'Index Name    :  &&indname'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

--set feedback on;

column index_owner      new_value var_index_owner     noprint
column index_name       new_value var_index_name      noprint
column table_owner      new_value var_table_owner     noprint
column table_name       new_value var_table_name      noprint
column column_position  new_value var_column_position noprint

column var_index_owner      format a20
column var_index_name       format a30
column var_table_owner      format a30
column var_table_name       format a30
column var_column_position  format 99999

break on index_owner on index_name skip 1 -
      on table_name skip page

--break on TABLE_OWNER on TABLE_NAME skip 1 on INDEX_OWNER on  INDEX_NAME 

ttitle left '--------------------------------------' skip 1 -
            'Owner:    ' var_index_owner  skip 1 -
            'Table:    ' var_table_name   skip 1 -
            'Index:    ' var_index_name   skip 1 -
            '--------------------------------------' skip 1 -
            '                                      '

select index_owner, table_name, index_name, column_position, column_expression  
  from all_ind_expressions
 where index_owner like upper(nvl('%&&ownname.%','%'))
   and index_name like upper(nvl('%&&indname.%','%'))
 order by index_owner, table_name, index_name, column_position;
 
spool off;

undefine dbname
undefine ownname
undefine indname
undefine filename

set heading on;
set long 80;
set maxdata 60000;
set pagesize 22;

clear columns
clear breaks
clear computes

ttitle off
btitle off

rem pause Press <Return> to continue;

rem exit
  
