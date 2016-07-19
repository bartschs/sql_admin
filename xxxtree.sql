
  select object_id from all_objects
    where owner        = upper(xxx_deptree_fill.schema)
    and   object_name  = upper(xxx_deptree_fill.name)
    and   object_type  = upper(xxx_deptree_fill.type);
	


select d.nest_level, o.object_type, o.owner, o.object_name /*,d.seq# */
  from 
(
    select object_id, referenced_object_id, level nest_level 
      from public_dependency
      connect by prior object_id = referenced_object_id
      start with referenced_object_id = (select object_id
	                                       from all_objects
                                          where owner = 'USM_SCHEMA'
                                            and object_name  = 'USM$VI_OBJ_CNTRCT'
                                            and object_type  = 'VIEW')	
) d  
, all_objects o
where d.object_id = o.object_id (+)
order by 1

	
    select object_id, referenced_object_id, level 
      from public_dependency
      connect by prior object_id = referenced_object_id
      start with referenced_object_id = (select object_id
	                                       from all_objects
                                          where owner = 'USM_SCHEMA'
                                            and object_name  = 'USM$VI_LOG_CNTRCT'
                                            and object_type  = 'VIEW')	

