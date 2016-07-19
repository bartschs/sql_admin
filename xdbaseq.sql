rem NAME
rem     sh_seq.sql
rem FUNCTION
rem     gets info about USER sequences 
rem NOTE
rem     start as USER
rem MODIFIED
rem     02.12.99 SBartsch - made it
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

column sequence_owner  format a14        heading 'OWNER'
column sequence_name   format a25        heading 'SEQUENCE'
column min_value       format 999999     heading 'MIN' 
column max_value       format 9999999999 heading 'MAX'
column cycle_flag      format a5         heading 'CYCLE'
column order_flag      format a5         heading 'ORDER'
column increment_by    format 99         heading 'INCR'
column cache_size      format 99         heading 'CACHE'
column last_number     format 9999999999 heading 'LAST'

prompt -----------------------------------------------------------;
prompt User Sequences Report
prompt -----------------------------------------------------------;
accept owner    char prompt 'Owner Name:    [] ';
accept seqname  char prompt 'Sequence Name: [] ';
accept filename char prompt 'Spool File:    [] ' default '&TMPDIR.sqlseq.lst';

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
       'User Sequences Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name :  &&dbname'|| chr(10) ||
       'User Name     :  '||user||' '|| chr(10) ||
       'Owner Name    :  &&owner'|| chr(10) ||
       'Sequence Name :  &&seqname'|| chr(10) ||
       'Spool File    :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;


select sequence_owner
      ,sequence_name
      ,min_value
      ,max_value
      ,increment_by
      ,cycle_flag
      ,order_flag
      ,cache_size
      ,last_number
  from dba_sequences 
 where sequence_owner like upper(nvl('%&&owner.%','%'))
   and sequence_name like upper(nvl('%&&seqname.%','%'))
/

spool off;

undefine dbname
undefine owner
undefine seqname
undefine filename

rem pause Press <Return> to continue;

