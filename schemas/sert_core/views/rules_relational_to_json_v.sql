create or replace view sert_core.rules_relational_to_json_v
as
select
   max (rownum) as num_rows
  ,json_arrayagg
    (
    json_object
      (
       'ruleName'            is rule_name
      ,'ruleKey'             is rule_key
      ,'categoryName'        is category_name
      ,'categoryKey'         is category_key
      ,'riskCode'            is risk_code
      ,'riskName'            is risk_name
      ,'apexVersion'         is apex_version
      ,'helpUrl'             is help_url
      ,'builderUrl'          is builder_url
      ,'impact'              is impact
      ,'activeYN'            is active_yn
      ,'internalYN'          is internal_yn
      ,'ruleType'            is rule_type
      ,'viewName'            is view_name
      ,'columnToEvaluate'    is column_to_evaluate
      ,'componentId'         is component_id
      ,'componentName'       is component_name
      ,'columnName'          is column_name
      ,'itemName'            is item_name
      ,'sharedCompName'      is shared_comp_name
      ,'operand'             is operand
      ,'valChar'             is val_char
      ,'valNumber'           is val_number
      ,'caseSensitiveYN'     is case_sensitive_yn
      ,'ruleCriteriaTypeKey' is rule_criteria_type_key
      ,'additionalWhere'     is additional_where
      ,'customQuery'         is custom_query
      ,'info'                is info
      ,'fix'                 is fix
      ,'timeToFix'           is time_to_fix
      ,'ruleSeverityName'    is rule_severity_name
      ,'ruleSeverityKey'     is rule_severity_key
      ,'descriotion'         is description
      ,'createdBy'           is created_by
      ,'createdOn'           is created_on
      ,'updatedBy'           is updated_by
      ,'updatedOn'           is updated_on
      )
    format json returning clob
  ) as json_doc
from
  rules_v
/