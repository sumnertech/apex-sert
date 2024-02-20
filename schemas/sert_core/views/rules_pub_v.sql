create or replace view sert_core.rules_pub_v
as
select
  rule_id
  ,rule_name
  ,category_name
  ,category_key
from
  sert_core.rules_v r
/