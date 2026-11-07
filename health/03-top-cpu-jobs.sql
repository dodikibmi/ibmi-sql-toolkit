-- The 10 active jobs that used the most CPU since they started.
-- Authority: any user sees their own jobs; *JOBCTL or *ALLOBJ to see every job.
-- AUTHORIZATION_NAME is the user the job runs for (server jobs such as QZDASOINIT have
-- JOB_USER = QUSER). Scope: remove the AUTHORIZATION_NAME filter to rank the whole system.
select job_name,
       job_type,
       job_status,
       subsystem,
       cpu_time,
       total_disk_io_count,
       temporary_storage as temp_mb
  from table(qsys2.active_job_info(detailed_info => 'NONE')) j
 where authorization_name = current user
 order by cpu_time desc
 fetch first 10 rows only;
