alter session set current_schema = sert_core;
set SERVEROUTPUT on;

begin
delete from evals;
eval_pkg.eval
  (
   p_application_id => 2002
   ,p_debug => true
  );
end;
/


select * from evals;
select * from eval_results;

delete from evals;
delete from rule_sets;
delete from rules;
commit;