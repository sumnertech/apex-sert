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
  l_classification_id classifications.classification_id%type;
  l_category_id       categories.category_id%type;
  l_rule_severity_id  rule_severity.rule_severity_id%type;
  l_cnt               number;
begin

log_pkg.log(p_log_key => g_log_key, p_log => 'Import Started', p_log_type => g_log_type);

apex_collection.create_or_truncate_collection(p_collection_name => 'RULES');

-- loop through the JSON file and add each rule, when able
for x in (select * from rules_json_to_relational_v where name = p_name)
loop

  -- determine if the rule key exists; do not insert if so
  select count(*) into l_cnt from rules_v where rule_key = x.rule_key;

  if l_cnt = 0 then

    -- determine if the classification exists; create it if not
    begin
    select classification_id into l_classification_id from classifications where classification_key = x.classification_key;
    exception
      when no_data_found then
        insert into classifications (classification_name, classification_key) values (x.classification_name, x.classification_key) returning classification_id into l_classification_id;
        log_pkg.log(p_log_key => g_log_key, p_log => 'Created new Classification: ' || x.classification_name, p_log_type => g_log_type);
    end;

    -- determine if the category exists; create it if not
    begin
    select category_id into l_category_id from categories where category_key = x.category_key;
    exception
      when no_data_found then
        insert into categories (category_name, category_key, classification_id) values (x.category_name, x.category_key, l_classification_id) returning category_id into l_category_id;
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

    -- all checks cleared - insert the rule
    insert into rules
      (
      rule_name
      ,rule_key
      ,category_id
      ,rule_type
      ,rule_severity_id
      ,impact
      ,apex_version
      ,view_name
      ,column_name
      ,operand
      ,val_char
      ,val_number
      ,case_sensitive_yn
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
      ,x.rule_type
      ,l_rule_severity_id
      ,x.impact
      ,x.apex_version
      ,x.view_name
      ,x.column_name
      ,x.operand
      ,x.val_char
      ,x.val_number
      ,x.case_sensitive_yn
      ,x.active_yn
      ,x.internal_yn
      ,x.help_url
      ,x.builder_url
      ,x.info
      ,x.fix
      ,x.time_to_fix
      );

    apex_collection.add_member(p_collection_name => 'RULES', p_c001 => 'SUCCESS', p_c002 => null, p_c003 => x.rule_name, p_c004 => x.rule_key, p_c005 => x.category_name, p_c006 => x.classification_name);
    log_pkg.log(p_log_key => g_log_key, p_log => 'Created new Rule: ' || x.rule_name, p_log_type => g_log_type);

  else
    -- rule not uploaded as a rule key with the same name exists
    apex_collection.add_member(p_collection_name => 'RULES', p_c001 => 'FAIL', p_c002 => 'Rule already exists', p_c003 => x.rule_name, p_c004 => x.rule_key, p_c005 => x.category_name, p_c006 => x.classification_name);
    log_pkg.log(p_log_key => g_log_key, p_log => 'Rule NOT Created because it already exists: ' || x.rule_name || ' / ' || x.rule_key, p_log_type => g_log_type);
  end if;

end loop;

log_pkg.log(p_log_key => g_log_key, p_log => 'Import Completed', p_log_type => g_log_type);
exception

  -- handle unanticipated errors
  when others then
    log_pkg.log(p_log_key => g_log_key, p_log => 'An unhandled error has occured', p_log_type => 'UNHANDLED');--, p_log_clob => dbms_utility.FORMAT_ERROR_STACK || DBMS_UTILITY.format_error_backtrace);
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

log_pkg.log(p_log_key => g_log_key, p_log => 'Export Completed', p_log_type => 'EXPORT');

apex_application.stop_apex_engine;

end export;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end rules_pkg;
/
