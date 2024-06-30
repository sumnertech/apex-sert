create or replace package body sert_core.exceptions_api
as
----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: S H O W _ E X C E P T I O N
----------------------------------------------------------------------------------------------------------------------------
-- Determines whether or not to show items/regions/buttons for an evaluation result based on the status
----------------------------------------------------------------------------------------------------------------------------
function show_exception
  (
  p_eval_result_id in number
  )
return boolean
is
  l_result varchar2(100);
begin

select result into l_result from eval_results_pub_v where eval_result_id = p_eval_result_id;
if l_result = 'PASS' then return false;
  else return true;
end if;

-- inspect the specific evaluation result and determine whether or not to render it
--for x in (select * from eval_results_pub_v where eval_result_id = p_eval_result_id)
--loop
---  if x.result = 'PASS' then
 --   return false;
 -- else
 --   return true;
 -- end if;
--end loop;

end show_exception;


----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: S H O W _ E X C E P T I O N S _ F O R M
----------------------------------------------------------------------------------------------------------------------------
-- Determines whether or not to show the Exceptions form
----------------------------------------------------------------------------------------------------------------------------
function show_exceptions_form
  (
   p_stale_eval    in varchar2
  ,p_exception_key in varchar2
  )
return boolean
is
begin

if p_stale_eval = 'Y' then
  -- evaluation is on an older version of APEX; do not display the form
  return false;
else
  -- check to see if an exception exists
  for y in (select 1 from exceptions_pub_v where exception_key = p_exception_key)
  loop
    -- there is an exception; do not display the form
    return false;
  end loop;
end if;
-- no exception found; display the form
return true;

end show_exceptions_form;


----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: S H O W _ A D D _ E X C E P T I O N _ B U T T O N
----------------------------------------------------------------------------------------------------------------------------
-- Determines whether or not to show the Add Exception button
----------------------------------------------------------------------------------------------------------------------------
function show_add_exception_button
  (
  p_exception_key in varchar2
  )
return boolean
is
begin

-- check to see if an exception exists
for y in (select 1 from exceptions_pub_v where exception_key = p_exception_key)
loop
  -- there is an exception; do not display the button
  return false;
end loop;

-- no exception found; display the button
return true;

end show_add_exception_button;


----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: S H O W _ W I T H D R A W _ E X C E P T I O N _ B U T T O N
----------------------------------------------------------------------------------------------------------------------------
-- Determines whether or not to show the Withdraw Exception button
----------------------------------------------------------------------------------------------------------------------------
function show_withdraw_exception_button
  (
   p_stale_eval    in varchar2
  ,p_exception_key in varchar2
  ,p_exception_id  in number
  ,p_app_user      in varchar2
  )
return boolean
is
begin

if p_stale_eval = 'Y' then
  -- evaluation is on an older version of APEX; do not display the button
  return false;
else
  -- check to see if an exception exists
  for y in
    (
    select
      1
    from
      exceptions_pub_v
    where
      exception_key = p_exception_key
      and 1 = (select 1 from exceptions_pub_v where exception_id = p_exception_id and created_by = p_app_user)
    )
  loop
    -- there is an exception by the current user; display the button
    return true;
  end loop;
end if;
-- no exception found from the current user or exception is from another user; do not display the button
return false;

end show_withdraw_exception_button;


----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: W I T H D R A W _ E X C E P T I O N
----------------------------------------------------------------------------------------------------------------------------
-- Withdraws an exception, stopping any workflows
----------------------------------------------------------------------------------------------------------------------------
procedure withdraw_exception
  (
   p_exception_id in number
  ,p_eval_id      in number
  )
is
begin

delete from exceptions where exception_id = p_exception_id;

-- calculate the scores
eval_pkg.calc_score(p_eval_id => p_eval_id);

end withdraw_exception;

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: A P P R O V E _ O R _ R E J E C T _ E X C E P T I O N
----------------------------------------------------------------------------------------------------------------------------
-- Either approve or reject an exception
----------------------------------------------------------------------------------------------------------------------------
procedure approve_or_reject_exception
  (
   p_exception_id in number
  ,p_result       in varchar2
  ,p_reason       in varchar2
  ,p_app_user     in varchar2
  ,p_eval_id      in number
  )
is
begin

update exceptions set
   result = p_result
  ,reason = p_reason
  ,actioned_by = coalesce(sys_context('APEX$SESSION','APP_USER'),p_app_user)
  ,actioned_on = systimestamp
where
  exception_id = p_exception_id;

-- calculate the scores
eval_pkg.calc_score(p_eval_id => p_eval_id);

end approve_or_reject_exception;


----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: A D D _ E X C E P T I O N
----------------------------------------------------------------------------------------------------------------------------
-- Adds a new exception
----------------------------------------------------------------------------------------------------------------------------
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
  )
is
begin

insert into exceptions
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
  ,exception
  ,result
  ,current_value
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
  ,p_exception
  ,'PENDING'
  ,p_curernt_value
  );

-- calculate the scores
eval_pkg.calc_score(p_eval_id => p_eval_id);

end add_exception;

end exceptions_api;
/
