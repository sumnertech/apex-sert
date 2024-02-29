create or replace package sert_core.exceptions_api
as

function show_exception
  (
  p_eval_result_id in number    
  )
return boolean;

end exceptions_api;
/
