-- Tables (physical files) with rows but no index, keyed logical file, primary or unique key.
-- Every query that filters them reads the whole table. Small code tables are fine; big ones are not.
-- Authority: any user. Replace MYLIB with the library to check.
select t.table_name,
       t.table_type,
       s.number_rows,
       decimal(s.data_size / 1024.0 / 1024, 11, 2) as data_mb
  from qsys2.systables t
  join qsys2.systablestat s
    on s.table_schema = t.table_schema
   and s.table_name   = t.table_name
 where t.table_schema = 'MYLIB'
   and t.table_type in ('T', 'P')
   and t.file_type  = 'D'                                    -- data, not source files
   and s.number_rows > 0
   and not exists (select 1 from qsys2.systableindexstat i   -- SQL indexes, keyed LFs, key constraints
                    where i.table_schema = t.table_schema
                      and i.table_name   = t.table_name)
   and not exists (select 1 from qsys2.sysfiles f            -- DDS physical file with a key
                    where f.table_schema = t.table_schema
                      and f.table_name   = t.table_name
                      and f.number_key_fields > 0)
 order by s.number_rows desc;
