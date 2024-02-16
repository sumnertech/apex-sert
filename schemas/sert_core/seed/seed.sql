alter session set current_schema = admin;

begin

-- delete tables
delete from sert_core.rule_severity;
delete from sert_core.rule_sets;
delete from sert_core.rule_set_types;
delete from sert_core.risks;

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

commit;
end;
/
