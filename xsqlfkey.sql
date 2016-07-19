rem NAME
rem   sqlfkey.sql
rem FUNCTION
rem   gets info about user's foreign key constraints
rem NOTE
rem   start from specified user
rem MODIFIED
rem   17.02.98 SBartsch - made it  
rem

/*
 all_cons_columns
 Name                            Null?    Type
 ------------------------------- -------- ----
 OWNER                           NOT NULL VARCHAR2(30)
 CONSTRAINT_NAME                 NOT NULL VARCHAR2(30)
 TABLE_NAME                      NOT NULL VARCHAR2(30)
 COLUMN_NAME                     NOT NULL VARCHAR2(30)
 POSITION                                 NUMBER

 all_constraints
 Name                            Null?    Type
 ------------------------------- -------- ----
 OWNER                           NOT NULL VARCHAR2(30)
 CONSTRAINT_NAME                 NOT NULL VARCHAR2(30)
 CONSTRAINT_TYPE                          VARCHAR2(1)
 TABLE_NAME                      NOT NULL VARCHAR2(30)
 SEARCH_CONDITION                         LONG
 R_OWNER                                  VARCHAR2(30)
 R_CONSTRAINT_NAME                        VARCHAR2(30)
 DELETE_RULE                              VARCHAR2(9)
 STATUS                                   VARCHAR2(8)
*/

set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column table_name     	format a20 heading 'TABLE'
column constraint_name	format a20 heading 'CONSTRAINT'
column col_name		format a15 heading 'COLUMN' 
column ref_table	format a20 heading 'REF_TABLE' 
column ref_column	format a15 heading 'REF_COLUMN' 
column status		format a7

prompt
prompt -----------------------------------------------------------;
prompt Table Foreign Key Constraints Report
prompt -----------------------------------------------------------;
prompt
prompt Constraint Status: => + = enabled, - = disabled
prompt
accept tabname  char prompt 'Table Name:      [] ';
accept consname char prompt 'Constraint Name: [] ';
accept filename char prompt 'Spool File:      [] ' default '&TMPDIR.sqlfkey.lst';

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
       'Table Foreign Key Constraints Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name   :  &&dbname'|| chr(10) ||
       'User Name       :  '||user||' '|| chr(10) ||
       'Table Name      :  &&tabname'|| chr(10) ||
       'Constraint Name :  &&consname'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

select  acc1.TABLE_NAME
      , acc1.CONSTRAINT_NAME
    ,   acc1.COLUMN_NAME COL_NAME
--    ,   ac1.CONSTRAINT_TYPE
--    ,   ac1.SEARCH_CONDITION
--    ,   ac1.DELETE_RULE
    ,   decode(ac1.STATUS, 'ENABLED', '+', 'DISABLED', '-') S
--    ,   ac1.R_CONSTRAINT_NAME
    ,   acc2.TABLE_NAME "REF_TABLE"
    ,   acc2.COLUMN_NAME "REF_COLUMN"
from    all_cons_columns    acc1,
        all_cons_columns    acc2,
        all_constraints     ac1
where   acc1.table_name like upper(nvl('%&&tabname.%','%'))
and     acc1.table_name         = ac1.table_name
and     acc1.constraint_name    like upper(nvl('&&consname.%','%'))
and     acc1.constraint_name    = ac1.constraint_name
and     ac1.r_constraint_name   = acc2.constraint_name
and     ac1.constraint_type = 'R'
order by acc1.constraint_name, acc1.position
/


spool off;

undefine tabname
undefine consname

rem pause Press <Return> to continue;

rem exit
