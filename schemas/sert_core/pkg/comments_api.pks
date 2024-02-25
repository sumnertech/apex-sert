create or replace package comments_api
as

procedure add_comment
  (
   p_rule_set_id      in number
  ,p_rule_id          in number
  ,p_workspace_id     in number
  ,p_application_id   in number
  ,p_page_id          in number   default null
  ,p_component_id     in varchar2 default null
  ,p_column_name      in varchar2 default null
  ,p_item_name        in varchar2 default null
  ,p_comments         in varchar2
  );

procedure delete_comment
  (
   p_comment_id in number
  ,p_created_by in varchar2 default v('APP_USER')
  );

end comments_api;
/
