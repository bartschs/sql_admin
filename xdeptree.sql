rem NAME
rem   xdeptree.sql
rem FUNCTION
rem   analyze schema#s dependency tree
rem NOTE
rem   start from user with DBA role
rem MODIFIED
rem   18.07.97 SBartsch - made it
rem


set serveroutput on size 1000000 format wrapped;
set trimspool on;
set termout off
--@@xutltree.sql
@@$SQLPATH/xutltree.sql
set termout on;
set verify off
set feedback off

prompt
prompt ---------------------------------------------------------------;
prompt Stored Objects Dependency Analysis 
prompt ---------------------------------------------------------------;
prompt
prompt ---------------------------------------------------------------;
prompt Available Types -> Package, Package Body, Procedure, Function
prompt ---------------------------------------------------------------;
prompt
accept schemaname char prompt 'Schema Name:     [USER] ';
accept objname    char prompt 'Object Name:         [] ';
accept objtype    char prompt 'Object Type:         [] ';
accept filename   char prompt 'Spool to <filename>: [] ' default '&TMPDIR.deptree.lst';
prompt ;
prompt Working...(This will take a while);

column dependencies format a75

declare
    schema_name      varchar2(30) := upper(nvl('&&schemaname', USER));
    object_name      varchar2(30) := upper('&&objname');
    object_type      varchar2(30) := upper('&&objtype');
begin
    xxx_deptree_fill (object_type, schema_name, object_name);
end;
/
prompt ;
prompt ;

set feedback on
set pagesize 200
set verify off
set heading on
set feedback 6
set termout on
set pause off
set verify off

spool &&filename
select * from xxx_ideptree;
spool off;

undefine schemaname
undefine objname
undefine objtype
undefine filename

set termout off
drop sequence xxx_deptree_seq
/
drop table xxx_deptree_temptab
/
drop procedure xxx_deptree_fill
/
drop view xxx_deptree
/
drop view xxx_ideptree
/
set termout on

