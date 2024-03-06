create or replace package sert_core.exceptions_api
as

function show_exception
  (
  p_eval_result_id in number    
  )
return boolean;

procedure withdraw_exception
  (
  p_exception_id in number    
  );

procedure approve_or_reject_exception
  (
   p_exception_id in number  
  ,p_result       in varchar2
  ,p_reason       in varchar2
  ,p_app_user     in varchar2
  );

procedure add_exception
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
  ,p_exception        in varchar2
  ,p_curernt_value    in varchar2
  );

end exceptions_api;
/
