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