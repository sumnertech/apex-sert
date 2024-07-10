create or replace package body sert_core.schedule_api
as

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: A D D _ S C H E D U L E _ J O B
----------------------------------------------------------------------------------------------------------------------------
-- Adds a new scheduled job for a specific app / rule set combination
----------------------------------------------------------------------------------------------------------------------------
procedure add_schedule_job
  (
   p_frequency    in varchar2
  ,p_hour         in varchar2
  ,p_min          in number
  ,p_ampm         in varchar2
  ,p_eval_id      in number
  ,p_app_id       in number
  ,p_rule_set_key in varchar2
  )
is
  l_hour number;
begin

-- first, get the users timezone and convert the time
select to_char(cast(to_timestamp(p_hour || '.' || p_min || ' ' || p_ampm,'HH:MI PM') at time zone 'gmt' as date),'HH24') into l_hour from dual;

-- then schedule the job
dbms_scheduler.create_job(
   job_name        => 'SERT_EVAL_' || p_app_id || '_' || p_rule_set_key
  ,job_type        => 'PLSQL_BLOCK'
  ,job_action      => 'declare l_eval_id number; begin eval_pkg.eval(p_application_id => ' || p_app_id || ', p_rule_set_key => ''' || p_rule_set_key || ''', p_eval_id_out => l_eval_id); end;'
  ,repeat_interval => 'FREQ=daily;BYDAY=' || p_frequency || ';BYHOUR=' || l_hour || ';BYMINUTE=' || p_min || '; bysecond=0;'
  ,enabled         => true
  ,auto_drop       => false
  );

end add_schedule_job;

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: R E M O V E _ S C H E D U L E _ J O B
----------------------------------------------------------------------------------------------------------------------------
-- Removes an existing scheduled evaluation
----------------------------------------------------------------------------------------------------------------------------
procedure remove_schedule_job
  (
   p_app_id       in number
  ,p_rule_set_key in varchar2
  )
is
begin

dbms_scheduler.drop_job(job_name => 'SERT_EVAL_' || p_app_id || '_' || p_rule_set_key);

end remove_schedule_job;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end schedule_api;
/
