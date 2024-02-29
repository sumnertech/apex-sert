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

end exceptions_api;
/
