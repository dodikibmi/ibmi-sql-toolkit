-- System overview: CPU, storage and job counts in one row.
-- Authority: any user. Run it first thing in the morning or when "the system is slow".
-- Watch: ASP_USED_PCT above 80, a sudden jump in jobs, CPU near 100.
select host_name,
       total_jobs_in_system,
       active_jobs_in_system,
       elapsed_cpu_used                              as cpu_pct,
       configured_cpus,
       main_storage_size / 1024 / 1024               as memory_gb,
       system_asp_used                               as asp_used_pct,
       decimal(system_asp_storage / 1024.0 / 1024, 9, 1) as asp_size_tb,
       current_temporary_storage                     as temp_storage_mb
  from table(qsys2.system_status(reset_statistics => 'NO')) s;
