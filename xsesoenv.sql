rem
rem NAME
rem   sh_sesoenv.sql
rem FUNCTION
rem   lists values of the v$ses_optimizer_env view
rem NOTE 
rem   start from sqlplus/sqldba as DBA
rem MODIFIED
rem   20.06.07 SBartsch - made it
rem   

set trimspool on;
set verify off;
set heading on;
set heading off;
set feedback off;
set trimspool on;

rem set long 20000;
rem set maxdata 60000;
set pagesize 20000;


column sid       format 99999 heading "SID";
column id        format 99999 heading "ID";
column name      format a40 heading "Parameter";
column value     format a15 heading "Value";
column isdefault format a10 heading "Default?";

prompt -----------------------------------------------------------;
prompt Session Optimizer Environment Report;
prompt -----------------------------------------------------------;
accept sid       char prompt 'Oracle SID ........: ';
accept param     char prompt 'Session Parameter  : ';
accept spoolfile char prompt 'Spool to <filename>: ' default '&TMPDIR.sesoenv.lst';


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
       'Session Optimizer Environment Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Run On        :  '||sysdate||' '|| chr(10) ||
       'Oracle SID    :  &&sid'|| chr(10) ||
       'Parameter     :  &&param'|| chr(10) ||
       'Spool File    :  &&spoolfile'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading off;

prompt SID    ID     Parameter                                Value           Default?
prompt ------ ------ ---------------------------------------- --------------- --------;

select sid
      ,id
      ,name
      ,value
      ,isdefault
  from v$ses_optimizer_env
 where name like '&&param.%'
   and sid = nvl('&&sid', sid)
 order by sid, name;

prompt -------------------------------------------------------------------------------;
prompt 

spool off;

undefine sid
undefine param
undefine spoolfile
