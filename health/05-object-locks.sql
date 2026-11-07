-- Who is locking the objects in a library (before a CHGPF, a restore or a nightly job).
-- Authority: *JOBCTL or *ALLOBJ to see locks held by other users' jobs.
-- Replace MYLIB with the library to check.
select system_object_name as object,
       object_type,
       system_table_member as member,
       lock_state,
       lock_status,
       lock_scope,
       job_name
  from qsys2.object_lock_info
 where system_object_schema = 'MYLIB'
 order by object, job_name;
