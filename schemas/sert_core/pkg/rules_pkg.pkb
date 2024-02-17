create or replace package body sert_core.rules_pkg
as
  g_log_key varchar2(10) := log_pkg.get_log_key;
  g_log_type varchar2(100) := 'IMPORT';

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: I M P O R T
----------------------------------------------------------------------------------------------------------------------------
-- Imports rules as a JSON file
----------------------------------------------------------------------------------------------------------------------------
procedure import
  (
  p_name in varchar2
  )
is
  l_category_id       categories.category_id%type;
  l_rule_severity_id  rule_severity.rule_severity_id%type;
  l_risk_id           risks.risk_id%type;
  l_cnt               number;
begin

-- set the log_key
apex_util.set_session_state('G_LOG_KEY', g_log_key);

log_pkg.log(p_log_key => g_log_key, p_log => 'Import Started', p_log_type => g_log_type);

-- create a collection to store the parsed JSON file
apex_collection.create_or_truncate_collection(p_collection_name => 'RULES');

-- loop through the JSON file and add each rule, when able
for x in (select * from rules_json_to_relational_v where name = p_name)
loop

  -- determine if the rule key exists; do not insert if so
  select count(*) into l_cnt from rules_v where rule_key = x.rule_key;

  if l_cnt = 0 then

    -- determine if the category exists; create it if not
    begin
    select category_id into l_category_id from categories where category_key = x.category_key;
    exception
      when no_data_found then
        insert into categories (category_name, category_key) values (x.category_name, x.category_key) returning category_id into l_category_id;
        log_pkg.log(p_log_key => g_log_key, p_log => 'Created new Category: ' || x.category_name, p_log_type => g_log_type);
    end;

    -- determine if the rule severity exists; create it if not
    begin
    select rule_severity_id into l_rule_severity_id from rule_severity where rule_severity_key = x.rule_severity_key;
    exception
      when no_data_found then
        insert into rule_severity (rule_severity_name, rule_severity_key) values (x.rule_severity_name, x.rule_severity_key) returning rule_severity_id into l_rule_severity_id;
        log_pkg.log(p_log_key => g_log_key, p_log => 'Created new Rule Severity: ' || x.rule_severity_name, p_log_type => g_log_type);

    end;

    -- get the risk; these should not be created on the fly, as they are based on OWASP Top 10
    select risk_id into l_risk_id from risks where risk_code = x.risk_code;

    -- all checks cleared - insert the rule
    insert into rules
      (
       rule_name
      ,rule_key
      ,category_id
      ,risk_id
      ,rule_type
      ,rule_severity_id
      ,impact
      ,apex_version
      ,view_name
      ,column_to_evaluate
      ,component_id
      ,column_name
      ,operand
      ,val_char
      ,val_number
      ,case_sensitive_yn
      ,additional_where
      ,custom_query
      ,active_yn
      ,internal_yn
      ,help_url
      ,builder_url
      ,info
      ,fix
      ,time_to_fix
      )
    values
      (
       x.rule_name
      ,x.rule_key
      ,l_category_id
      ,l_risk_id
      ,x.rule_type
      ,l_rule_severity_id
      ,x.impact
      ,x.apex_version
      ,x.view_name
      ,x.column_to_evaluate
      ,x.component_id
      ,x.column_name
      ,x.operand
      ,x.val_char
      ,x.val_number
      ,x.case_sensitive_yn
      ,x.additional_where
      ,x.custom_query
      ,x.active_yn
      ,x.internal_yn
      ,x.help_url
      ,x.builder_url
      ,x.info
      ,x.fix
      ,x.time_to_fix
      );

    apex_collection.add_member(p_collection_name => 'RULES', p_c001 => 'SUCCESS', p_c002 => null, p_c003 => x.rule_name, p_c004 => x.rule_key, p_c005 => x.category_name, p_c006 => x.risk_code || '-' || x.risk_name);
    log_pkg.log(p_log_key => g_log_key, p_log => 'Created new Rule: ' || x.rule_name, p_log_type => g_log_type);

  else
    -- rule not uploaded as a rule key with the same name exists
    apex_collection.add_member(p_collection_name => 'RULES', p_c001 => 'FAIL', p_c002 => 'Rule already exists', p_c003 => x.rule_name, p_c004 => x.rule_key, p_c005 => x.category_name, p_c006 => x.risk_code || '-' || x.risk_name);
    log_pkg.log(p_log_key => g_log_key, p_log => 'Rule NOT Created because it already exists: ' || x.rule_name || ' / ' || x.rule_key, p_log_type => g_log_type);
  end if;

