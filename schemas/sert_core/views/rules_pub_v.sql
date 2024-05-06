create or replace force view sert_core.rules_pub_v
as
select
   rule_id
  ,rule_name
  ,risk_name
  ,category_name
  ,category_key
  ,risk
  ,risk_url
  ,impact
  ,shared_comp_type
  ,rule_criteria_type_name
  ,nvl(to_char(info), 'No data found') as info
  ,nvl(to_char(fix), 'No data found')  as fix
  ,help_url
  ,builder_url_key
  ,builder_url_id
  ,rule_hash
  ,view_name
from
  sert_core.rules_v r
/