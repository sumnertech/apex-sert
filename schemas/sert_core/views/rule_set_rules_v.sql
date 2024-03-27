create or replace view sert_core.rule_set_rules_v
as
select
   rs.rule_set_id
  ,rs.rule_set_type_id
  ,rst.rule_set_type_name
  ,rst.rule_set_type_key
  ,rs.rule_set_name
  ,rs.rule_set_key
  ,rs.apex_version
  ,rs.active_yn as rule_set_active_yn
  ,case
    when rs.active_yn = 'Y' then 'success'
    else 'danger'
   end rule_set_active_color
  ,case
    when rs.active_yn = 'Y' then 'Active'
    else 'Inactive'
   end rule_set_active_value
  ,rs.internal_yn
  ,rs.description
  ,r.rule_name
  ,r.rule_key
  ,r.rule_id
  ,r.active_yn as rule_active_yn
  ,case
    when r.active_yn = 'Y' then 'success'
    else 'danger'
   end rule_active_color
  ,case
    when r.active_yn = 'Y' then 'Active'
    else 'Inactive'
   end rule_active_value
  ,rs.created_by
  ,rs.created_on
  ,rs.updated_by
  ,rs.updated_on
  ,r.rule_hash
from
   rule_sets rs
  ,rule_set_types rst
  ,rule_set_rules rsr
  ,rules_v r
where
  rs.rule_set_type_id = rst.rule_set_type_id
  and rs.rule_set_id = rsr.rule_set_id
  and rsr.rule_id = r.rule_id
/