end loop;

log_pkg.log(p_log_key => g_log_key, p_log => 'Import Completed', p_log_type => g_log_type);
exception

  -- handle unanticipated errors
  when others then
    log_pkg.log(p_log_key => g_log_key, p_log => 'An unhandled error has occured', p_log_type => 'UNHANDLED');
    raise;

end import;

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: E X P O R T
----------------------------------------------------------------------------------------------------------------------------
-- Exports rules as a JSON file
----------------------------------------------------------------------------------------------------------------------------
procedure export
is
  l_blob blob;
begin

-- set the log_key
apex_util.set_session_state('G_LOG_KEY', g_log_key);

-- log the start point
log_pkg.log(p_log_key => g_log_key, p_log => 'Export Started', p_log_type => 'EXPORT');

-- generate the json file from the view
select apex_util.clob_to_blob(p_clob => json_doc) into l_blob from rules_relational_to_json_v;

-- download the file
sys.htp.init;
sys.owa_util.mime_header ('application/json', false, 'utf-8');
sys.htp.p('cache-control: no-cache');
sys.htp.p('expires: 0');
sys.htp.p('pragma: no-cache');
sys.htp.p('content-length: ' || length(l_blob));
sys.htp.p('content-disposition: attachment; filename="APEX-SERT Rules ' || to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '.json');
sys.owa_util.http_header_close;
sys.wpg_docload.download_file(l_blob);

-- log the end point
log_pkg.log(p_log_key => g_log_key, p_log => 'Export Completed', p_log_type => 'EXPORT');

apex_application.stop_apex_engine;

end export;

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: A D D _ R U L E _ T O _ R U L E _ S E T S
----------------------------------------------------------------------------------------------------------------------------
-- Adds a rule to a rule set or sets
----------------------------------------------------------------------------------------------------------------------------
procedure add_rule_to_rule_set
  (
  p_rule_id    in number
  ,p_rule_sets in varchar2
  )
is
  l_rule_set_arr apex_application_global.vc_arr2;
begin

-- convert the rule sets to an array
l_rule_set_arr := apex_string.string_to_table(p_rule_sets,':');

-- loop through them and assign the rule
for x in 1..l_rule_set_arr.count
loop
  insert into rule_set_rules (rule_set_id, rule_id) values (l_rule_set_arr(x), p_rule_id);
end loop;

end add_rule_to_rule_set;

----------------------------------------------------------------------------------------------------------------------------
-- PROCEDURE: C O P Y _ R U L E
----------------------------------------------------------------------------------------------------------------------------
-- Makes a copy of an existing rule
----------------------------------------------------------------------------------------------------------------------------
procedure copy_rule
  (
   p_rule_id   in out number
  ,p_rule_name in varchar2
  ,p_rule_key  in varchar2
  ,p_rule_sets in varchar2
  )
is
begin

-- copy the rule
for x in (select * from rules where rule_id = p_rule_id)
loop
  insert into rules
  (
     rule_name
    ,rule_key
    ,category_id
    ,risk_id
    ,rule_severity_id
    ,rule_type
    ,impact
    ,apex_version
    ,view_name
    ,column_to_evaluate
    ,component_id
    ,column_name
    ,operand
    ,val_char
    ,val_number
    ,case_sensitive_yn
    ,additional_where
    ,custom_query
    ,active_yn
    ,internal_yn
    ,help_url
    ,builder_url
    ,info
    ,fix
    ,time_to_fix
  )
  values
  (
     p_rule_name
    ,p_rule_key
    ,x.category_id
    ,x.risk_id
    ,x.rule_severity_id
    ,x.rule_type
    ,x.impact
    ,x.apex_version
    ,x.view_name
    ,x.column_to_evaluate
    ,x.component_id
    ,x.column_name
    ,x.operand
    ,x.val_char
    ,x.val_number
    ,x.case_sensitive_yn
    ,x.additional_where
    ,x.custom_query
    ,x.active_yn
    ,x.internal_yn
    ,x.help_url
    ,x.builder_url
    ,x.info
    ,x.fix
    ,x.time_to_fix
  )
returning rule_id into p_rule_id;
end loop;

-- next, add to any rule sets that were selected
if p_rule_sets is not null then
  null;

end if;

end copy_rule;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end rules_pkg;
/
