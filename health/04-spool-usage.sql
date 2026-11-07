-- Spooled files per user: how many, how big, how old.
-- Old spooled files fill the disk and slow down WRKSPLF; clean up what is past the retention rule.
-- Authority: any user sees their own spooled files; *SPLCTL to see all.
-- Scope: remove the USER_NAME filter to see every user.
select user_name,
       count(*)                                   as spooled_files,
       sum(total_pages)                           as pages,
       decimal(sum(size) / 1024.0, 11, 1)         as size_mb,
       date(min(create_timestamp))                as oldest,
       sum(case when create_timestamp < current timestamp - 30 days
                then 1 else 0 end)                as older_than_30_days
  from qsys2.output_queue_entries_basic
 where user_name = current user
 group by user_name
 order by size_mb desc;
