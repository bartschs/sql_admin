rem NAME
rem   dbaexts.sql
rem FUNCTION
rem   gets info about SYSTEMs table extents 
rem NOTE
rem   start from specified user
rem MODIFIED
rem   23.01.03 SBartsch - made it  
rem

set trimspool on;
set verify off;
set feedback off;
--set heading off;

clear columns
clear breaks
clear computes

--ttitle off
--btitle off

set pause off;
--set echo off;
set linesize 150;
set pagesize 60;

column c1  heading "Tablespace";
column c2  heading "Owner";
column c3  heading "Table";
column c12 heading "Partition";
column c4  heading "Size (KB)";
column c5  heading "Alloc. Ext";
column c6  heading "Max Ext";
column c7  heading "Init Ext (KB)";
column c8  heading "Next Ext (KB)";
column c9  heading "% Inc";
rem column c10 heading "% Free";
column c10 heading "Num Rows";
rem column c11 heading "% Used";
column c11 heading "Blocks";
column c12 heading "Sum Bytes";

prompt
prompt -----------------------------------------------------------;
prompt User DB-Extents Report
prompt -----------------------------------------------------------;
prompt
accept ownname  char prompt 'Owner Name:      [] ';
accept objname  char prompt 'Table Name:      [] ';
accept partname char prompt 'Partition Name:  [] ';
accept tbsname  char prompt 'Tablespace Name: [] ';
accept filename char prompt 'Spool File:      [] ' default '&TMPDIR.dbaexts.lst';

spool &&filename

break on c1 skip 2 on c2 skip 2

ttitle "Partioned Tables";

select  substr(seg.tablespace_name,1,10) c1
       ,substr(tab.table_owner,1,10)     c2
       ,substr(tab.table_name,1,20)      c3
       --,substr(tab.partition_name,1,20)  c12
       ,substr(tab.partition_name,1,30)  c12
       ,seg.bytes/1024                   c4 
       ,seg.extents                      c5
       ,tab.max_extent                   c6
       ,tab.initial_extent/1024          c7
       ,tab.next_extent/1024             c8
       ,tab.pct_increase                 c9
       --,tab.pct_free                    c10
       ,tab.num_rows                    c10
       --,tab.pct_used                    c11
       ,tab.blocks                      c11
       --,sum(seg.bytes)/1024             c12
from    sys.dba_segments seg,
        sys.dba_tab_partitions   tab
 where  tab.table_owner like upper(nvl('&&ownname','%'))
   and  tab.table_name like upper(nvl('&&objname.%','%'))
   and  tab.partition_name like upper(nvl('&&partname.%','%'))
   and  tab.tablespace_name like upper(nvl('&&tbsname','%'))
   and  seg.tablespace_name = tab.tablespace_name
  and   seg.owner = tab.table_owner
  and   seg.segment_name = tab.table_name 
  --and   seg.partition_name = tab.partition_name 
order by 1,2,3
/

spool off;

--  and   seg.extents > 10

undefine ownname  
undefine objname 
undefine tbsname 
undefine filename
