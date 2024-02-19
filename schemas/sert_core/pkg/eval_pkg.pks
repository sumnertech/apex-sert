create or replace package sert_core.eval_pkg
as

function eval_criteria
  (
   p_column_to_evaluate in varchar2
  ,p_return_details     in varchar2 default 'Y'
  ,p_rule_criteria_type in varchar2
  )
return varchar2;

procedure eval
  (
   p_application_id in number
  ,p_rule_set_key   in varchar2 default 'INTERNAL'
  ,p_eval_by        in varchar2 default coalesce(sys_context('APEX$SESSION','APP_USER'),user)
  ,p_debug          in boolean  default false
  );


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end eval_pkg;
/