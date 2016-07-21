rem NAME 
rem     sh_bytes.sql
rem FUNCTION
rem    show sum of bytes and tablespaces as current user 
rem NOTE
rem    start as DBA
rem MODIFIED
rem    06.07.92 SBartsch  - made it
rem 

set trimspool on;
set verify off;
set feedback off;
set heading on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column segment_name    format a25
column tablespace_name format a20 
column file_name       format a30

prompt
prompt -----------------------------------------------------------;
prompt DB Tablespace Byte Report
prompt -----------------------------------------------------------;
prompt
accept tbsname  char prompt 'Tablespace Name:     [] ';
accept objname  char prompt 'Table Name:          [] ';
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.dbabyte.lst';
rem prompt ------------------------------------------------------;

spool &&filename

rem
rem    show space used
rem

 select TABLESPACE_NAME, SEGMENT_NAME, SEGMENT_TYPE,  sum(BYTES) bytes_used
   from dba_extents
  where
         tablespace_name like upper(nvl('&&tbsname.%','%'))
    and  segment_name like upper(nvl('&&objname.%','%'))
  group by TABLESPACE_NAME, SEGMENT_NAME, SEGMENT_TYPE
/
rem
rem    show space used
rem

 select TABLESPACE_NAME, sum(BYTES) bytes_free
   from dba_free_space
  where
         tablespace_name like upper(nvl('&&tbsname.%','%'))
  group by TABLESPACE_NAME
/

spool off

undefine objname 
undefine tbsname 
undefine filename

