create or replace package body rules_pkg
as

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

-- loop through the JSON file and add each rule, when able
for x in (select * from  rules_json_to_relational_v where  name = p_name)
loop

  -- determine if the rule key exists; do not insert if so
  select count(*) into l_cnt from rules_v where rule_key = x.rule_key;

  if l_cnt = 0 then

    -- determine if the classification exists; create it if not
    begin
    select classification_id into l_classification_id from classifications where classification_key = x.classification_key;
    exception
      when no_data_found then
        -- //TODO log that the classification was created
        insert into classifications (classification_name, classification_key) values (x.classification_name, x.classification_key) returning classification_id into l_classification_id;
    end;

    -- determine if the category exists; create it if not
    begin
    select category_id into l_category_id from categories where category_key = x.category_key;
    exception
      when no_data_found then
        -- //TODO log that the category was created
        insert into categories (category_name, category_key, classification_id) values (x.category_name, x.category_key, l_classification_id) returning category_id into l_category_id;
    end;

    -- determine if the rule severity exists; create it if not
    begin
    select rule_severity_id into l_rule_severity_id from rule_severity where rule_severity_key = x.rule_severity_key;
    exception
      when no_data_found then
        -- //TODO log that the severity was created
        insert into rule_severity (rule_severity_name, rule_severity_key) values (x.rule_severity_name, x.rule_severity_key) returning rule_severity_id into l_rule_severity_id;
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

    -- //TODO: log that the rule was created

  else
    -- //TODO: log that the rule was not created
    null;
  end if;

end loop;

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
apex_application.stop_apex_engine;

end export;


----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
end rules_pkg;
/
