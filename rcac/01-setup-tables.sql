-- RCAC demo, step 1: a fictitious customer table and a table that says which sales region
-- each user may see. Runs with normal authority. Replace MYLIB with your library.
create or replace table MYLIB.tk_customer (
  customer_id   integer       not null primary key,
  customer_name varchar(40)   not null,
  region        char(4)       not null,
  phone         varchar(20),
  credit_limit  decimal(11,2) not null default 0
);

create or replace table MYLIB.tk_user_region (
  user_name   varchar(10) not null,
  region      char(4)     not null,
  can_see_pii char(1)     not null default 'N',
  primary key (user_name, region)
);

delete from MYLIB.tk_customer;
insert into MYLIB.tk_customer values
  (1, 'Northwind Retail', 'EAST', '+1 555 0101', 25000),
  (2, 'Blue Harbor Foods', 'EAST', '+1 555 0102', 12000),
  (3, 'Summit Hardware',  'WEST', '+1 555 0201', 40000),
  (4, 'Cedar Lane Books', 'WEST', '+1 555 0202',  8000),
  (5, 'Pioneer Tools',    'NORT', '+1 555 0301', 15000);

-- The user running the demo may see region EAST, but not the phone numbers.
delete from MYLIB.tk_user_region;
insert into MYLIB.tk_user_region values (session_user, 'EAST', 'N');
