create or replace package body sert_core.eval_pkg
as
  g_log_key varchar2(10) := log_pkg.get_log_key;
  g_log_type varchar2(100) := 'EVAL';


----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: P R O C E S S _ R U L E S
----------------------------------------------------------------------------------------------------------------------------
-- Process all rules for a specific evaluation
----------------------------------------------------------------------------------------------------------------------------
procedure process_rules
  (
   p_application_id in number
  ,p_eval_id        in number
  ,p_rule_set_id    in number
  ,p_debug          in boolean
  )
is
  cursor   l_cursor is select r.* from rules r, rule_set_rules rsr where r.rule_id = rsr.rule_id and rsr.rule_set_id = p_rule_set_id;
  l_row    l_cursor%rowtype;
  l_result varchar2(1000);
  l_sql    varchar2(10000);
begin

-- start the evaluation
log_pkg.log(p_log => 'Evaluation started', p_log_key => g_log_key, p_log_type => g_log_type);

-- open the rules cursor
open l_cursor;
  loop
    fetch l_cursor into l_row;
    exit when l_cursor%notfound;

    -- record which rule is being evaluated
    log_pkg.log(p_log => 'Evaluating rule ' || l_row.rule_name || ' (' || l_row.rule_key || ')', p_id => l_row.rule_id, p_id_col => 'rule_id', p_log_key => g_log_key, p_log_type => g_log_type);

    -- process each rule for the application
    case
      when l_row.rule_type = 'APEX_VIEW' then

      l_sql :=
         'select '
      -- include the corresponding eval_id
      || '  ' || p_eval_id     || ' as eval_id'

      -- include the corresponding rule_id from the cursor
      || ' ,' || l_row.rule_id || ' as rule_id'

      -- always include application_id
      || ' ,application_id'

      -- include page_id if the impact is not Application or Shared Components
      || case when l_row.impact in ('APP', 'SC') then ',null as page_id' else ',page_id' end
      || ' ,' || nvl(l_row.component_id, 'null') || ' as component_id'
      || ' ,null as column_name'

      -- display the current value of the column being investigated
      || ' ,' || l_row.column_to_evaluate || ' as current_value'

      -- display the list of value values for this rule
      || ' ,''' || initcap(replace(l_row.operand,'_',' ')) || ' ' || nvl(replace(l_row.val_char,':',', '),l_row.val_number) || ''' as valid_values';

      -- determine the result
      case
        -- EQUALS
        when l_row.operand = 'EQUALS' then
          if l_row.case_sensitive_yn = 'Y' then
            l_result := l_result || ', case when '|| l_row.column_to_evaluate || ' in (''' || l_row.val_char || ''') then ''PASS'' else ''FAIL''';
          else
            l_result := l_result || ', case when upper(' || l_row.column_to_evaluate || ') in (upper(''' || replace(l_row.val_char,':','''),upper(''') || ''')) then ''PASS'' else ''FAIL''';
          end if;

        -- NOT_EQUALS
        when l_row.operand = 'DOES_NOT_EQUAL' then
          if l_row.case_sensitive_yn = 'Y' then
            l_result := l_result || ', case when '|| l_row.column_to_evaluate || ' not in (''' || l_row.val_char || ''') then ''PASS'' else ''FAIL''';
          else
            l_result := l_result || ', case when upper(' || l_row.column_to_evaluate || ') not in (upper(''' || replace(l_row.val_char,':','''),upper(''') || ''')) then ''PASS'' else ''FAIL''';
          end if;

        -- GREATER_THAN
        when l_row.operand = 'GREATER_THAN' then
          l_result := ', case when ' || l_row.column_to_evaluate || ' > ' || l_row.val_number || ' then ''PASS'' else ''FAIL''';

        -- LESS_THAN
        when l_row.operand = 'LESS_THAN' then
          l_result := ', case when ' || l_row.column_to_evaluate || ' < ' || l_row.val_number || ' then ''PASS'' else ''FAIL''';

        -- IS_NOT_NULL
        when l_row.operand = 'IS_NOT_NULL' then
          l_result := ', case when ' || l_row.column_to_evaluate || ' is not null then ''PASS'' else ''FAIL''';

        -- IS_NULL
        when l_row.operand = 'IS_NULL' then
          l_result := ', case when ' || l_row.column_to_evaluate || ' is null then ''PASS'' else ''FAIL''';

        -- SQL
        when l_row.operand = 'SQLI' then
          l_result := ', case when 1=1 then ''PASS'' else ''FAIL''';

        -- HTML
        when l_row.operand = 'XSS' then
          l_result := ', case when 1=1 then ''FAIL'' else ''PASS''';

        -- No match
        else null;

      end case;

      -- close the case statement
      l_sql := l_sql || l_result || ' end as result';

      -- add the from and where clause
      l_sql := l_sql
        || ' ,null as result_details'
        || ' from ' || l_row.view_name
        || ' where 1=1'
        || ' and application_id = ' || p_application_id;

      -- add the optional where clause
      l_sql := l_sql || ' ' || l_row.additional_where;

    when l_row.rule_type = 'CUSTOM_QUERY' then
      -- replace the EVAL_ID
      l_sql := replace(l_row.custom_query, '#EVAL_ID#', p_eval_id);

      -- replace the APP_ID in case its used in a with or subquery
      l_sql := replace(l_sql, '#APP_ID#', p_application_id);

      -- replace the RULE_ID with the current one
      l_sql := replace(l_sql, '#RULE_ID#', l_row.rule_id);

      -- select the application_id from a outer query in case it has an alias on it
      l_sql := ' select * from (' || l_sql || ' ) where application_id = ' || p_application_id;

    end case;


    -- add the insert statement
    l_sql := 'insert into eval_results (eval_id, rule_id, application_id, page_id, component_id, column_name, current_value, valid_values, result, result_details) ' || l_sql;

    if p_debug = true then
      dbms_output.put_line(l_sql);
    end if;

    -- run the sql, populating the eval_results table
    log_pkg.log(p_log_key => g_log_key, p_log => 'SQL for Rule ' || l_row.rule_name || ' (' || l_row.rule_key || ')', p_log_type => 'EVAL', p_log_clob => l_sql, p_id => l_row.rule_id, p_id_col => 'rule_id');
    -- log_pkg.log(p_log_key => g_log_key, p_log => 'SQL', p_log_type => 'EVAL', p_log_clob => l_result);
    execute immediate l_sql;

    -- reset the variables
    l_sql := null;
    l_result := null;

  end loop;

