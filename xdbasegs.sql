rem NAME
rem     sh_seg.sql
rem FUNCTION
rem     gets info about user's segments
rem NOTE
rem     start as DBA
rem MODIFIED
rem     12.07.95 SBartsch - made it   
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

column owner             format a12          heading 'OWNER'
column name              format a30          heading 'SEGMENT'
column segment_type      format a8           heading 'TYPE'
column tbs               format a20          heading 'TBS'
column bytes             format 990,000.000  heading 'G_BYTES'
column blocks            format 9999999999   heading 'BLOCKS'

prompt -----------------------------------------------------------;
prompt DBA Segments Report
prompt -----------------------------------------------------------;
accept ownname  char prompt 'Owner Name:      [] ';
accept tbsname  char prompt 'Tablespace Name: [] ';
accept segname  char prompt 'Segment Name:    [] ';
accept segtype  char prompt 'Segment Type:    [] ';
accept sorting  char prompt 'Order by:    [name] ' default 'name';
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
       'Owner Name      :  &&ownname'|| chr(10) ||
       'Tablespace Name :  &&tbsname'|| chr(10) ||
       'Segment Name    :  &&segname'|| chr(10) ||
       'Segment Type    :  &&segtype'|| chr(10) ||
       'Order by        :  &&sorting'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

--select segment_name, partition_name, segment_type, tablespace_name, bytes, blocks
--select tablespace_name, segment_name, sum(bytes)/1024/1024 bytes
select *
from
(
select owner, segment_name name, segment_type, sum(bytes)/1024/1024 bytes, tablespace_name tbs
  from dba_segments 
 where owner like upper(nvl('%&&ownname.%','%'))
   and tablespace_name like upper(nvl('%&&tbsname.%','%'))
   and segment_name like upper(nvl('%&&segname.%','%'))
   and segment_type like upper(nvl('%&&segtype','%'))
 group by owner, segment_name, segment_type, tablespace_name
-- group by tablespace_name, segment_name
)
-- order by tablespace_name, segment_type, segment_name
 order by &&sorting
/


spool off

undefine ownname 
undefine tbsname 
undefine segname 
undefine segtype 
undefine sorting
undefine filename 


