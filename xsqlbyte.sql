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

column segment_name    format a25
column tablespace_name format a20 
column file_name       format a30

prompt
prompt -----------------------------------------------------------;
prompt USER Tablespace Report
prompt -----------------------------------------------------------;
prompt
accept filename char prompt 'Spool to <filename>: [] ' default '&TMPDIR.tmpbyte.lst';
rem prompt ------------------------------------------------------;

spool &&filename

rem
rem    show space used
rem

 select TABLESPACE_NAME, SEGMENT_NAME, SEGMENT_TYPE,  sum(BYTES) bytes_used
   from user_extents
  group by TABLESPACE_NAME, SEGMENT_NAME, SEGMENT_TYPE
/
rem
rem    show space used
rem

 select TABLESPACE_NAME, sum(BYTES) bytes_free
   from user_free_space
  group by TABLESPACE_NAME
/

spool off

