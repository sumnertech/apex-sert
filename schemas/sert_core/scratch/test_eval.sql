alter session set current_schema = sert_core;
set SERVEROUTPUT off;

begin
delete from evals;
eval_pkg.eval
  (
   p_application_id => 2001
   ,p_debug => true
  );
end;
/

select r.rule_name, er.* from eval_results er, rules_v r where er.rule_id = r.rule_id;

delete from evals;
delete from rule_sets;
delete from rules;
commit;
