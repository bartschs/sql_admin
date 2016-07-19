select SID, TYPE, ID1, ID2, LMODE,
       (select object_name from user_objects where object_id=id1) oname,
        block
  from v$lock
 where sid = (select sid from v$mystat where rownum=1 )
    or block = 1
/

