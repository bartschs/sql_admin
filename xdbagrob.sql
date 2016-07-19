rem
rem NAME
rem     sh_gr_obj.sql
rem FUNCTION
rem     gets info about grants on objects (user is owner, grantor, grantee)
rem NOTE 
rem     start from sqlplus for specified table owner
rem MODIFIED
rem     07.07.95 SBartsch - made it  
rem   

set trimspool on;
set verify off;
set heading on;

clear columns
clear breaks
clear computes

ttitle off
btitle off

column owner           format a14
column table_name      format a28 heading 'OBJECT_NAME'
column grantee         format a15 
column privilege       format a20 
column grantor         format a15 


prompt
prompt -----------------------------------------------------------;
prompt Grants On Objects Report
prompt -----------------------------------------------------------;
prompt
accept tablename  char prompt 'Object Name : [] '
accept owner      char prompt 'Owner :       [] '
accept grantee    char prompt 'Grantee:      [] '
accept privilege  char prompt 'Privilege:    [] '
accept filename   char prompt 'Spool File:   [] ' default '&TMPDIR.sqlgrob.lst';
rem prompt ------------------------------------------------------;

spool &&filename

select owner, table_name, privilege, grantee, grantor, grantable
  from dba_tab_privs
 where owner like upper(nvl('%&&owner.%', '%'))
   and table_name like upper(nvl('%&&tablename.%', '%'))
   and grantee like upper(nvl('%&&grantee.%', '%'))
   and privilege like upper(nvl('&&privilege.%', '%'))
 order by owner, table_name, grantee, privilege
/

undefine tablename  
undefine owner     
undefine grantee   
undefine privilege 
undefine filename  

spool off;
