
--------hourly usage code

select e.user_id, count(e.event_code) as bookmark_activity,

case when s.q7::INT >= 5 then 8 when s.q7::INT = 4 then 6
when s.q7::INT = 3 then 4 when s.q7::INT = 2 then 2
when s.q7::INT <= 1 then 1 end as customer_hour_online,

case when s.q1::INT >= 5 then 'longtime_user' when s.q1::INT <= 4 then 'shorttime_user' end as customer_commitment,

count(s.q7::INT) as annoyance,
count(s.q1::INT) as annoyance2

into temporary bookmark_act_table

from events as e
inner join survey as s on e.user_id=s.user_id
where e.event_code = 9 or (e.event_code = 10 or e.event_code = 11)


-- new stuff above
group by e.user_id,s.q7,s.q1
order by bookmark_activity desc


-----results exported to csv in project 2 folder
;

select
round(avg(bookmark_activity),0) avg_bookmark_act,
round(avg(bookmark_activity/customer_hour_online),0) avg_bookactDIVcustHours,
customer_hour_online,
count(user_id) as num_of_users
from bookmark_act_table

group by customer_hour_online
order by customer_hour_online

;

select --customer_hour_online, round(avg(bookmark_activity),0),count(user_id)

round(avg(bookmark_activity),0) avg_bookmark_act,
round(avg(bookmark_activity/customer_hour_online),0) avg_bookactDIVcustHours,
count(user_id) as num_of_users
from bookmark_act_table


--avg of bookmarks used 10 and bookmarks per hour = 2 for 1225 users

--group by customer_hour_online
--order by customer_hour_online

;

select --customer_hour_online, round(avg(bookmark_activity),0),count(user_id)

customer_commitment,
round(avg(bookmark_activity),0) avg_bookmark_act,
round(avg(bookmark_activity/customer_hour_online),0) avg_bookactDIVcustHours,
count(user_id) as num_of_users
from bookmark_act_table
group by customer_commitment

;



--avg of bookmarks used 10 and bookmarks per hour = 2 for 1225 users

--group by customer_hour_online
--order by customer_hour_online
