create or replace package sert_core.schedule_api
AUTHID CURRENT_USER
as

procedure add_schedule_job
  (
   p_frequency    in varchar2
  ,p_hour         in varchar2
  ,p_min          in number
  ,p_ampm         in varchar2
  ,p_eval_id      in number
  ,p_app_id       in number
  ,p_rule_set_key in varchar2
  );

procedure remove_schedule_job
  (
   p_app_id       in number
  ,p_rule_set_key in varchar2
  );

end schedule_api;
/
