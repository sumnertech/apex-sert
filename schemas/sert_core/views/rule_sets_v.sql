create or replace force view sert_core.rule_sets_v
as
with cnt as (select rule_set_id, sum(rule_hash) as rule_set_hash, count(*) cnt from rule_set_rules_v group by rule_set_id)
select
   rs.rule_set_id
  ,rs.rule_set_type_id
  ,rst.rule_set_type_name
  ,rst.rule_set_type_key
  ,rs.rule_set_name
  ,rs.rule_set_key
  ,rs.apex_version
  ,rs.active_yn
  ,case
    when rs.active_yn = 'Y' then 'success'
    else 'danger'
   end active_color
  ,case
    when rs.active_yn = 'Y' then 'Active'
    else 'Inactive'
   end active_value
  ,rs.internal_yn
  ,rs.description
  ,rs.created_by
  ,rs.created_on
  ,rs.updated_by
  ,rs.updated_on
  ,nvl(cnt.cnt,0) as cnt
  ,rule_set_hash
from
   rule_sets rs
  ,rule_set_types rst
  ,cnt
where
  rs.rule_set_type_id = rst.rule_set_type_id
  and rs.rule_set_id = cnt.rule_set_id(+)
/