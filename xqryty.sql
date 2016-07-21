rem NAME
rem   qryty.sql
rem FUNCTION
rem   gets info about schema's type tables
rem NOTE
rem   start from specified user
rem MODIFIED
rem   06.11.01 SBartsch - made it  
rem

set trimspool on;
set verify off;
set feedback off;
set heading off;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a80

column OBJECT_NAME        format a30
column SHORT_DESCRIPTION  format a7
column DESCRIPTION        format a35
column LONG_DESCRIPTION   format a15
column SORTING            format 999999999
column VALID              format 9

prompt ----------------------------------------------------------------------;
prompt CC/Rating/Billing System Type Description Report
prompt ----------------------------------------------------------------------;
prompt
accept schemaprefix char prompt 'Schema Prefix: [] ';
accept tablematch   char prompt 'Table Match  : [] ';
accept scriptfile   char prompt 'Script File  : [] ' default '&TMPDIR.tmp_ty.sql';
accept filename     char prompt 'Spool File   : [] ' default '&TMPDIR.tmp_ty.lst';

set heading off
set linesize 80
set pause off
set termout off
set feedback off
set concat on
set verify off
set long 20000;
set maxdata 60000;
set pagesize 2000;
set linesize 100;

column obj_type noprint
column obj_name noprint

spool &&scriptfile

select distinct('-- '|| chr(10) ||
       'PROMPT => Report on table '||object_name||' (-> '||
	substr(object_name,1,3)||'$TA_DESCRIPTION)' ||chr(10)||
       'select t.'||substr(object_name,8)|| chr(10) ||
       '      ,d.SHORT_DESCRIPTION' || chr(10) ||
       '      ,d.DESCRIPTION' || chr(10) ||
       '      ,d.LONG_DESCRIPTION' || chr(10) ||
       '      ,t.SORTING' || chr(10) ||
       '      ,t.VALID' || chr(10) ||
       '  from '||object_name||' t, '||substr(object_name,1,3)||'$ta_description d' ||chr(10)||
       ' where t.DESCRIPTION_ID = d.DESCRIPTION_ID' || chr(10) ||
       ' order by 1' || ';') command_line
       ,object_type obj_type, object_name obj_name
  from all_objects 
 where object_type like upper('%synonym%')      
   and (object_name like upper('&&schemaprefix.$ta%&&tablematch.%'))
-- and (object_name like upper('rbs$ta%') or
--      object_name like upper('rbc$ta%') or
--      object_name like upper('rbx$ta%') or
--      object_name like upper('xhs$ta%') or
--      object_name like upper('swi$ta%'))
   and (object_name like upper('%_ty') or
        object_name like upper('%_st') or
        object_name like upper('%_cv'))
 order by object_name
/
--     '      ,d.LONG_DESCRIPTION' || chr(10) ||

spool off
set heading on
set feedback on
set termout on
set verify on

spool &&filename
start &&scriptfile
rem start &TMPDIR.tmp_ty.sql
rem host rm &TMPDIR.tmp_ty.sql
spool off

set verify off
set linesize 100

set heading on;

undefine schemaprefix
undefine scriptfile
undefine filename

