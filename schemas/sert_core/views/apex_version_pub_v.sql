create or replace view sert_core.apex_version_pub_v
as
select
   apex_version
  ,apex_version_item
  ,sert_apex_version
from
  apex_version_v
/
