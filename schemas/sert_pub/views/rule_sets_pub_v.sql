create or replace view sert_pub.rule_sets_pub_v
as
select
   rule_set_id
  ,rule_set_type_id
  ,rule_set_type_name
  ,rule_set_type_key
  ,rule_set_name
  ,rule_set_key
  ,apex_version
  ,description
  ,cnt
from
  sert_core.rule_sets_pub_v
/