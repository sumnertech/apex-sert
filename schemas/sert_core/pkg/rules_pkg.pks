create or replace package rules_pkg
as

procedure import
  (
  p_name in varchar2
  );

procedure export;

end rules_pkg;
/