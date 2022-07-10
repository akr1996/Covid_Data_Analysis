with hotels as (
select * from dbo.[2018]
union 
select *
from dbo.[2019]
union
select *
from dbo.[2020])

select * from hotels as a
left join dbo.market_segment  as b on a.market_segment=b.market_segment 
left join dbo.meal_cost c on a.meal=c.meal

--select sum((stays_in_week_nights+stays_in_weekend_nights)*adr) as Revenue,arrival_date_year,hotel
--from hotels
--group by arrival_date_year,hotel
--order by Revenue,hotel 
