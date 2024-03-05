create or replace view sert_core.exceptions_pub_v
as
select
   e.exception_id
  ,e.exception
  ,e.rule_set_id
  ,e.rule_id
  ,e.workspace_id
  ,e.application_id
  ,e.page_id
  ,e.component_id
  ,e.column_name
  ,e.shared_comp_name
  ,e.item_name
  ,e.current_value
  ,e.rule_set_id || ':'
    || e.rule_id || ':'
    || e.workspace_id || ':'
    || e.application_id || ':'
    || e.page_id || ':'
    || e.component_id || ':'
    || e.item_name || ':'
    || e.column_name || ':'
    || e.shared_comp_name
    as exception_key
  ,e.result
  ,e.reason
  ,e.created_on
  ,e.created_by
  ,e.updated_on
  ,e.updated_by
  ,e.actioned_by
  ,e.actioned_on
from
  exceptions_v e
where
  e.workspace_id = (select nv('WORKSPACE_ID') from dual)
/