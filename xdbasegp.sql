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
set linesize 120;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column owner             format a12          heading 'OWNER'
column name              format a30          heading 'SEGMENT'
column partition         format a20          heading 'PARTITION'
column segment_type      format a8           heading 'TYPE'
column tbs               format a20          heading 'TBS'
column bytes             format 990,000.000  heading 'G_BYTES'
column max               format 990,000.000  heading 'MAX_EXT'
column inital            format 990,000.000  heading 'IN_EXT'
column blocks            format 9999999999   heading 'BLOCKS'

prompt -----------------------------------------------------------;
prompt DBA Segments Report
prompt -----------------------------------------------------------;
accept ownname  char prompt 'Owner Name:      [] ';
accept tbsname  char prompt 'Tablespace Name: [] ';
accept segname  char prompt 'Segment Name:    [] ';
accept partname char prompt 'Partition Name:  [] ';
accept sorting  char prompt 'Order by:    [name] ' default 'name';
accept filename char prompt 'Spool File:      [] ' default '&TMPDIR.dbasegp.lst';

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
       'Partition Name  :  &&partname'|| chr(10) ||
       'Order by        :  &&sorting'|| chr(10) ||
       'Spool File      :  &&filename'|| chr(10) ||
       '------------------------------------------------------'|| chr(10) from dual
/

set heading on;
set feedback on;

--select segment_name, partition_name, segment_type, tablespace_name, bytes, blocks
--select tablespace_name, segment_name, sum(bytes)/1024/1024 bytes
select distinct *
from
(
select  seg.tablespace_name  tbs 
       ,tab.table_owner  owner    
       ,tab.table_name  name    
       ,tab.partition_name partition
       ,seg.bytes/1024                
       --,seg.extents                  
--     ,tab.max_extent  
--     ,tab.initial_extent/1024
--     ,tab.next_extent/1024
       ,tab.pct_increase 
       --,tab.pct_free          
       ,tab.num_rows           
       --,tab.pct_used        
       ,tab.blocks           
       ,sum(seg.bytes)/1024  bytes  
from    sys.dba_segments seg
       ,sys.dba_tab_partitions   tab
 where  tab.table_owner like upper(nvl('&&ownname','%'))
   and  tab.table_name like upper(nvl('&&segname.%','%'))
   and  tab.partition_name like upper(nvl('&&partname.%','%'))
   and  tab.tablespace_name like upper(nvl('&&tbsname','%'))
   and  seg.tablespace_name = tab.tablespace_name
   and  seg.owner = tab.table_owner
   and  seg.segment_name = tab.table_name 
   --and  seg.partition_name = tab.partition_name 
group by seg.tablespace_name, seg.segment_name
)
-- order by tablespace_name, segment_type, segment_name
 order by &&sorting
--order by 1,2,3
/


spool off

undefine ownname 
undefine tbsname 
undefine segname 
undefine partname 
undefine sorting
undefine filename 


