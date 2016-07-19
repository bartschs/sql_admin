rem NAME
rem     sort_seg.sql
rem FUNCTION
rem     gets info about user's segments
rem NOTE
rem     start as DBA
rem MODIFIED
rem     27.03.07 SBartsch - made it   
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

column tablespace_name   format a20          heading 'TBS'
column bytes             format 990,000.000  heading 'G_BYTES'
column blocks            format 9999999999   heading 'BLOCKS'

prompt -----------------------------------------------------------;
prompt DBA Sort Segments Report
prompt -----------------------------------------------------------;
accept tbsname  char prompt 'Tablespace Name: [] ';
accept filename char prompt 'Spool File:      [] ' default '&TMPDIR.dbaseg.lst';

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
       'DBA Segments Report'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) ||
       'Database Name   :  &&dbname'|| chr(10) ||
       'User Name       :  '||user||' '|| chr(10) ||
       'Tablespace Name :  &&tbsname'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

--select segment_name, partition_name, segment_type, tablespace_name, bytes, blocks
--select owner, segment_name, sum(bytes)/1024/1024 bytes, tablespace_name
select tablespace_name, total_blocks, used_blocks, free_blocks, current_users
  from v$sort_segment 
 where 
       tablespace_name like upper(nvl('%&&tbsname.%','%'))
-- group by tablespace_name
-- group by tablespace_name, segment_name
-- order by tablespace_name, segment_type, segment_name
/


spool off

rem undefine tbsname 
rem undefine filename 


