-- Objects in a library that *PUBLIC can change or delete.
-- Rule of thumb: *PUBLIC should be *EXCLUDE (or *USE for read-only reference data);
-- applications get access through a group profile, an authorization list or adopted authority.
-- Authority: ownership or *OBJMGT to see the private authorities of an object.
-- Replace MYLIB with the library to check.
select system_object_name as object,
       object_type,
       object_authority   as public_authority,
       owner,
       authorization_list,
       data_update,
       data_delete,
       object_existence
  from qsys2.object_privileges
 where system_object_schema = 'MYLIB'
   and authorization_name = '*PUBLIC'
   and object_authority not in ('*EXCLUDE', '*USE')
 order by object_type, system_object_name;

-- Summary: how *PUBLIC is set across the library.
select object_authority as public_authority,
       count(*)         as objects
  from qsys2.object_privileges
 where system_object_schema = 'MYLIB'
   and authorization_name = '*PUBLIC'
 group by object_authority
 order by objects desc;
