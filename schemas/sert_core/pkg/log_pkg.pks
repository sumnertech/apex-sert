create or replace package sert_core.log_pkg
as

function get_log_key
return varchar2;

procedure log
  (
   p_log            in varchar2 default null
  ,p_application_id in number   default null
  ,p_log_type       in varchar2 default 'GENERIC'
  ,p_log_key        in varchar2 default null
  ,p_log_clob       in varchar2 default null
  ,p_id             in varchar2 default null
  ,p_id_col         in varchar2 default null
  );

function error
  (
  p_error in apex_error.t_error
  )
return apex_error.t_error_result;

end log_pkg;
/
