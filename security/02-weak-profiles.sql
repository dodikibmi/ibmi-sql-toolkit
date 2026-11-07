-- Profiles that break basic password rules:
--   default password (password = user name, checked by the system),
--   enabled but not used for 90 days, password that never expires.
-- Authority: *SECADM to see all profiles (*ALLOBJ + *SECADM for USER_DEFAULT_PASSWORD);
-- without it you only see your own profile.
select user_name,
       status,
       user_default_password,
       date(previous_signon)        as last_signon,
       date(password_change_date)   as password_changed,
       password_expiration_interval as expiry_days,
       no_password_indicator,
       case when user_default_password = 'YES'                 then 'default password'
            when previous_signon < current timestamp - 90 days then 'not used for 90 days'
            when password_expiration_interval = -1            then 'password never expires'
            else 'ok' end            as finding
  from qsys2.user_info
 where status = '*ENABLED'
 order by finding, user_name;
