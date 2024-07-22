create or replace view sert_core.exceptions_json_to_rel_v as
select
   application_id
  ,rule_set_id
  ,max (rownum) as num_rows
  ,json_arrayagg
    (
    json_object
      (
       'ruleSetKey'         is rule_set_key
      ,'ruleKey'            is rule_key
      ,'apexVersion'        is apex_version
      ,'exception'          is exception
      ,'workspaceId'        is workspace_id
      ,'applicationId'      is application_id
      ,'pageId'             is page_id
      ,'componentId'        is component_id
      ,'columnName'         is column_name
      ,'itemName'           is item_name
      ,'sharedCompName'     is shared_comp_name
      ,'result'             is result
      ,'reason'             is reason
      ,'currentValue'       is current_value
      ,'createdBy'          is created_by
      ,'createdOn'          is created_on
      ,'updatedBy'          is updated_by
      ,'updatedOn'          is updated_on
      ,'actionedBy'         is actioned_by
      ,'actionedOn'         is actioned_on
      ,'componentName'      is component_name
      ,'checksum'           is checksum
      )
    format json returning clob
  ) as json_doc
from
  exceptions_v
group by
   application_id
  ,rule_set_id
/