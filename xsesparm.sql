rem
rem NAME
rem   sh_sesoenv.sql
rem FUNCTION
rem   lists values of the v$ses_optimizer_env/v$parameter view
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
set pagesize 2000;


column sid       format 99999 heading "SID";
column id        format 99999 heading "ID";
column name      format a40 heading "Parameter";
column value     format a30 heading "Value";
column isdefault format a8  heading "Default?";
column sesinfo   format a4  heading "Info";

prompt -----------------------------------------------------------;
prompt Session Parameter Environment Report;
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
       'Session Paramater Environment Report'|| chr(10) ||
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

--prompt SID    Parameter                                Value                Default? Info
--prompt ------ ---------------------------------------- -------------------- -------- ----;
prompt SID    Parameter                                Value                          Default? Info
prompt ------ ---------------------------------------- ------------------------------ -------- ----;

select b.sid
      ,a.name
      ,case when b.name is not null then b.value else a.value end value
      ,case when b.name is not null then b.isdefault else a.isdefault end isdefault
      ,case when b.name is not null then 'YES' else 'NO' end sesinfo
 from ( select name, value, isdefault 
          from v$parameter
         where isses_modifiable = 'TRUE' ) a,
      ( select sid, name, value, isdefault
          from v$ses_optimizer_env ) b
 where a.name = b.name (+)
   and a.name like '&&param.%'
   and (b.sid = '&&sid' or b.sid is null)
 order by sid, name
/

prompt ----------------------------------------------------------------------------------------------;
--prompt ------------------------------------------------------------------------------------;
prompt 

spool off;

undefine sid
undefine param
undefine spoolfile
