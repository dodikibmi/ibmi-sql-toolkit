-- RCAC demo, step 2: the real thing. A row permission and a column mask live on the table itself,
-- so every interface (SQL, RPG native I/O, ODBC, DFU, Query/400) gets the same filtered rows.
-- Authority: the QIBM_DB_SECADM function usage (a security administrator role, separate from the
-- data owner). Without it CREATE PERMISSION fails with SQL0552 - as it does on the shared
-- practice system, so the runnable version of the same idea is 03-secure-view-alternative.sql.
create or replace permission MYLIB.tk_customer_by_region
  on MYLIB.tk_customer
  for rows where exists (select 1 from MYLIB.tk_user_region r
                          where r.user_name = session_user
                            and r.region    = MYLIB.tk_customer.region)
  enforced for all access
  enable;

create or replace mask MYLIB.tk_customer_phone
  on MYLIB.tk_customer
  for column phone return
    case when verify_group_for_user(session_user, 'SALESMGR') = 1   -- members of group SALESMGR
         then phone
         else 'XXX-XXX-' concat right(trim(phone), 4)
    end
  enable;

alter table MYLIB.tk_customer
  activate row access control
  activate column access control;

-- Without the authority the SELECT below still shows every row: nothing is active yet.
-- After this, a plain "select * from MYLIB.tk_customer" returns only region EAST, phones masked.
select * from MYLIB.tk_customer;
