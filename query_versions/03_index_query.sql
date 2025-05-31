-- create index index_occdate_mci on major_crime_indicators (`OCC_DATE`, `MCI_CATEGORY`); -- створюємо каверінг індекс
-- explain analyze -- скан
with crime_counts as (
  select
    date_format(`OCC_DATE`, '%Y-%m') as yearmonth,
    case
      when `MCI_CATEGORY` in ('Assault', 'Robbery', 'Homicide', 'Sexual Assault') then 'violent'
      else 'nonviolent'
    end as crime_type
  from major_crime_indicators use index (index_occdate_mci) -- ось тут використовуємо індекс
  where `OCC_DATE` between '2018-01-01' and '2019-01-01'
) -- те саме що і в минулій версії

select -- те саме що і в минулій версії
  yearmonth,
  sum(case when crime_type = 'violent' then 1 else 0 end) as violent_crimes,
  sum(case when crime_type = 'nonviolent' then 1 else 0 end) as nonviolent_crimes,
  round(
    case
      when sum(case when crime_type = 'nonviolent' then 1 else 0 end) > 0
      then sum(case when crime_type = 'violent' then 1 else 0 end) / sum(case when crime_type = 'nonviolent' then 1 else 0 end)
      else 0
    end, 4
  ) as violent_to_nonviolent_ratio
from crime_counts
group by yearmonth
order by yearmonth;
