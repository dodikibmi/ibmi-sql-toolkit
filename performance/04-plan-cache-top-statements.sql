-- The 10 most expensive SQL statements in the plan cache (the optimizer's memory of recent plans).
-- Use it when "the system is slow" and you need to know which query costs the most.
-- Authority: *JOBCTL special authority or the QIBM_DB_SQLADM function usage. Without it the CALL
-- fails with CPF43A3 (as it does on the shared practice system) - a DBA runs it, or uses
-- Visual Explain / the Plan Cache view in IBM i Access Client Solutions.
call qsys2.dump_plan_cache_topn('MYLIB', 'PCTOP10', 10);

select qqjob    as job,
       qqucnt   as statement_number,
       qq1000   as statement_text
  from MYLIB.pctop10
 where qqrid = 1000
 order by qqi6 desc;
