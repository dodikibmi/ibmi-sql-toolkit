-- Jobs stuck in message wait (MSGW): a batch job is waiting for an operator reply.
-- Authority: any user sees their own jobs; *JOBCTL or *ALLOBJ to see every job.
-- AUTHORIZATION_NAME is the user the job runs for (server jobs such as QZDASOINIT have
-- JOB_USER = QUSER). Scope: remove the AUTHORIZATION_NAME filter to check the whole system.
select job_name,
       job_type,
       subsystem,
       trim(coalesce(function_type, '')) concat ' ' concat trim(coalesce(function, '')) as doing,
       job_active_time
  from table(qsys2.active_job_info(detailed_info => 'NONE')) j
 where job_status = 'MSGW'
   and authorization_name = current user
 order by job_active_time;
