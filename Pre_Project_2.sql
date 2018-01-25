My initial findings show we should pursue improving the bookmarks/tabs feature because of reasons X, Y, Z.

Here are some quick bullet points that will show why doing bookmarks/tabs is better than tabs/bookmarks.

-%n of users utilize bookmarks/tabs at least t times

1. are there more users using tabs or using bookmarks in this dataset. Also how many users are there?
--select * from events limit 20

--I used a subquery to count the users that used tabs maybe that's dumb I don't
-- know yet...

--There are 14718 users in the dataset
select count(distinct user_id) from events limit 20

-- there are 14598 users that have used tabs in the dataset

select count(events_compiled.tab_events)

from (

select distinct e.user_id, count(e.event_code) as tab_events
from events as e
where event_code = 26
group by user_id) as events_compiled

-- there were 12187 users that have used bookmarks in this dataset
select count(events_compiled.book_events)

from (

select distinct e.user_id, count(e.event_code) as book_events
from events as e
where e.event_code = 9 or (e.event_code = 10 or e.event_code = 11)
group by user_id) as events_compiled


2. which action has more counts
-- tab events that happened 452715

select sum(events_compiled.tab_events)

from (

select e.user_id, count(e.event_code) as tab_events
from events as e
where e.event_code = 26 -- or ( e.event_code = 9 or e.event_code = 10 or e.event_code = 11)
group by user_id) as events_compiled

-- Bookmark events 88778

select sum(events_compiled.book_events)

from (

select e.user_id, count(e.event_code) as book_events
from events as e
where e.event_code = 8 or ( e.event_code = 9 or e.event_code = 10 or e.event_code = 11)
group by user_id) as events_compiled

3. Make a graph which shows the amounts of events over the years or months.



---creation of subquery to new table to save resources for tabs

select tabs_compiled.user_id,
case when tabs_compiled.tab_num = ''  then '0' else tab_num end as tab_num_fix,
tabs_compiled.timestamp
into temporary tabs_test_table
from (

select e.user_id,
replace(e.data2,' tabs','') as tab_num,
e.timestamp
from events as e
where e.event_code = 26
group by e.user_id,e.data2,e.timestamp) as tabs_compiled

order by 1,3

limit 50




-- scrap code
select u.version,count(events_compiled.tab_events)

from (

select distinct e.user_id, count(e.event_code) as tab_events
from events as e
where event_code = 26
group by user_id) as events_compiled

inner join users as u on e.user_id = u.id
-- scrap code



select distinct user_id, count(event_code) as tab_events
into temporary newtable_tabs
from events
where event_code = 26
group by user_id --as events_compiled
;

select u.fx_version, sum(e.tab_events)
from users as u
left join newtable_tabs as e on u.id=e.user_id
group by 1
order by 1 desc
limit 100

select fx_version from users
group by 1
order by 1 desc
limit 100



select distinct user_id, count(event_code) as tab_events
into temporary newtable_tabs
from events
where event_code = 26
group by user_id --as events_compiled
;

select u.fx_version, sum(e.tab_events),rank () over (order by sum(e.tab_events) desc)
from users as u
left join newtable_tabs as e on u.id=e.user_id
group by 1
order by 1 desc
limit 100

select timestamp from events
order by 1 desc
limit 20

--sum(ISNULL(e.tab_events,0))

I've included one chart or table or graph that will show the points I'm trying to make

While this is my initial finding, I'm looking into these questions to solidify my findings

Q1 Look up the amount of active mozilla firefox users worldwide or in the US

Q2 take the usage of all the other events and see if there's a statistical difference in the usage of the
   tabs or the bookmarks

Q3 Read the survey questions a little closer.

(If necessary) I'm having a little bit of trouble figuring out how to run this bit of code that will tell me some new insight.

This is kind of ironic, but this is the question that's stumping me... I will ask for assitance when it comes up, but I'm still playing with the data.

On a statistical question would it be appropriate to use baye's theorem in this situation? to give the likelihood of a new 4.xx fx_version user to use a tab or bookmark. Or should I show percentages instead of probability?
