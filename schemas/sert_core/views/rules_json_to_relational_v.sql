create or replace view sert_core.rules_json_to_relational_v as
select
   j.rule_name
  ,j.rule_key
  ,j.category_name
  ,j.category_key
  ,j.classification_name
  ,j.classification_key
  ,j.apex_version
  ,j.help_url
  ,j.builder_url
  ,j.impact
  ,j.active_yn
  ,j.internal_yn
  ,j.rule_type
  ,j.view_name
  ,j.column_name
  ,j.operand
  ,j.val_char
  ,j.val_number
  ,j.case_sensitive_yn
  ,j.info
  ,j.fix
  ,j.time_to_fix
  ,j.rule_severity_name
  ,j.rule_severity_key
  ,j.created_by
  ,j.created_on
  ,j.updated_by
  ,j.updated_on
  ,f.name
from
  apex_application_temp_files f
  ,json_table
    (
    f.blob_content
    ,'$[*]'
   columns
      (
       rule_name           varchar path '$.ruleName'
      ,rule_key            varchar path '$.ruleKey'
      ,category_name       varchar path '$.categoryName'
      ,category_key        varchar path '$.categoryKey'
      ,classification_name varchar path '$.classificationName'
      ,classification_key  varchar path '$.classificationKey'
      ,apex_version        number  path '$.apexVersion'
      ,help_url            varchar path '$.helpUrl'
      ,builder_url         varchar path '$.builderUrl'
      ,impact              varchar path '$.impact'
      ,active_yn           varchar path '$.activeYN'
      ,internal_yn         varchar path '$.internalYN'
      ,rule_type           varchar path '$.ruleType'
      ,view_name           varchar path '$.viewName'
      ,column_name         varchar path '$.columnName'
      ,operand             varchar path '$.operand'
      ,val_char            varchar path '$.valChar'
      ,val_number          number  path '$.valNumber'
      ,case_sensitive_yn   varchar path '$.caseSensitiveYN'
      ,info                varchar path '$.info'
      ,fix                 varchar path '$.fix'
      ,time_to_fix         varchar path '$.timeToFix'
      ,rule_severity_name  varchar path '$.ruleSeverityName'
      ,rule_severity_key   varchar path '$.ruleSeverityKey'
      ,created_by          varchar path '$.createdBy'
      ,created_on          date    path '$.createdOn'
      ,updated_by          varchar path '$.updatedBy'
      ,updated_on          date    path '$.updatedOn'
      )
    ) j
