rem
rem NAME
rem   dbakill.sql
rem FUNCTION
rem   kill Non-system user sessions
rem NOTE 
rem   start from sqlplus/sqldba as DBA
rem MODIFIED
rem   07.06.10 SBartsch - made it
rem   

set trimspool on;
set verify off;
--set heading on;
set heading off;
set feedback off;
set trimspool on;

rem set long 20000;
rem set maxdata 60000;
rem set pagesize 20000;


column sid       format 99999 heading "SID";
column id        format 99999 heading "ID";
column name      format a40 heading "Parameter";

prompt -----------------------------------------------------------;
prompt Kill User Session Report;
prompt -----------------------------------------------------------;
accept sid       char prompt 'Oracle SID ........: ';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.dbakill.lst';


rem
rem get current DB Name
rem

set termout off
define dbname=xxx
column currname new_value dbname
select global_name currname from global_name;
set termout on

spool &&spoolfile;

select '------------------------------------------------------'|| chr(10) ||
       'Kill User Session Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Oracle SID    :  &&sid'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

prompt -----------------------------------------------------------------------------------------;

begin
for i in (
  select distinct a.sid, a.serial#
    from v$session a, v$access b
   where a.sid = b.sid
     AND a.sid = nvl('&&sid', a.sid)
     AND b.TYPE <> 'NON-EXISTENT'
     AND (b.owner IS NOT NULL)
     AND (b.owner <> 'SYSTEM')
     AND (b.owner <> 'SYS')
     AND (b.TYPE in ('PACKAGE', 'TABLE'))
     AND (SUBSTR(OBJECT,1,3) IN( 'RBT','RBS','RBC','RBR','CCS','RBP','XHS','SWI','RBV','RBI','USM','CBD','RBW'))
  ) loop
  BEGIN
     dbms_output.put_line('Killing session SID/Serial#: '||i.sid||','||i.serial#);
     execute immediate 'alter system kill session '''||i.sid||','||i.serial#||''' immediate';
  EXCEPTION
     WHEN others THEN
        dbms_output.put_line('Error when killing SID/Serial#: '||i.sid||','||i.serial#||' -> '||SQLERRM);
  END;
end loop;
end;
/

prompt -----------------------------------------------------------------------------------------;
prompt 

spool off;

undefine sid
undefine spoolfile
