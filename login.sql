-------------------------------------------------------------------------------
--
-- NAME
--     login.sql
-- FUNCTION
--     login settings for SQL*Plus
-- NOTE
--     - Verify that SQLPATH variable is correctly set
--     - Check UNIX/DOS environment variable for temporary directory
-- MODIFIED
--     20.01.2000 SBartsch - review
--     07.01.1998 SBartsch - made it
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- preferred Editor 
-------------------------------------------------------------------------------
define _editor = vi

-------------------------------------------------------------------------------
-- login default settings for SQL*Plus
-------------------------------------------------------------------------------
set echo off
set linesize  120
set underline   "-"
set verify      on
set space       1
set termout     on
set doc         off
set pause       off
set null        ""
set pagesize    22
set heading     on
set feedback    off
set editfile    sql.sql
set concat      .
set describe depth all linenum off indent on

-------------------------------------------------------------------------------
-- default settings for DBMS_OUTPUT
-------------------------------------------------------------------------------
set serveroutput on
execute dbms_output.enable(100000)

-------------------------------------------------------------------------------
-- clear SQL*Plus Report settings
-------------------------------------------------------------------------------
clear columns
clear breaks
clear computes

ttitle off
btitle off

-------------------------------------------------------------------------------
-- some useful definitions/settings
-------------------------------------------------------------------------------
--var zahl number
--var text varchar2(100)

col object_name         for a30
col table_name          for a30
col db_link             for a30
col comments            for a60 word_wrapped

-------------------------------------------------------------------------------
-- directory separator -> Take care of UNIX/DOS differences
-------------------------------------------------------------------------------
define S  = '/'                 -- Unix directory separator
-- define S  = '\'                 -- DOS directory separator
define TMPDIR  = '$TMP&S'       -- Unix temporary directory
-- define TMPDIR  = '%TEMP%&S'     -- DOS temporary  directory

-------------------------------------------------------------------------------
-- NLS_DATE_FORMAT defaults
-------------------------------------------------------------------------------
-- alter session set nls_date_format='dd.mm.syyyy hh24:mi:ss';
alter session set nls_date_format='dd.mm.yyyy hh24:mi:ss';
--alter session set NLS_NUMERIC_CHARACTERS='.,';

-------------------------------------------------------------------------------
-- set default Prompting
-------------------------------------------------------------------------------

set termout off
set heading off
set feedback off

set termout off
--set arraysize 1
define var_prompt=SQL>
column user_prompt new_value var_prompt
select '"'|| substr(global_name,1,instr(global_name,'.')-1) || '('||USER||')> "' user_prompt
 from global_name;
--
-- keep the 'arraysize' setting due to Oracle8 enhancements on catalog views -> varchar2(4000)
--set arraysize 15
set termout on

set sqlprompt &&var_prompt
undefine var_prompt

set termout on
set heading on
set feedback on


