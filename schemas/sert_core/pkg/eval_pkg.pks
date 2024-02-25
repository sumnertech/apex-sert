create or replace package sert_core.eval_pkg
as

function eval_criteria
  (
   p_column_to_evaluate    in varchar2
  ,p_return_details        in varchar2 default 'Y'
  ,p_rule_criteria_type_id in number
  )
return varchar2;

procedure process_rules
  (
   p_application_id in number
  ,p_page_id        in number default null
  ,p_eval_id        in number
  ,p_rule_set_id    in number
  );

procedure eval
  (
   p_application_id    in number
  ,p_page_id           in number   default null
  ,p_eval_id           in number   default null
  ,p_rule_set_key      in varchar2 default 'INTERNAL'
  ,p_eval_by           in varchar2 default coalesce(sys_context('APEX$SESSION','APP_USER'),user)
  ,p_run_in_background in varchar2 default 'Y'
  ,p_eval_id_out       out number
  );

procedure delete_eval
  (
   p_eval_id in number
  ,p_delete_comments in varchar2 default 'Y'
  );

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end eval_pkg;
/