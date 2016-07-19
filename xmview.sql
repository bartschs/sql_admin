rem NAME
rem    mview.sql
rem FUNCTION
rem    This script gets row count info of MView definitions 
rem    from the data dictionary/Billing Ressource Management 
rem    and spools it to an operating system file.
rem    
rem    for use by application developers.
rem    -- Usage:    sqlplus -s un/pw @mview.sql
rem NOTE
rem    call from sqlplus as specified user
rem MODIFIED
rem    29.06.10 SBartsch  - made it
rem


set trimspool on;
set verify off;
set linesize 100;
set arraysize 4;
set long 10000;
set maxdata 30000;
set pagesize 100;
set heading off;
set feedback off;

set newpage 0
set pagesize 0

clear columns
clear breaks
clear computes

ttitle off
btitle off

prompt
prompt -----------------------------------------------------------;
prompt User MView Row Count Report
prompt -----------------------------------------------------------;
prompt
accept objname    char prompt 'MView Name ........................... : ' ;
accept objtype    char prompt 'Content Type ID ................... [0]: ' default '0';
accept restrict   char prompt 'Where Clause (e.g. "where rownum < 2") : ' ;
accept filename   char prompt 'Spool to <filename> ...................: ' default '&TMPDIR.tmview.lst';


rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
--set termout on


spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt User MView Row Count Report'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Database Name    :  &&dbname'|| chr(10) ||
       'prompt User Name        :  '||user||' '|| chr(10) ||
       'prompt Run On           :  '||sysdate||' '|| chr(10) ||
       'prompt MView Name       :  &&objname'|| chr(10) ||
       'prompt Object Type      :  &&objtype'|| chr(10) ||
       'prompt Where Clause     :  &&restrict'|| chr(10) ||
       'prompt Spool File       :  &&filename'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) || 
       'prompt '|| chr(10) || chr(10) from dual
/

--       'spool &&filename                                      '|| chr(10) from dual
spool off

column command_line1 format a80
column command_line2 format a80
column command_line3 format a80

set termout off

spool &TMPDIR.tmp_row.sql

select 'select rpad('''|| table_name ||''', 30, '' '')||'' ,''||' command_line1,
       'count(*) from ' command_line2,
       table_name || ' '|| '&&restrict' || chr(10) ||
       '/ ' command_line3
  from (
        SELECT DISTINCT
               ST.table_name 
          FROM RBS$TA_RS_TY        TY,
               RBS$TA_RS_EC        EC,
               RBS$TA_RS_STORAGE   ST
         WHERE TY.rs_ty = EC.rs_ty
           AND EC.content_type_id = '&&objtype'
           AND ST.rs_ty = EC.rs_ty
       )
 where table_name like upper(nvl('&&objname.%','%'))
 order by table_name;

spool off

spool &TMPDIR.tmp_foot.sql

set heading off;
set verify off;
set feedback off;

select 'spool off; '|| chr(10) from dual
/

spool off;

set termout on;

set trimspool on;
set heading off;
set pagesize 0;
set verify off;
set timing off;
set feedback off;
rem spool &TMPDIR.&&filename.lst
rem spool &TMPDIR.sqlrow.lst
spool &&filename
start &TMPDIR.tmp_head.sql
start &TMPDIR.tmp_row.sql
start &TMPDIR.tmp_foot.sql
--host rm &TMPDIR.tmp_head.sql
--host rm &TMPDIR.tmp_row.sql
--host rm &TMPDIR.tmp_foot.sql


undefine ownname 
undefine objname 
undefine objtype 
undefine restrict 
undefine filename


rem exit
