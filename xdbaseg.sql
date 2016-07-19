rem NAME
rem     sh_seg.sql
rem FUNCTION
rem     gets info about user's segments
rem NOTE
rem     start as DBA
rem MODIFIED
rem     12.07.95 SBartsch - made it   
rem

set verify off

column owner             format a12       heading 'OWNER'
column segment_name      format a22       heading 'SEGMENT'
column segment_type      format a20       heading 'SEG_TYPE'
column tablespace_name   format a20       heading 'TBS'
column bytes             format 99999999  heading 'K_BYTES'
column blocks            format 999999    heading 'BLOCKS'

prompt -----------------------------------------------------------;
prompt User Segments Report
prompt -----------------------------------------------------------;
accept ownname  char prompt 'Owner Name:      [] ';
accept tbsname char prompt  'Tablespace Name: [] ';
accept segname char prompt  'Segment Name:    [] ';
accept segtype char prompt  'Segment Type:    [] ';
accept filename char prompt 'Spool File:      [] ' default '&TMPDIR.dbaseg.lst';

spool &&filename

--select segment_name, partition_name, segment_type, tablespace_name, bytes, blocks
select segment_name
      ,segment_type
      --,partition_name
      ,tablespace_name
      --,sum(bytes) 
	  ,sum(bytes)/1024  bytes
      --,blocks 
  from dba_segments 
 where owner like upper(nvl('&&ownname','%'))
   and tablespace_name like upper(nvl('%&&tbsname.%','%'))
   and segment_name like upper(nvl('%&&segname.%','%'))
   and segment_type like upper(nvl('%&&segType','%'))
 group by segment_name, tablespace_name, segment_type
       --, partition_name 
       --,blocks
-- order by tablespace_name, segment_type, segment_name
/


spool off

undefine ownname 
undefine segname 
undefine segtype 
undefine filename 


