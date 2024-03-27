create or replace force view sert_core.comments_v
as
select
   c.comment_id
  ,c.rule_set_id
  ,c.rule_id
  ,c.workspace_id
  ,c.application_id
  ,c.page_id
  ,c.component_id
  ,c.component_name
  ,c.column_name
  ,c.item_name
  ,c.shared_comp_name
  ,c.comments
  ,c.created_on
  ,c.created_by
  ,c.updated_on
  ,c.updated_by
from
  comments c
/