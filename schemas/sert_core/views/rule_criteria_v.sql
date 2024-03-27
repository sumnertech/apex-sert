create or replace force view sert_core.rule_criteria_v
as
select
   rc.rule_criteria_id
  ,rc.rule_criteria_name
  ,rc.rule_criteria_key
  ,rc.rule_criteria_type_id
  ,rct.rule_criteria_type_name
  ,rct.rule_criteria_type_key
  ,rc.rule_criteria_sql
  ,rc.reason
  ,rc.active_yn
  ,rc.internal_yn
  ,case when rc.active_yn = 'Y' then 'Active' else 'Inactive' end as active_value
  ,case when rc.active_yn = 'Y' then 'success' else 'danger' end as active_color
  ,rc.description
  ,rc.created_by
  ,rc.created_on
  ,rc.updated_by
  ,rc.updated_on
from
  rule_criteria rc
  ,rule_criteria_types rct
where
  rc.rule_criteria_type_id = rct.rule_criteria_type_id
/