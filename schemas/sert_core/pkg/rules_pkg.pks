create or replace package sert_core.rules_pkg
as

procedure import
  (
   p_name in varchar2
  );

procedure export;

procedure add_rule_to_rule_set
  (
   p_rule_id in number
  ,p_rule_sets in varchar2
  );

procedure copy_rule
  (
   p_rule_id   in out number
  ,p_rule_name in varchar2
  ,p_rule_key  in varchar2
  ,p_rule_sets in varchar2 default null
  );

end rules_pkg;
/