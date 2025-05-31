-- explain analyze -- скан
with crime_counts as (
  select
    date_format(`OCC_DATE`, '%Y-%m') as yearmonth, -- отримуємо дати і конвертуємо в формат
    case
      when `MCI_CATEGORY` in ('Assault', 'Robbery', 'Homicide', 'Sexual Assault') then 'violent'
      else 'nonviolent' 
    end as crime_type -- розділяємо на типи злочинів та додаємо еліас
  from major_crime_indicators
  where `OCC_DATE` between '2018-01-01' and '2019-01-01' -- фільтр по часу
) 

select
  yearmonth,
  sum(case when crime_type = 'violent' then 1 else 0 end) as violent_crimes, -- рахує кількість рекордів через кейси
  sum(case when crime_type = 'nonviolent' then 1 else 0 end) as nonviolent_crimes, -- раїує кількість рекордів через кейси
  round(
    case
      when sum(case when crime_type = 'nonviolent' then 1 else 0 end) > 0 -- більше 0 і не 0 (для ділення)
      then sum(case when crime_type = 'violent' then 1 else 0 end) / sum(case when crime_type = 'nonviolent' then 1 else 0 end)
      else 0 -- якщо перша умова не виконана, то просто ставимо 0, щоб не ламати кверю діленням на 0
    end, 4 -- округлення до 4 значень після коми
  ) as violent_to_nonviolent_ratio
from crime_counts
group by yearmonth 
order by yearmonth;
