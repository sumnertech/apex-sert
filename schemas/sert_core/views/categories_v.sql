create or replace view sert_core.categories_v
as
select
   cat.category_id
  ,cat.category_name
  ,cat.category_key
  ,cat.description
  ,cat.created_by
  ,cat.created_on
  ,cat.updated_by
  ,cat.updated_on
from
  categories cat
/