select distinct * from (
select ga_category
, ga_action
, extras['experimentVariant']
, sum(1) as "Num actions"
from statsdb.fact_trackingevent_events
where ga_category like '%ImageReactionModule%'
and date(concat(year,'-',month,'-',day)) between date('2021-08-18') and date('2021-08-19')
group by 1,2,3
order by 1,2,3
)
where ga_action in ('click','impression')
LIMIT 10;


/*
pathfinder module names
* ImageReactionModule
* MobileImageReactionModule
* DesktopArticleReactionModule
* MobileArticleReactionModule
* DesktopVideoReactionModule
* MobileVideoReactionModule
* DesktopInfoboxImageReactionModule
* MobileInfoboxImageReactionModule
*/
