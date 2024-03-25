create or replace package body comments_api
as

procedure add_comment
  (
   p_rule_set_id      in number
  ,p_rule_id          in number
  ,p_workspace_id     in number
  ,p_application_id   in number
  ,p_page_id          in number   default null
  ,p_component_id     in varchar2 default null
  ,p_component_name   in varchar2 default null
  ,p_column_name      in varchar2 default null
  ,p_item_name        in varchar2 default null
  ,p_shared_comp_name in varchar2 default null
  ,p_comments         in varchar2
  )
is
begin

insert into comments
  (
   rule_set_id
  ,rule_id
  ,workspace_id
  ,application_id
  ,page_id
  ,component_id
  ,component_name
  ,column_name
  ,item_name
  ,shared_comp_name
  ,comments
  )
values
  (
   p_rule_set_id
  ,p_rule_id
  ,p_workspace_id
  ,p_application_id
  ,p_page_id
  ,p_component_id
  ,p_component_name
  ,p_column_name
  ,p_item_name
  ,p_shared_comp_name
  ,p_comments
  );

end add_comment;

procedure delete_comment
  (
   p_comment_id in number
  ,p_created_by in varchar2 default v('APP_USER')
  )
is
begin

delete from comments where comment_id = p_comment_id and created_by = p_created_by;

end delete_comment;

end comments_api;
/
