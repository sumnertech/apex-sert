create or replace package sert_core.exceptions_api
as

function show_exception
  (
  p_eval_result_id in number
  )
return boolean;

function show_exceptions_form
  (
   p_stale_eval    in varchar2
  ,p_exception_key in varchar2
  )
return boolean;

function show_add_exception_button
  (
  p_exception_key in varchar2
  )
return boolean;

function show_withdraw_exception_button
  (
   p_stale_eval    in varchar2
  ,p_exception_key in varchar2
  ,p_exception_id  in number
  ,p_app_user      in varchar2
  )
return boolean;

procedure withdraw_exception
  (
   p_exception_id in number
  ,p_eval_id     in number
  );

procedure approve_or_reject_exception
  (
   p_exception_id in number
  ,p_result       in varchar2
  ,p_reason       in varchar2
  ,p_app_user     in varchar2
  ,p_eval_id      in number
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
  ,p_eval_id          in number
  );

procedure download_exceptions
  (
   p_application_id in number
  ,p_eval_id        in number
  );

procedure upload_exceptions
  (
   p_name      in varchar2
  ,p_eval_id   in number
  );

end exceptions_api;
/
