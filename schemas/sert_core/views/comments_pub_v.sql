create or replace view sert_core.comments_pub_v
as
select
   c.comment_id
  ,replace(apex_escape.html(c.comments), chr(10), '<br />') ||
    case when c.created_by = (select v('APP_USER') from dual)
      then '<br /><br /><a href="#" class="deleteComment" id="' || c.comment_id || '"">Delete Comment</a>'
      else null end as comments
  ,c.rule_set_id
  ,c.rule_id
  ,c.workspace_id
  ,c.application_id
  ,c.page_id
  ,c.component_id
  ,c.column_name
  ,c.shared_comp_name
  ,c.item_name
  ,c.created_on
  ,c.created_by
  ,c.updated_on
  ,c.updated_by
from
  comments_v c
where
  workspace_id = (select nv('WORKSPACE_ID') from dual)
/