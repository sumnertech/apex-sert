create or replace view sert_core.categories_v
as
select
   cat.category_id
  ,cat.classification_id
  ,c.classification_name
  ,c.classification_key
  ,cat.category_name
  ,cat.category_key
  ,cat.created_by
  ,cat.created_on
  ,cat.updated_by
  ,cat.updated_on
from
  categories cat
  ,classifications c
where
  cat.classification_id = c.classification_id
/