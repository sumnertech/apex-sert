create or replace view sert_core.classifications_v
as
select
  classification_id
  ,classification_name
  ,classification_key
  ,created_by
  ,created_on
  ,updated_by
  ,updated_on
from
  classifications
/