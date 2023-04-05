--  1.  Original

with exp as (select ev.beacon
,session_id
from statsdb.fact_trackingevent_events ev
left join statsdb.fact_pageview_events pv
on ev.pv_unique_id = pv.pv_unique_id
where date(concat(ev.year,'-',ev.month,'-',ev.day)) between date('2021-11-03') and date('2021-11-15')
and date(concat(pv.year,'-',pv.month,'-',pv.day)) between date('2021-11-03') and date('2021-11-15')
and ga_category in ('pf-experiments: DesktopRelatedWikisModule','pf-experiments: MobileRelatedWikisModule')
group by 1,2
) 
, 
pv_sess as (
select beacon, session_id
, count(distinct pv_unique_id) as num_pv_ps
from statsdb.fact_pageview_events pv
where date(concat(pv.year,'-',pv.month,'-',pv.day)) between date('2021-11-03') and date('2021-11-15')
and session_id in (select distinct session_id from exp)
group by 1,2)

select exp.*
, pvs.num_pv_ps
from exp
left join pv_sess pvs on pvs.session_id = exp.session_id 

limit 100




--------
--------

--  2. Mean pv/session for each variant in an Experiment, and Grand Total

-- 12/13/2021 
-- Victoria:  I am trying to figure out a way to make this code print out the mean pv/session for each variant in an experiment, as well as the grand total.

with exp as (
    select 
         extras['experimentVariant'] as var,
         session_id
    from statsdb.fact_trackingevent_events ev
         left join statsdb.fact_pageview_events pv
         on ev.pv_unique_id = pv.pv_unique_id
         where  date(concat(ev.year,'-',ev.month,'-',ev.day)) between date('2021-10-20') and date('2021-10-20')
         and date(concat(pv.year,'-',pv.month,'-',pv.day)) between date('2021-10-20') and date('2021-10-20')
         and ga_category='pf-experiments: DesktopArticlesViewedModule'
         and extras['experimentVariant'] like '%fandoms%'
         and ga_action in ('inserted','impression','click')
    group by 1,2
)
,
pv_sess as (
    select session_id,
           count(distinct pv_unique_id) as num_pv_ps
           --count(pvs.pv_unique_id) as total_pv
           --count(pvs.session_id) as total_sessions
    from statsdb.fact_pageview_events pv
    where date(concat(pv.year,'-',pv.month,'-',pv.day)) between date('2021-10-20') and date('2021-10-20')
            and session_id in (select distinct session_id from exp)
    group by 1
)

select exp.*,
       pvs.num_pv_ps as total_pgv_session,
       avg(pvs.num_pv_ps) over(partition by var) as avg_pvs_var    --average pgv/session over variant
       --pvs.total_pv/pvs.total_sessions as total_pgv_session
from exp left join pv_sess pvs on pvs.session_id = exp.session_id
group by 1,2,3
order by 2







-------------------------

--  3.  find numbers for "Fandom Data Visualization Fields Required - Dec 2021"
--  https://docs.google.com/spreadsheets/d/1JtI7001Thh2QgyH0RgLqe45CI-dHhvi5SQH1KqJsPAM/edit#gid=845485666

-- 12/13/2021 
-- Victoria:  I am trying to figure out a way to make this code print out the mean pv/session for each variant in an experiment, as well as the grand total.

-- variables
-- date('2021-09-01') and date('2021-09-14')
-- ga_category='pf-experiments: DesktopInfoboxImageReactionModule'



with exp as (
    select 
         extras['experimentVariant'] as var,
         session_id
    from statsdb.fact_trackingevent_events ev
         left join statsdb.fact_pageview_events pv
         on ev.pv_unique_id = pv.pv_unique_id
         where  date(concat(ev.year,'-',ev.month,'-',ev.day)) between date('2021-09-01') and date('2021-09-14')
         and date(concat(pv.year,'-',pv.month,'-',pv.day)) between date('2021-09-01') and date('2021-09-14')
         and ga_category='pf-experiments: DesktopInfoboxImageReactionModule'
         
         --and extras['experimentVariant'] like '%fandoms%'     -- v1
         and extras['experimentVariant'] is not null            -- v2
         
         and ga_action in ('inserted','impression','click')
    group by 1,2
)
,
pv_sess as (
    select session_id,
           count(distinct pv_unique_id) as num_pv_ps
           --count(pvs.pv_unique_id) as total_pv
           --count(pvs.session_id) as total_sessions
    from statsdb.fact_pageview_events pv
    where date(concat(pv.year,'-',pv.month,'-',pv.day)) between date('2021-09-01') and date('2021-09-14')
            and session_id in (select distinct session_id from exp)
    group by 1
)

select exp.*,
       pvs.num_pv_ps as total_pgv_session,
       avg(pvs.num_pv_ps) over(partition by var) as avg_pvs_var    --average pgv/session over variant
       --pvs.total_pv/pvs.total_sessions as total_pgv_session
from exp left join pv_sess pvs on pvs.session_id = exp.session_id
group by 1,2,3
order by 2



---------------------

--  4. Scott's


with exp as (
    select 
         extras['experimentVariant'] as var,
         session_id
    from statsdb.fact_trackingevent_events ev
         left join statsdb.fact_pageview_events pv
         on ev.pv_unique_id = pv.pv_unique_id
         where  date(concat(ev.year,'-',ev.month,'-',ev.day)) between  date('2021-11-24') and date('2021-12-01')
         and date(concat(pv.year,'-',pv.month,'-',pv.day)) between  date('2021-11-24') and date('2021-12-01')
         and ga_category like ('%VisitedModule%')
         --and ga_action in ('inserted','impression','click')
         and ga_action = 'impression'
    group by 1,2
)
,
pv_sess as (
    select session_id,
           count(distinct pv_unique_id) as num_pv_ps
    from statsdb.fact_pageview_events pv
    where date(concat(pv.year,'-',pv.month,'-',pv.day)) between  date('2021-11-24') and date('2021-12-01')
            and session_id in (select distinct session_id from exp)
    group by 1
)
, pv_sess_var as (
select exp.*,
       pvs.num_pv_ps as total_pgv_session
--       avg(pvs.num_pv_ps) over(partition by var) as avg_pvs_var
from exp left join pv_sess pvs on pvs.session_id = exp.session_id
group by 1,2,3
)

select var
, avg(pvs.total_pgv_session) as avg_pvs
, stddev(pvs.total_pgv_session) as stddev_pvs
from pv_sess_var pvs
group by 1
order by 1