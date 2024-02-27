alter session set current_schema = sert_core;
create or replace view sert_core.comment_cnt_v
as
with er_key as
(
select
      er.eval_result_id
   ,  e.rule_set_id     || ':'
   || er.rule_id        || ':'
   || e.workspace_id    || ':'
   || er.application_id || ':'
   || er.page_id        || ':'
   || er.component_id   || ':'
   || er.item_name      || ':'
   || er.column_name    || ':'
   || er.shared_comp_name 
      as key
from
  eval_results er
  ,evals e
where
  e.eval_id = er.eval_id
),
c as
(
select
   comment_id
   ,  rule_set_id    || ':'
   || rule_id        || ':'
   || workspace_id   || ':'
   || application_id || ':'
   || page_id        || ':'
   || component_id   || ':'
   || item_name      || ':'
   || column_name    || ':'
   || shared_comp_name 
      as key
from
  comments
)
select
   er_key.eval_result_id
  ,count(c.comment_id) as cnt
from
   c
  ,er_key
  ,eval_results er
where
  er_key.key = c.key(+)
  and er.eval_result_id = er_key.eval_result_id
group by
   er_key.eval_result_id
/