close l_cursor;

-- end the evaluation
log_pkg.log(p_log => 'Evaluation completed', p_log_key => g_log_key, p_log_type => g_log_type);

end process_rules;


----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: E V A L
----------------------------------------------------------------------------------------------------------------------------
-- Main evaluation procedure that will run and record an evaluation
----------------------------------------------------------------------------------------------------------------------------
procedure eval
  (
   p_application_id in number
  ,p_rule_set_key   in varchar2 default 'INTERNAL'
  ,p_eval_by        in varchar2 default coalesce(sys_context('APEX$SESSION','APP_USER'),user)
  ,p_debug          in boolean default false
  )
is
  l_rule_set_id  rule_sets.rule_set_id%type;
  l_eval_id      evals.eval_id%type;
  l_workspace_id number;
begin

-- set the log_key
apex_util.set_session_state('G_LOG_KEY', g_log_key);

-- get the rule_set_id
select rule_set_id into l_rule_set_id from rule_sets where rule_set_key = p_rule_set_key;

-- get the workspace_id
select workspace_id into l_workspace_id from apex_applications where application_id = p_application_id;

-- create a new evaluation
insert into evals
  (
   application_id
  ,workspace_id
  ,rule_set_id
  ,eval_on
  ,eval_by
  )
values
  (
   p_application_id
  ,l_workspace_id
  ,l_rule_set_id
  ,systimestamp
  ,p_eval_by
  )
returning eval_id into l_eval_id;

-- process all rules for the rule set
process_rules
  (
   p_application_id => p_application_id
  ,p_eval_id        => l_eval_id
  ,p_rule_set_id    => l_rule_set_id
  ,p_debug          => p_debug
  );

exception
  when others then
    log_pkg.log(p_log => 'An unhandled error has occured', p_log_key => g_log_key, p_log_type => 'UNHANDLED');
    raise;

end eval;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end eval_pkg;
/
