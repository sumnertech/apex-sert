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


----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: D O W N L O A D  _ E X C E P T I O N S
----------------------------------------------------------------------------------------------------------------------------
-- Downloads an applications exceptions as a JSON file
----------------------------------------------------------------------------------------------------------------------------
procedure download_exceptions
  (
   p_application_id in number
  ,p_eval_id        in number
  )
is
  l_log_key varchar2(10) := log_pkg.get_log_key;
begin

log_pkg.log(p_log => 'Downloading Exceptions for Application ' || p_application_id, p_log_key => l_log_key, p_log_type => 'EXCEPTION_EXPORT', p_application_id => p_application_id);

-- loop through the current evaluation to get the rule_set_id
for x in (select * from evals_pub_v where eval_id = p_eval_id)
loop
  -- loop through all exceptions that match on application_id and rule_set_id
  for y in (select * from exceptions_json_to_rel_v where application_id = p_application_id and rule_set_id = x.rule_set_id)
  loop

    -- download the JSON file
    apex_http.download
      (
       p_clob => y.json_doc
      ,p_content_type => 'application/json'
      ,p_filename => 'Exceptions for App ' || p_application_id || ' - ' || to_char(localtimestamp, 'DD-MON-YYYY HH.MI.SS PM') || '.json'
      );

  end loop;
end loop;

log_pkg.log(p_log => 'Downloading Exceptions Completed for Application ' || p_application_id, p_log_key => l_log_key, p_log_type => 'EXCEPTION_EXPORT', p_application_id => p_application_id);

end download_exceptions;


----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: U P L O A D  _ E X C E P T I O N S
----------------------------------------------------------------------------------------------------------------------------
-- Uploads and applies an Exceptions JSON file
----------------------------------------------------------------------------------------------------------------------------
procedure upload_exceptions
  (
   p_name      in varchar2
  ,p_eval_id   in number
  )
is
  l_fail           number := 0;
  l_pass           number := 0;
  l_application_id number;
  l_rule_set_key   varchar2(250);
  l_apex_version   number;
  l_log_key        varchar2(10) := log_pkg.get_log_key;
  l_checksum       number;
begin

-- get the application_id for the specific evaluation
select application_id, rule_set_key, apex_version into l_application_id, l_rule_set_key, l_apex_version from evals_v where eval_id = p_eval_id;

log_pkg.log(p_log => 'Uploading Exceptions for Application ' || l_application_id || ' - Rule Set ' || l_rule_set_key, p_log_key => l_log_key, p_log_type => 'EXCEPTION_IMPORT', p_application_id => l_application_id);

-- find the file that was just uploaded
for x in
  (
  select
    *
  from
    exceptions_rel_to_json_v
  where
    name = p_name
  )
loop
  -- check to make sure that the user can see the application and if so, try to insert the row
  if l_application_id = x.application_id and l_rule_set_key = x.rule_set_key and l_apex_version = x.apex_version then

    -- generate a checksum based on the data uploaded
    select ora_hash
      (
           x.rule_set_key
        || x.rule_key
        || x.apex_version
        || x.workspace_id
        || x.application_id
        || x.page_id
        || x.component_id
        || x.component_name
        || x.column_name
        || x.item_name
        || x.shared_comp_name
        || x.current_value
        || x.exception
        || x.result
        || x.reason
        || x.created_by
        || x.updated_by
        || x.actioned_by
      )
    into
      l_checksum
    from
      dual;

    -- verify that the checksums match
    if x.checksum = l_checksum then

      -- checksums match; insert the exception
      begin
      insert into exceptions
        (
         rule_set_id
        ,rule_id
        ,exception
        ,workspace_id
        ,application_id
        ,page_id
        ,component_id
        ,column_name
        ,item_name
        ,shared_comp_name
        ,result
        ,reason
        ,current_value
        ,created_by
        ,created_on
        ,updated_by
        ,updated_on
        ,actioned_by
        ,actioned_on
        ,component_name
        )
      values
        (
         (select rule_set_id from rule_sets where rule_set_key = x.rule_set_key and apex_version = x.apex_version)
        ,(select rule_id from rules where rule_key = x.rule_key and apex_version = x.apex_version)
        ,x.exception
        ,x.workspace_id
        ,x.application_id
        ,x.page_id
        ,x.component_id
        ,x.column_name
        ,x.item_name
        ,x.shared_comp_name
        ,x.result
        ,x.reason
        ,x.current_value
        ,x.created_by
        ,to_timestamp_tz(x.created_on, 'YYYY-MM-DD"T"HH24:MI:SS.FF6TZH:TZM')
        ,x.updated_by
        ,x.updated_on
        ,x.actioned_by
        ,x.actioned_on
        ,x.component_name
        );

      -- increment the pass counter
      l_pass := l_pass + 1;

      log_pkg.log(p_log => 'Exception Uploaded - Application: ' || x.application_id || ' - Rule Set: ' || l_rule_set_key || ' - Rule Key: ' || x.rule_key,
        p_log_key => l_log_key, p_log_type => 'EXCEPTION_IMPORT', p_application_id => l_application_id);

      exception
        when others then
        -- exception already exists, do not insert another one; increment the fail counter
        l_fail := l_fail + 1;
        log_pkg.log(p_log => 'Exception Failed (already exists) - Application: ' || x.application_id || ' - Rule Set: ' || l_rule_set_key || ' - Rule Key: ' || x.rule_key,
          p_log_key => l_log_key, p_log_type => 'EXCEPTION_IMPORT', p_application_id => l_application_id);
      end;

    else
      -- checksum does not match; increment the fail counter
      l_fail := l_fail + 1;
      log_pkg.log(p_log => 'Exception Failed (checksum mismatch) - Application: ' || x.application_id || ' - Rule Set: ' || l_rule_set_key || ' - Rule Key: ' || x.rule_key,
        p_log_key => l_log_key, p_log_type => 'EXCEPTION_IMPORT', p_application_id => l_application_id);
    end if;

  else
    -- exception is for another app/rule set combination; increment the fail counter
    l_fail := l_fail + 1;
    log_pkg.log(p_log => 'Exception Failed (other) - Application: ' || x.application_id || ' - Rule Set: ' || l_rule_set_key || ' - Rule Key: ' || x.rule_key,
      p_log_key => l_log_key, p_log_type => 'EXCEPTION_IMPORT', p_application_id => l_application_id);
  end if;

end loop;

-- set the message to be displayed
apex_util.set_session_state('P40_MSG', l_pass || ' exceptions imported' || case when l_fail > 0 then ', ' || l_fail || ' ignored' else null end);

log_pkg.log(p_log => 'Uploading Exceptions for Application ' || l_application_id || ' - Rule Set ' || l_rule_set_key || ' Completed',
  p_log_key => l_log_key, p_log_type => 'EXCEPTION_EXPORT', p_application_id => l_application_id);

end upload_exceptions;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end exceptions_api;
/
