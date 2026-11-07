-- Programs that run with their owner's authority (USRPRF(*OWNER)).
-- Adopted authority is the normal way to give controlled access, but a program owned by a
-- powerful profile that *PUBLIC can call is a back door. Check the owner and *PUBLIC access.
-- Authority: any user. Replace MYLIB with the library to check.
select p.program_name,
       p.object_type,
       p.program_owner,
       p.user_profile        as runs_as,
       p.use_adopted_authority,
       u.special_authorities as owner_special_authorities,
       a.object_authority    as public_authority
  from qsys2.program_info p
  left join qsys2.user_info u
         on u.user_name = p.program_owner
  left join qsys2.object_privileges a
         on a.system_object_schema = p.program_library
        and a.system_object_name   = p.program_name
        and a.object_type          = p.object_type
        and a.authorization_name   = '*PUBLIC'
 where p.program_library = 'MYLIB'
   and p.user_profile = '*OWNER'
 order by p.program_name;
