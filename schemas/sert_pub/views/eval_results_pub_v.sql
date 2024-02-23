create or replace view sert_pub.eval_results_pub_v
as
select
   eval_result_id
  ,eval_id
  ,workspace_id
  ,application_id
  ,page_id
  ,page_name
  ,page_id || ': ' || page_name
      || case when region_name is not null then ' / ' || region_name else null end
      || case when column_name is not null then ' / ' || column_name else null end
      || case when item_name   is not null then ' / ' || item_name   else null end
   as description
  ,region_name
  ,component_id
  ,column_name
  ,item_name
  ,category_name
  ,category_key
  ,current_value
  ,valid_values
  ,result
  ,result_color
  ,reason
  ,rule_id
  ,rule_name
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
   sert_core.eval_results_pub_v
/
