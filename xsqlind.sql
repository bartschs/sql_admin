rem NAME
rem   sqlind.sql
rem FUNCTION
rem   gets info about user's object indexes
rem NOTE
rem   start from specified user
rem MODIFIED
rem   11.06.99 SBartsch - made it  
rem

/*
 all_indexes
 Name                            Null?    Type
 ------------------------------- -------- ----
 OWNER                           NOT NULL VARCHAR2(30)
 INDEX_NAME                      NOT NULL VARCHAR2(30)
 TABLE_OWNER                     NOT NULL VARCHAR2(30)
 TABLE_NAME                      NOT NULL VARCHAR2(30)
 TABLE_TYPE                               CHAR(5)
 UNIQUENESS                               VARCHAR2(9)
 TABLESPACE_NAME                 NOT NULL VARCHAR2(30)
 INI_TRANS                       NOT NULL NUMBER
 MAX_TRANS                       NOT NULL NUMBER
 INITIAL_EXTENT                           NUMBER
 NEXT_EXTENT                              NUMBER
 MIN_EXTENTS                     NOT NULL NUMBER
 MAX_EXTENTS                     NOT NULL NUMBER
 PCT_INCREASE                    NOT NULL NUMBER
 FREELISTS                                NUMBER
 FREELIST_GROUPS                          NUMBER
 PCT_FREE                        NOT NULL NUMBER
 BLEVEL                                   NUMBER
 LEAF_BLOCKS                              NUMBER
 DISTINCT_KEYS                            NUMBER
 AVG_LEAF_BLOCKS_PER_KEY                  NUMBER
 AVG_DATA_BLOCKS_PER_KEY                  NUMBER
 CLUSTERING_FACTOR                        NUMBER
 STATUS                                   VARCHAR2(11)

 all_ind_columns
 Name                            Null?    Type
 ------------------------------- -------- ----
 INDEX_OWNER                     NOT NULL VARCHAR2(30)
 INDEX_NAME                      NOT NULL VARCHAR2(30)
 TABLE_OWNER                     NOT NULL VARCHAR2(30)
 TABLE_NAME                      NOT NULL VARCHAR2(30)
 COLUMN_NAME                     NOT NULL VARCHAR2(30)
 COLUMN_POSITION                 NOT NULL NUMBER
 COLUMN_LENGTH                   NOT NULL NUMBER
*/

set verify off;
set heading off;
set trimspool on;
set feedback off;
set pagesize 2000

clear columns
clear breaks
clear computes

ttitle off
btitle off

column owner           format a12
column table_type      format a5  heading 'TYPE'
column status          format a2  heading 'ST'
column uniqueness      format a2  heading 'UQ'

column TABLE_OWNER      format a13      heading "TABLE OWNER"
column TABLE_NAME       format a30      heading "TABLE NAME"
column INDEX_OWNER      format a10      heading "INDEX OWNER"
column INDEX_NAME       format a30      heading "INDEX NAME"
column COLUMN_POSITION  format 999      heading "POS"
column COLUMN_NAME      format a20      heading "COLUMN"

prompt
prompt -----------------------------------------------------------;
prompt Table Index Report;
prompt -----------------------------------------------------------;
prompt
accept townname      char prompt 'Table Owner ....: [] ';
accept tabname       char prompt 'Table Name  ....: [] ';
rem accept iownname      char prompt 'Index Owner ....: [] ';
accept indname       char prompt 'Index Name .....: [] ';
accept indstat       char prompt 'Index Status ...: [] ';
accept colname       char prompt 'Column Name ....: [] ';
accept filename      char prompt 'Spool to <filename>: ' default '&TMPDIR.sqlind.lst';

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
       'Table Index Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Owner Name    :  &&townname'|| chr(10) ||
       'Object Name   :  &&tabname'|| chr(10) ||
       'Index Name    :  &&indname'|| chr(10) ||
       'Index Status  :  &&indstat'|| chr(10) ||
       'Column Name   :  &&colname'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;


break on TABLE_OWNER on TABLE_NAME skip 1 on INDEX_OWNER on  INDEX_NAME skip 1 on STATUS

select  aic.table_owner
       ,aic.table_name
--       ,aic.index_owner
       ,aic.index_name
       ,decode(ai.status, 
	      'VALID', '1', 
	      'INVALID', '-1', 
	      'DISABLED', '0', 
	      ai.status) status
       ,substr(ai.uniqueness,1,1) uniqueness
       ,aic.column_position
       ,aic.column_name
from    all_ind_columns aic
       ,all_indexes ai
where   ai.owner = aic.index_owner
  and   ai.index_name = aic.index_name
  and   ai.table_owner = aic.table_owner
  and   ai.table_name = aic.table_name
  and   ai.status like upper(nvl('%&&indstat.%','%'))
  and   aic.table_owner like upper(nvl('%&&townname.%','%'))
  and   aic.table_name like upper(nvl('%&&tabname.%','%'))
  and   aic.index_name like upper(nvl('%&&indname.%','%'))
  and   aic.column_name like upper(nvl('%&&colname.%','%'))
--  and   aic.index_name not like 'I_SNAP$%'  
order by 1,2,3,6
--order by 1,2,3,5
/

rem   and   aic.index_owner like upper(nvl('%&&iownname.%','%'))
spool off;

undefine dbname
undefine townname
undefine tabname
undefine iownname
undefine indname
undefine filename

set pagesize 22

rem pause Press <Return> to continue;

rem exit
