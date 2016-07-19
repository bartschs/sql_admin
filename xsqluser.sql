rem NAME
rem    sh_user.sql
rem FUNCTION
rem    lists all users of a database and their privileges/tablespaces
rem NOTE
rem    start as DBA
rem MODIFIED
rem    12.07.95 SBartsch - modified
rem    29.11.94 SBartsch - modified
rem    06.07.92 SBartsch - made it
rem

set verify off

column username  	        format a13  heading 'USER'
column profile              format 9    heading 'PROFILE'
column created              format 9    heading 'CREATION'
column default_tablespace   format a15  heading 'DEF-TS'
column temporary_tablespace format a15  heading 'TMP-TS'

accept username    char prompt 'User Name:   [] ';

select username, 
       profile, 
       created, 
       default_tablespace, 
       temporary_tablespace
  from sys.dba_users
 where username like upper(nvl('%&&username.%','%'))
 order by username;


undefine username




