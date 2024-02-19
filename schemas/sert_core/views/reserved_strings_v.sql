create or replace view sert_core.reserved_strings_v
as
select
   reserved_string_id
  ,reserved_string
  ,reserved_string_key
  ,reserved_string_type
  ,active_yn
  ,case when active_yn = 'Y' then 'Active' else 'Inactive' end as active_value
  ,case when active_yn = 'Y' then 'success' else 'danger' end as active_color
  ,description
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
  reserved_strings
/