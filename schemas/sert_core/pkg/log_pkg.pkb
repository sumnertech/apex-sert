create or replace package body sert_core.log_pkg
as

----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: G E T _ L O G _ K E Y
----------------------------------------------------------------------------------------------------------------------------
-- Returns a random 10-character code that can be used to group similar log entries together for easier troubleshooting
----------------------------------------------------------------------------------------------------------------------------
function get_log_key
return varchar2
is
begin

return dbms_random.string('U', 10);

end get_log_key;


----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: L O G
----------------------------------------------------------------------------------------------------------------------------
-- Writes a row to the log table
----------------------------------------------------------------------------------------------------------------------------
procedure log
  (
   p_log      in varchar2 default null
  ,p_log_type in varchar2 default 'GENERIC'
  ,p_log_key  in varchar2 default null
  ,p_log_clob in varchar2 default null
  )
is
  pragma autonomous_transaction;
begin

insert into logs
  (
   log_key
  ,log_type
  ,log
  ,log_clob
  )
values
  (
   p_log_key
  ,p_log_type
  ,p_log
  ,dbms_utility.format_error_stack || dbms_utility.format_error_backtrace || p_log_clob
  );

commit;

end log;

----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: E R R O R
----------------------------------------------------------------------------------------------------------------------------
-- main error handler
----------------------------------------------------------------------------------------------------------------------------
function error
  (
  p_error in apex_error.t_error
  )
return apex_error.t_error_result
is
  l_result          apex_error.t_error_result;
begin

-- capture the result
l_result := apex_error.init_error_result (p_error => p_error );

-- set the error message

if l_result.message is null then
  l_result.message := 'An unexpected error has occurred. Please review the log for details.';
end if;

-- return the result
return l_result;


end error;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end log_pkg;
/
