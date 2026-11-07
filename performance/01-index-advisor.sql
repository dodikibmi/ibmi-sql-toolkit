-- Indexes the SQL optimizer (SQE) asked for while running queries against a library.
-- TIMES_ADVISED and MTI_USED show how often it wanted the index. Create the top ones and
-- check the advice stops; do not create every advised index (each one costs on insert/update).
-- Authority: any user. Replace MYLIB with the library to check.
select table_name,
       key_columns_advised,
       index_type,
       sum(times_advised)           as times_advised,
       max(last_advised)            as last_advised,
       max(estimated_creation_time) as est_create_seconds,
       sum(mti_used)                as mti_used,
       'CREATE INDEX ' concat trim(table_schema) concat '.' concat trim(table_name)
         concat '_IX1 ON ' concat trim(table_schema) concat '.' concat trim(table_name)
         concat ' (' concat trim(key_columns_advised) concat ')' as suggested_ddl
  from qsys2.sysixadv
 where table_schema = 'MYLIB'
 group by table_schema, table_name, key_columns_advised, index_type
 order by times_advised desc;
