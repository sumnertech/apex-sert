create or replace view sert_core.apex_version_v
as
select
   substr(VERSION_NO, 1, instr(version_no,'.',1)+1) as apex_version
  ,(select v('G_APEX_VERSION') from dual) as apex_version_item
  ,(select pref_value from prefs where pref_key = 'SERT_APEX_VERSION') as sert_apex_version
from
  apex_release
/
