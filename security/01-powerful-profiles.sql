-- Enabled profiles with *ALLOBJ, *SECADM, *AUDIT or *SERVICE special authority.
-- Auditors ask for this list first: every powerful profile needs an owner and a reason.
-- Authority: anyone can run it, but without *SECADM you only see your own profile
-- (and profiles you have authority to), so an empty result may only mean "not allowed to see".
select user_name,
       status,
       user_class_name,
       special_authorities,
       group_profile_name,
       date(previous_signon) as last_signon,
       text_description
  from qsys2.user_info
 where status = '*ENABLED'
   and (special_authorities like '%*ALLOBJ%'
     or special_authorities like '%*SECADM%'
     or special_authorities like '%*AUDIT%'
     or special_authorities like '%*SERVICE%')
 order by user_name;
