rem
rem NAME
rem   sh_unuse.sql
rem FUNCTION
rem   listing of unused space from tables and indexes
rem NOTE
rem   call from sqlplus as user system
rem MODIFIED
rem   30.08.97 SBartsch - add for loop, sum up totals
rem   04.07.97 SBartsch - made it
rem

prompt -----------------------------------------------------------;
prompt Unused Space Report
prompt -----------------------------------------------------------;
accept owner char   prompt  'Object(s) Owner:     [] ';
accept objname char prompt  'Object Name:         [] ';
accept objtype char prompt  'Object Type:         [] ';
accept filename char prompt 'Spool to <filename>: [] ';
prompt ;

set trimspool on;
set serveroutput on;
set heading off;
set pause off;
set feedback off;
set verify off;

spool &&filename;

declare
    lv_owner_name  varchar2(39) := upper('&&owner');
    --lv_object_name varchar2(39) := upper('%'||'&&objname'||'%');
    lv_object_name varchar2(39) := upper('&&objname');
    lv_object_type varchar2(39) := upper('&&objtype');

    op1 number;
    op2 number;
    op3 number;
    op4 number;
    op5 number;
    op6 number;
    op7 number;

    sum_total_blks number := 0;
    sum_total_byte number := 0;
    sum_unuse_blks number := 0;
    sum_unuse_byte number := 0;

    cursor c_obj
       (c_owner varchar2,
        c_name  varchar2,
        c_type  varchar2)
    is
    select owner,
	       object_name, 
	       subobject_name, 
           object_type
      from dba_objects
     where  
	       owner like upper(nvl(c_owner,'%'))
	   and object_name like upper(nvl(c_name,'%'))
       and object_type like upper(nvl(c_type,'%'))
       and object_type in ('TABLE', 'TABLE PARTITION', 'INDEX', 'CLUSTER');

begin
    dbms_output.enable(1000000);
    for cloop in c_obj(lv_owner_name, lv_object_name, lv_object_type)
    loop

        begin
	    if upper(lv_object_type)  = 'TABLE PARTITION' then

           dbms_space.unused_space(cloop.owner,  
                                   cloop.object_name, 
                                   cloop.object_type,
                                   op1, op2, op3 ,op4,op5, op6, op7,
								   cloop.subobject_name);

           dbms_output.put_line('==============================================');
           dbms_output.put_line('Object Name                = '||cloop.object_name);
           dbms_output.put_line('SubObject Name             = '||cloop.subobject_name);
           dbms_output.put_line('----------------------------------------------');
        else
		   
           dbms_space.unused_space(cloop.owner,  
                                   cloop.object_name, 
                                   cloop.object_type,
                                   op1, op2, op3 ,op4,op5, op6, op7);

           dbms_output.put_line('==============================================');
           dbms_output.put_line('Object Name                = '||cloop.object_name);
           dbms_output.put_line('----------------------------------------------');
        end if;
        exception
           when others then
                dbms_output.put_line('==============================================');
                dbms_output.put_line('ERROR: Typ ->'||lv_object_type);
                dbms_output.put_line('==============================================');
                dbms_output.put_line('Object Name            = '||cloop.object_name);
                dbms_output.put_line('SubObject Name         = '||cloop.subobject_name);
                dbms_output.put_line('----------------------------------------------');
                dbms_output.put_line(sqlerrm(sqlcode));
        end;

        dbms_output.put_line('Total Blocks               = '||op1);
        dbms_output.put_line('Total Bytes                = '||op2);
        dbms_output.put_line('Unused Blocks              = '||op3);
        dbms_output.put_line('Unused Bytes               = '||op4);
        dbms_output.put_line('Last Used Extent File Id   = '||op5);
        dbms_output.put_line('Last Used Extent Block Id  = '||op6);
        dbms_output.put_line('Last Used Block            = '||op7);
        dbms_output.put_line('==============================================');

        sum_total_blks := sum_total_blks + op1;
        sum_total_byte := sum_total_byte + op2;
        sum_unuse_blks := sum_unuse_blks + op3;
        sum_unuse_byte := sum_unuse_byte + op4;
    end loop;
    dbms_output.put_line('##############################################');
    dbms_output.put_line('Total Summary                                 ');
    dbms_output.put_line('----------------------------------------------');
    dbms_output.put_line('Sum Total Blocks           = '||NVL(sum_total_blks,0));
    dbms_output.put_line('Sum Total Bytes            = '||NVL(sum_total_byte,0));
    dbms_output.put_line('Sum Unused Blocks          = '||NVL(sum_unuse_blks,0));
    dbms_output.put_line('Sum Unused Bytes           = '||NVL(sum_unuse_byte,0));
    dbms_output.put_line('##############################################');
end;
/

spool off;

