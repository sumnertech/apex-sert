create or replace view sert_core.rules_pub_v
as
select
  rule_id
  ,rule_name
  ,risk_name
  ,category_name
  ,category_key
  ,risk
  ,risk_url
  ,rule_criteria_type_name
  ,info
  ,fix
  ,help_url
  ,builder_url
from
  sert_core.rules_v r
/