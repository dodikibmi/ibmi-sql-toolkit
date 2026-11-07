-- RCAC demo, step 3: the runnable alternative with normal authority - a "secure view".
-- Same filter and mask, but in a view. Users get GRANT SELECT on the view and no authority on the
-- table (*PUBLIC *EXCLUDE). Weakness compared with RCAC: anyone who can still reach the table
-- (native I/O, another view, a powerful profile) bypasses it. RCAC closes that gap.
create or replace view MYLIB.tk_customer_v as
  select c.customer_id,
         c.customer_name,
         c.region,
         case when r.can_see_pii = 'Y' then c.phone
              else 'XXX-XXX-' concat right(trim(c.phone), 4) end as phone,
         c.credit_limit
    from MYLIB.tk_customer c
    join MYLIB.tk_user_region r
      on r.user_name = session_user
     and r.region    = c.region;

-- In a real system:
--   revoke all on MYLIB.tk_customer from public;
--   grant select on MYLIB.tk_customer_v to sales_group;

select * from MYLIB.tk_customer_v order by customer_id;
