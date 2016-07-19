
Rem 
Rem NAME
Rem   sqlstat.sql 
Rem FUNCTION 
rem NAME
rem    cresyn.sql
rem FUNCTION
rem    generate statistics for tables of specified user
rem NOTE
rem    call from sqlplus as specified user 
rem MODIFIED
rem    22.01.01 SBartsch  - made it
rem

prompt
prompt ----------------------------------------------------------------------;
prompt Generate Statistics for Non-PL/SQL Objects
prompt ----------------------------------------------------------------------;
prompt
accept ownname    char prompt 'Owner Name:      [USER] ';
accept objname    char prompt 'Object Name:         [] ';
accept objtype    char prompt 'Object Type:         [] ';
accept method     char prompt 'Method:      [ESTIMATE] ' default 'ESTIMATE';
accept estproc    char prompt 'Estimate Percent:    [] ';
accept estrows    char prompt 'Estimate Rows:       [] ';
accept scriptfile char prompt 'Script File:         [] ' default '&TMPDIR.tmptstat.sql';
accept spoolfile  char prompt 'Spool  File:         [] ' default '&TMPDIR.tmptstat.lst';
accept runscript  char prompt 'Run Script?:   (Y/N) [] ' default 'N';
prompt ;
rem prompt Working...(This will take a while);

set heading off
set linesize 80
set pause off
set termout off
set feedback off
set concat on
set verify off

clear columns
clear breaks
clear computes

ttitle off
btitle off

column command_line format a80

spool &TMPDIR.tmp_head.sql

select 'prompt'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Generate Statistics for Non-PL/SQL Objects ;'|| chr(10) ||
       'prompt ------------------------------------------------------;'|| chr(10) ||
       'prompt Owner  Name:  &&objname'|| chr(10) ||
       'prompt Object Name:  &&objname'|| chr(10) ||
       'prompt Object Type:  &&objtype'|| chr(10) ||
       'prompt Method     :  &&method'|| chr(10) ||
       'prompt Estim. Proc:  &&estproc'|| chr(10) ||
       'prompt Estim. Rows:  &&estrows'|| chr(10) ||
       'prompt'|| chr(10) from dual;


spool off

spool &&scriptfile

select 'set timing on;' command_line
  from dual
/

select 'prompt '|| chr(10) ||
       'prompt Analyze table '||owner||'.'||object_name|| chr(10) ||
       'prompt  &&method. statistics ...;' || chr(10) ||
       'analyze table '||owner ||'.'||object_name|| chr(10) ||
       ' &&method. statistics '|| chr(10) ||
        decode(upper('&&method') 
              ,'ESTIMATE ROWS' 
              ,' FOR TABLE FOR ALL INDEXED COLUMNS FOR ALL INDEXES SAMPLE &&estrows. rows'
              ,'ESTIMATE PERCENT' 
              ,' FOR TABLE FOR ALL INDEXED COLUMNS FOR ALL INDEXES SAMPLE &&estproc. percent'
              ,'ESTIMATE' 
              ,' FOR TABLE FOR ALL INDEXED COLUMNS FOR ALL INDEXES SAMPLE &&estproc. percent'
              ,' FOR TABLE FOR ALL INDEXED COLUMNS FOR ALL INDEXES ') ||
       ' ;' command_line
  from all_objects
where owner like upper(nvl('%&&ownname.%', USER))
  and object_name like upper(nvl('&&objname.%','%'))
  and object_type like upper(nvl('%&&objtype.%','%'))
 order by owner, object_name
/

select 'set timing off;' command_line
  from dual
/

spool off
set heading on
set feedback 6
set termout on
set verify on

spool &&spoolfile
start &&scriptfile
rem host rm &&scriptfile
spool off

set verify off
set linesize 100

set heading on; 

undefine ownname
undefine objname
undefine objtype
undefine method    
undefine estrows  
undefine estproc  

rem pause Press <Return> to continue;

rem exit
