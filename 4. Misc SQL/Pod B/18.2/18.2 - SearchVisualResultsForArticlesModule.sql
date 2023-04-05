--  18.2 Search Popup Modal with Visual Suggestions
--  Nov 29  -  Dec 10
--  pf-experiments: SearchVisualResultsForArticlesModule

select 
    beacon,
	extras [ 'experimentVariant' ] as var,
	ga_action,
	case
	    when(ga_action = 'inserted') then extras [ 'experimentVariant' ]
	    when(ga_action = 'impression') then ga_label
	    when(ga_action = 'click') then ga_label
	end as label,
	count(beacon) as num_action_performed
from statsdb.fact_trackingevent_events ev
where date(concat(ev.year,'-',ev.month,'-',ev.day)) between date('2021-11-29') and date('2021-12-10')
and ga_category = 'pf-experiments: SearchVisualResultsForArticlesModule'
and extras['experimentVariant'] is not null
and ga_action in ('inserted','impression','click')
group by 1,2,3,4
order by 1,2,3 