create or replace view sert_core.rules_v
as
select
   r.rule_id
  ,r.rule_name
  ,r.rule_key
  ,r.category_id
  ,c.category_name
  ,c.category_key
  ,c.classification_id
  ,c.classification_name
  ,c.classification_key
  ,r.apex_version
  ,r.help_url
  ,r.builder_url
  ,r.impact
  ,case
    when r.impact = 'SC' then 'Shared Component'
    else initcap(r.impact)
    end as impact_rpt
  ,r.active_yn
  ,r.internal_yn
  ,r.rule_type
  ,r.view_name
  ,r.column_name
  ,r.operand
  ,case
     when r.rule_type = 'FUNCTION' then 'Function'
     when r.operand = 'SQLI' then 'Valid SQL'
     when r.operand = 'XSS' then 'Valid HTML'
     else initcap(replace(r.operand,'_', ' '))
   end
   || case
       when val_char is not null then ' ' || replace(val_char, ':', ', ')
       when val_number is not null then ' ' || to_char(val_number)
       else null end
   as operand_rpt
  ,r.val_char
  ,r.val_number
  ,r.case_sensitive_yn
  ,r.info
  ,r.fix
  ,r.time_to_fix
  ,r.rule_severity_id
  ,rs.rule_severity_name
  ,rs.rule_severity_key
  ,rs.seq as rule_severity_seq
  ,case
    when rs.rule_severity_key = 'HIGH' then 'danger'
    when rs.rule_severity_key = 'MEDIUM' then 'warning'
    when rs.rule_severity_key = 'LOW' then 'success'
    else null
   end as rule_severity_badge
  ,r.created_by
  ,r.created_on
  ,r.updated_by
  ,r.updated_on
from
  rules r
  ,categories_v c
  ,rule_severity rs
where
  r.category_id = c.category_id
  and r.rule_severity_id = rs.rule_severity_id
/
