alter session set current_schema = admin;
set define off;

begin

-- delete tables
delete from sert_core.rule_severity;
delete from sert_core.rule_sets;
delete from sert_core.rule_set_types;
delete from sert_core.risks;
delete from sert_core.prefs;
delete from sert_core.reserved_strings;
delete from sert_core.rule_criteria;

-- insert severities
insert into sert_core.rule_severity (rule_severity_name, rule_severity_key, seq) values ('Low', 'LOW', 1);
insert into sert_core.rule_severity (rule_severity_name, rule_severity_key, seq) values ('Medium', 'MEDIUM', 2);
insert into sert_core.rule_severity (rule_severity_name, rule_severity_key, seq) values ('High', 'HIGH', 3);

-- insert rule set types
insert into sert_core.rule_set_types (rule_set_type_name, rule_set_type_key) values ('Security', 'SECURITY');
insert into sert_core.rule_set_types (rule_set_type_name, rule_set_type_key) values ('Quality', 'QA');

-- insert risks
insert into sert_core.risks(risk_code, risk_name, url) values ('A01-2021', 'Broken Access Control', 'https://owasp.org/Top10/A01_2021-Broken_Access_Control/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A02-2021', 'Cryptographic Failures', 'https://owasp.org/Top10/A02_2021-Cryptographic_Failures/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A03-2021', 'Injection', 'https://owasp.org/Top10/A03_2021-Injection/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A04-2021', 'Insecure Design', 'https://owasp.org/Top10/A04_2021-Insecure_Design/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A05-2021', 'Security Misconfiguration', 'https://owasp.org/Top10/A05_2021-Security_Misconfiguration/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A06-2021', 'Vulnerable and Outdated Components', 'https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A07-2021', 'Identification and Authentication Failures', 'https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A08-2021', 'Software and Data Integrity Failures', 'https://owasp.org/Top10/A08_2021-Software_and_Data_Integrity_Failures/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A09-2021', 'Security Logging and Monitoring Failures', 'https://owasp.org/Top10/A09_2021-Security_Logging_and_Monitoring_Failures/');
insert into sert_core.risks(risk_code, risk_name, url) values ('A10-2021', 'Server-Side Request Forgery', 'https://owasp.org/Top10/A10_2021-Server-Side_Request_Forgery_%28SSRF%29/');

-- insert categories
insert into sert_core.categories (category_name, category_key) values ('Authentication Scheme',	'AUTENTICATION_SCHEME');
insert into sert_core.categories (category_name, category_key) values ('User Interface Attributes',	'USER_INTERFACE_ATTRIBUTES');
insert into sert_core.categories (category_name, category_key) values ('Item Settings',	'ITEM_SETTINGS');
insert into sert_core.categories (category_name, category_key) values ('Page Settings',	'PAGE_SETTINGS');
insert into sert_core.categories (category_name, category_key) values ('Application Items',	'APPLICATION_ITEMS');
insert into sert_core.categories (category_name, category_key) values ('Application Settings',	'APPLICATION_SETTINGS');
insert into sert_core.categories (category_name, category_key) values ('Region Settings',	'REGION_SETTINGS');

-- insert preferences
insert into sert_core.prefs(pref_name, pref_key, pref_value) values ('Log Evaluations', 'LOG_EVALUATIONS', 'Y');
insert into sert_core.prefs(pref_name, pref_key, pref_value) values ('Log Imports', 'LOG_IMPORTS', 'Y');

-- insert reserved_strings
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&APP_ID.', 'APP_ID', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&FLOW_ID.', 'FLOW_ID', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&FLOW_PAGE_ID.', 'FLOW_PAGE_ID', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&APP_ALIAS.', 'APP_ALIAS', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&APP_PAGE_ID.', 'APP_PAGE_ID', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&APP_USER.', 'APP_USER', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&SESSION.', 'SESSION', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&APP_SESSION.', 'APP_SESSION', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&DEBUG.', 'DEBUG', 'SUBSTITUTION_STRING');
insert into sert_core.reserved_strings (reserved_string, reserved_string_key, reserved_string_type) values ('&APP_SECURITY_GROUP_ID.', 'APP_SECURITY_GROUP_ID', 'SUBSTITUTION_STRING');

-- insert rule_criteria_types
insert into sert_core.rule_criteria_types (rule_criteria_type_name, rule_criteria_type_key) values ('SQL Injection', 'SQLI');
insert into sert_core.rule_criteria_types (rule_criteria_type_name, rule_criteria_type_key) values ('Cross-Site Scripting', 'XSS');

-- insert rule_criteria
insert into sert_core.rule_criteria (rule_criteria_name, rule_criteria_key, rule_criteria_type_id, rule_criteria_sql, reason) values
  ('Incorrect Item Substitution Syntax', 'INCORRECT_ITEM_SUBSTITUTION_SYNTAX', (select rule_criteria_type_id from sert_core.rule_criteria_types where rule_criteria_type_key = 'SQLI'), 'select count(*) from dual where REGEXP_LIKE((:l_source), ''&[[:alnum:]]+.'', ''ix'')','Incorrect item substitution syntax');
insert into sert_core.rule_criteria (rule_criteria_name, rule_criteria_key, rule_criteria_type_id, rule_criteria_sql, reason) values
  ('Usage of EXECUTE IMMEDIATE', 'USAGE_OF_EXECUTE_IMMEDIATE', (select rule_criteria_type_id from sert_core.rule_criteria_types where rule_criteria_type_key = 'SQLI'), 'select count(*) from dual where REGEXP_LIKE((:l_source), ''EXECUTE+[ ]+IMMEDIATE'', ''i'')','EXECUTE IMMEDIATE found; please investigate');
insert into sert_core.rule_criteria (rule_criteria_name, rule_criteria_key, rule_criteria_type_id, rule_criteria_sql, reason) values
  ('Usage of DBMS_SQL', 'USAGE_OF_DBMS_SQL', (select rule_criteria_type_id from sert_core.rule_criteria_types where rule_criteria_type_key = 'SQLI'), 'select count(*) from dual where REGEXP_LIKE((:l_source), ''dbms_sql'', ''i'')','DBMS_SQL found; please investigate');
insert into sert_core.rule_criteria (rule_criteria_name, rule_criteria_key, rule_criteria_type_id, rule_criteria_sql, reason) values
  ('Usage of HTP without SYS prefix', 'USAGE_OF_HTP_WITHOUT_SYS_PREFIX', (select rule_criteria_type_id from sert_core.rule_criteria_types where rule_criteria_type_key = 'SQLI'), 'select count(*) from dual where REGEXP_LIKE((:l_source), ''[ ]htp.'', ''ix'')', 'Be sure to include the SYS prefix when making calls to HTP');
insert into sert_core.rule_criteria (rule_criteria_name, rule_criteria_key, rule_criteria_type_id, rule_criteria_sql, reason) values
  ('Usage of HTP without SYS prefix - First Character', 'USAGE_OF_HTP_WITHOUT_SYS_PREFIX_-_FIRST_CHARACTER', (select rule_criteria_type_id from sert_core.rule_criteria_types where rule_criteria_type_key = 'SQLI') , 'select count(*) from dual where lower(:l_source) like ''htp.%''', 'Be sure to include the SYS prefix when making calls to HTP');

commit;
end;
/
