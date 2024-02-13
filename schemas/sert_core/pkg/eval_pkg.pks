create or replace package sert_core.eval_pkg
as

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
