set trimspool on;
set serveroutput on size 1000000 format wrapped;
set pagesize 2000;
set linesize 200;

set verify off;
set feedback off;

prompt
prompt -----------------------------------------------------------;
prompt Generate Snapshot Refresh Scripts 
prompt -----------------------------------------------------------;
prompt
accept objname  char prompt 'Snapshot Name: ..... [] ' default '%';
accept master   char prompt 'Master Name: ....... [] ' default '%';
accept method   char prompt 'Fast/Complete (F|C) [F] ' default 'F';
accept filename char prompt 'Spool File: .......  [] ' default 'refresh_all_fast.sql';
rem prompt ------------------------------------------------------;

spool &&filename

declare
  i_replica_name   varchar2(30) := upper('&&objname');
  i_master_name    varchar2(30) := upper('&&master');
  i_method char(1) := upper('&&method');
  --
  l_REPLICA_OWNER     varchar2(30);
  l_REPLICA_NAME      varchar2(30);
  l_REPLICA_USER      varchar2(30) := USER;
  cursor c_replica (
     i_replica_name IN VARCHAR2
    ,i_master_name  IN VARCHAR2
  )
  is 
   select REPLICA_OWNER
	 ,REPLICA_NAME 
     from rbr$ta_replica
    where replica_name like upper(nvl('%'||i_replica_name||'%','%'))
      and master_name  like upper(nvl('%'||i_master_name||'%','%'))
    order by REPLICA_NAME;
begin
  --fetch c_replica into l_REPLICA_OWNER, l_REPLICA_NAME;
  for cloop in c_replica(i_replica_name, i_master_name) loop
    --exit when c_replica%NOTFOUND;
    dbms_output.put_line('PROMPT ');
    dbms_output.put_line('PROMPT Refresh: '||cloop.replica_name||';');
    dbms_output.put_line('PROMPT Method:  '||i_method||';');
    dbms_output.put_line('PROMPT ');
    dbms_output.put_line('execute DBMS_SNAPSHOT.REFRESH( -'||chr(10)||
                         ' list   => '''||l_REPLICA_USER||'.'||cloop.replica_name||''', - '||chr(10)||
                         ' method => '''||i_method||''' -' ||chr(10)||
                         ');');
  end loop;  
end;
/

spool off
