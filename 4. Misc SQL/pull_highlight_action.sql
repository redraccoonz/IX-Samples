select split_part(ga_category,': ',2) as exp
, extras['experimentVariant'] as var
, beacon
, count(distinct case when ga_action = 'impression' then beacon end) as user_saw_image
, count(distinct case when ga_action = 'click' then beacon end) as user_clicked
, sum(case when ga_action = 'impression' then 1 else 0 end) as total_impressions
, sum(case when ga_action = 'click' then 1 else 0 end) as total_clicks

, round((1.0*count(distinct case when ga_action = 'click' then beacon end))/(1.0*count(distinct case when ga_action = 'impression' then beacon end)),6) as user_participation
, round((1.0*sum(case when ga_action = 'click' then 1 else 0 end))/(1.0*count(distinct case when ga_action = 'click' then beacon end)),6) as clicks_per_user


from statsdb.fact_trackingevent_events
where date(concat(year,'-',month,'-',day)) between date('2021-08-27') and date('2021-09-01') --modify this for dates
and event_ts >= timestamp'2021-08-18 20:00:00.000'
and ga_category in ('pf-experiments: HighlightToAction' )
and extras['experimentVariant'] is not null
group by 1,2,3
order by 1,2,3
