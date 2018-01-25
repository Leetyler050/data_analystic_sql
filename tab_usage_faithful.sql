select tabs_compiled.user_id,
case when tabs_compiled.tab_num = ''  then '0' else tab_num end as tab_num_fix,
tabs_compiled.timestamp,
tabs_compiled.event_code
into temporary tabs_test_table
from (

select e.user_id,
replace(e.data2,' tabs','') as tab_num,
e.timestamp,
e.event_code
from events as e
where e.event_code = 26
group by e.user_id,e.data2,e.timestamp,event_code) as tabs_compiled

order by 1,3

--limit 1000 -- "safety" don't fire until ready

;
SELECT t.user_id, t.event_code,t.tab_num_fix::INT as tab_num,t.prev_tab_count,t.timestamp

into temporary tab_sum_table

FROM
(
    SELECT t.*, lag(t.tab_num_fix::INT) OVER (ORDER BY t.user_id,t.timestamp) as prev_tab_count
    FROM tabs_test_table t
  ) as t
  WHERE t.tab_num_fix::INT != t.prev_tab_count
  AND (t.tab_num_fix::INT != 0 and t.prev_tab_count != 0)

---limit 300 --saftey

;

select st.user_id, st.event_code, SUM(ABS(st.tab_num - st.prev_tab_count)) as activity_frequency,
sum((ABS(st.tab_num - st.prev_tab_count) - (st.tab_num - st.prev_tab_count))/2) as tabs_opened

into temporary avg_tab_table

from tab_sum_table st
GROUP BY 1,2
ORDER BY st.user_id

;

select round(avg(at.activity_frequency),0) as avg_tab_activity, round(avg(at.tabs_opened),0) as avg_tabs_opened

from avg_tab_table as at

--avg_tab_activity 31
--avg_tabs_opened 16
-- count 12381 users


;
------------------- section for hourly tab usage code extenstion

select at.activity_frequency, at.tabs_opened,

case when s.q7::INT >= 5 then 8 when s.q7::INT = 4 then 6
when s.q7::INT = 3 then 4 when s.q7::INT = 2 then 2
when s.q7::INT <= 1 then 1 end as customer_hour_online,

case when q1::INT >= 5 then 'longtime_user' when q1::INT <= 4 then 'shorttime_user' end as customer_commitment

into temporary tabs_by_hourly_table

from avg_tab_table as at

inner join survey as s on at.user_id=s.user_id


-- user_id total is 1947

;

select tbh.customer_commitment,round(avg(tbh.activity_frequency),0) as avg_tab_act_hourly,
round(avg(tbh.tabs_opened),0) as avg_tabs_opened_hourly,
tbh.customer_hour_online, count(customer_hour_online) as customers_counted

from tabs_by_hourly_table as tbh
group by tbh.customer_hour_online, tbh.customer_commitment
order by tbh.customer_hour_online

--- this was sent to a csv in project to for a pretty graph

------ avg for hourly data
;
select -- round(avg(tbh.activity_frequency),0) as avg_tab_act_hourly,
--round(avg(tbh.tabs_opened),0) as avg_tabs_opened_hourly,
--tbh.customer_hour_online, count(customer_hour_online) as customers_counted
customer_commitment,
round(avg(tbh.activity_frequency/customer_hour_online),0) as avg_tab_act_by_hour,
round(avg(tbh.tabs_opened/customer_hour_online),0) as avg_tab_opened_by_hour


from tabs_by_hourly_table as tbh
group by customer_commitment
--group by tbh.customer_hour_online
--order by tbh.customer_hour_online

-- avg_tab_act_by_hour     7
-- avg_tab_opened_by_hour  3
