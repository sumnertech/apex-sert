begin

-- delete tables
delete from wksp_sert.classifications;
delete from wksp_sert.rule_severity;
delete from wksp_sert.rule_sets;
delete from wksp_sert.rule_set_types;

-- insert severities
insert into wksp_sert.rule_severity (rule_severity_name, rule_severity_key, seq) values ('Low', 'LOW', 1);
insert into wksp_sert.rule_severity (rule_severity_name, rule_severity_key, seq) values ('Medium', 'MEDIUM', 2);
insert into wksp_sert.rule_severity (rule_severity_name, rule_severity_key, seq) values ('High', 'HIGH', 3);

-- insert rule set types
insert into wksp_sert.rule_set_types (rule_set_type_name, rule_set_type_key) values ('Security', 'SECURITY');
insert into wksp_sert.rule_set_types (rule_set_type_name, rule_set_type_key) values ('Quality', 'QA');

-- insert classifications
insert into wksp_sert.classifications (classification_name, classification_key) values ('Classification A', 'A');
insert into wksp_sert.classifications (classification_name, classification_key) values ('Classification B', 'B');
insert into wksp_sert.classifications (classification_name, classification_key) values ('Classification C', 'C');
insert into wksp_sert.classifications (classification_name, classification_key) values ('Classification D', 'D');
insert into wksp_sert.classifications (classification_name, classification_key) values ('Classification E', 'E');

-- insert categories
for x in (select * from wksp_sert.classifications)
loop

  insert into wksp_sert.categories (category_name, category_key, classification_id) values ('Category ' || x.classification_key || '.A', x.classification_key || '.A', x.classification_id);
  insert into wksp_sert.categories (category_name, category_key, classification_id) values ('Category ' || x.classification_key || '.B', x.classification_key || '.B', x.classification_id);
  insert into wksp_sert.categories (category_name, category_key, classification_id) values ('Category ' || x.classification_key || '.C', x.classification_key || '.C', x.classification_id);
  insert into wksp_sert.categories (category_name, category_key, classification_id) values ('Category ' || x.classification_key || '.D', x.classification_key || '.D', x.classification_id);
  insert into wksp_sert.categories (category_name, category_key, classification_id) values ('Category ' || x.classification_key || '.E', x.classification_key || '.E', x.classification_id);

end loop;

-- rules
/*
for x in (select * from wksp_sert.categories_v)
loop

  insert into wksp_sert.rules(rule_name, rule_key, category_id, apex_version, rule_severity_id) values ('Rule ' || 'A.' || x.category_key, 'A.' || x.category_key, x.category_id, '23.2', (select rule_severity_id from wksp_sert.rule_severity where rule_severity_key = 'MEDIUM'));
  insert into wksp_sert.rules(rule_name, rule_key, category_id, apex_version, rule_severity_id) values ('Rule ' || 'B.' || x.category_key, 'B.' || x.category_key, x.category_id, '23.2', (select rule_severity_id from wksp_sert.rule_severity where rule_severity_key = 'MEDIUM'));
  insert into wksp_sert.rules(rule_name, rule_key, category_id, apex_version, rule_severity_id) values ('Rule ' || 'C.' || x.category_key, 'C.' || x.category_key, x.category_id, '23.2', (select rule_severity_id from wksp_sert.rule_severity where rule_severity_key = 'MEDIUM'));
  insert into wksp_sert.rules(rule_name, rule_key, category_id, apex_version, rule_severity_id) values ('Rule ' || 'D.' || x.category_key, 'D.' || x.category_key, x.category_id, '23.2', (select rule_severity_id from wksp_sert.rule_severity where rule_severity_key = 'MEDIUM'));
  insert into wksp_sert.rules(rule_name, rule_key, category_id, apex_version, rule_severity_id) values ('Rule ' || 'E.' || x.category_key, 'E.' || x.category_key, x.category_id, '23.2', (select rule_severity_id from wksp_sert.rule_severity where rule_severity_key = 'MEDIUM'));

end loop;
*/

commit;
end;
/
