-- Members with many deleted rows: the space is still allocated and full scans still read it.
-- Fix: RGZPFM, or ALTER TABLE ... / CHGPF REUSEDLT(*YES) so new rows reuse the holes.
-- Authority: any user. Replace MYLIB with the library to check.
select table_name,
       table_partition                as member,
       number_rows,
       number_deleted_rows,
       decimal(100.0 * number_deleted_rows
               / nullif(number_rows + number_deleted_rows, 0), 5, 1) as deleted_pct,
       decimal(data_size / 1024.0 / 1024, 11, 2)                     as data_mb,
       date(last_change_timestamp)    as last_changed
  from qsys2.syspartitionstat
 where table_schema = 'MYLIB'
   and number_deleted_rows > 0
 order by deleted_pct desc, number_deleted_rows desc;
