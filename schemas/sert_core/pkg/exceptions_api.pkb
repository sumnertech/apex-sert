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
begin

-- inspect the specific evaluation result and determine whether or not to render it
for x in (select * from eval_results_pub_v where eval_result_id = p_eval_result_id)
loop
  if x.result = 'PASS' then
    return false;
  else
    return true;
  end if;
end loop;

end show_exception;

----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: W I T H D R A W _ E X C E P T I O N
----------------------------------------------------------------------------------------------------------------------------
-- Withdraws an exception, stopping any workflows
----------------------------------------------------------------------------------------------------------------------------
procedure withdraw_exception
  (
  p_exception_id in number    
  )
is
begin

delete from exceptions where exception_id = p_exception_id;

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

null;

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
  ,p_column_name      in varchar2 default null
  ,p_item_name        in varchar2 default null
  ,p_shared_comp_name in varchar2 default null
  ,p_exception        in varchar2
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
  ,column_name
  ,item_name
  ,shared_comp_name
  ,exception
  ,result
  )
values
  (
   p_rule_set_id
  ,p_rule_id
  ,p_workspace_id
  ,p_application_id
  ,p_page_id
  ,p_component_id
  ,p_column_name
  ,p_item_name
  ,p_shared_comp_name
  ,p_exception
  ,'PENDING'
  );



end add_exception;

end exceptions_api;
/
