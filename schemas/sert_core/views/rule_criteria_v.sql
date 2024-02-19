create or replace view sert_core.rule_criteria_v
as
select
   rule_criteria_id
  ,rule_criteria_name
  ,rule_criteria_key
  ,rule_criteria_type
  ,rule_criteria_sql
  ,reason
  ,active_yn
  ,internal_yn
  ,case when active_yn = 'Y' then 'Active' else 'Inactive' end as active_value
  ,case when active_yn = 'Y' then 'success' else 'danger' end as active_color
  ,description
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
  rule_criteria
/