create or replace force view sert_core.rule_sets_pub_v
as
with c as (select apex_version from apex_version_v)
select
   r.rule_set_id
  ,r.rule_set_type_id
  ,r.rule_set_type_name
  ,r.rule_set_type_key
  ,r.rule_set_name
  ,r.rule_set_key
  ,r.apex_version
  ,r.description
  ,r.cnt
from
   rule_sets_v r
  ,c
where
  r.active_yn = 'Y'
  and r.apex_version = c.apex_version
/