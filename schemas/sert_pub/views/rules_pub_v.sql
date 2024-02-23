create or replace view sert_pub.rules_pub_v
as
select
   rule_id
  ,rule_name
  ,category_name
  ,category_key
  ,risk
  ,risk_url
  ,info
  ,fix
  ,help_url
  ,builder_url
from
  sert_core.rules_pub_v
/