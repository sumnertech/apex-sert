create or replace view sert_pub.apex_version_pub_v
as
select
   apex_version
  ,sert_apex_version
from
  sert_core.apex_version_pub_v
/