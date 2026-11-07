-- The 15 largest objects in a library, with when they were last used.
-- Large and unused for a long time = candidate to archive or delete (after asking the owner).
-- Authority: *USE on the objects. Replace MYLIB with the library to check.
select objname,
       objtype,
       objattribute,
       decimal(objsize / 1024.0 / 1024, 11, 2) as size_mb,
       objowner,
       date(last_used_timestamp)               as last_used,
       days_used_count,
       objtext
  from table(qsys2.object_statistics('MYLIB', '*ALL')) o
 order by objsize desc
 fetch first 15 rows only;
