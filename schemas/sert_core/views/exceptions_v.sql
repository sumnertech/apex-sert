create or replace view sert_core.exceptions_v
as
select
   e.exception_id
  ,e.rule_set_id
  ,e.rule_id
  ,e.workspace_id
  ,e.application_id
  ,e.page_id
  ,e.component_id
  ,e.component_name
  ,e.column_name
  ,e.item_name
  ,e.shared_comp_name
  ,e.current_value
  ,e.exception
  ,e.result
  ,e.reason
  ,e.created_on
  ,e.created_by
  ,e.updated_on
  ,e.updated_by
  ,e.actioned_by
  ,e.actioned_on
from
  exceptions e
/