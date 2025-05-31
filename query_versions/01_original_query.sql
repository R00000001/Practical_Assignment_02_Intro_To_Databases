-- згенеровано ChatGPT
-- explain analyze -- скан
SELECT months.yearmonth,
  (
    SELECT COUNT(*)
    FROM major_crime_indicators AS sub_v
    WHERE DATE_FORMAT(sub_v.`OCC_DATE`, '%Y-%m') = months.yearmonth -- фільтрація по місяцю
      AND sub_v.`MCI_CATEGORY` IN ('Assault', 'Robbery', 'Homicide', 'Sexual Assault') -- фільтр по важким злочину
  ) AS violent_crimes, 

  (
    SELECT COUNT(*)
    FROM major_crime_indicators AS sub_nv
    WHERE DATE_FORMAT(sub_nv.`OCC_DATE`, '%Y-%m') = months.yearmonth -- фільтрація по місяцю
      AND sub_nv.`MCI_CATEGORY` NOT IN ('Assault', 'Robbery', 'Homicide', 'Sexual Assault') -- фільтр по не важким злочинам
  ) AS nonviolent_crimes,

  (
    SELECT
      ROUND(
        CASE
          WHEN
            (
              SELECT COUNT(*)
              FROM major_crime_indicators AS sub_nv2
              WHERE DATE_FORMAT(sub_nv2.`OCC_DATE`, '%Y-%m') = months.yearmonth
                AND sub_nv2.`MCI_CATEGORY` NOT IN ('Assault', 'Robbery', 'Homicide', 'Sexual Assault')
            ) = 0 -- до наступного рядка просто перевірка на кількість не важких злочинів, якщо їз нема, то замість 0 ставимо null (не ділимо на 0)
          THEN NULL
          ELSE
            (
              SELECT COUNT(*)
              FROM major_crime_indicators AS sub_v2
              WHERE DATE_FORMAT(sub_v2.`OCC_DATE`, '%Y-%m') = months.yearmonth
                AND sub_v2.`MCI_CATEGORY` IN ('Assault', 'Robbery', 'Homicide', 'Sexual Assault')
            ) / -- рахуємо важкі злочини і ділимо їх на не важкі
            (
              SELECT COUNT(*)
              FROM major_crime_indicators AS sub_nv3
              WHERE DATE_FORMAT(sub_nv3.`OCC_DATE`, '%Y-%m') = months.yearmonth
                AND sub_nv3.`MCI_CATEGORY` NOT IN ('Assault', 'Robbery', 'Homicide', 'Sexual Assault')
            )
        END, 4 -- тут жахливо видно, але тут просто округлюємо до 4 значень після коми
      )
  ) AS violent_to_nonviolent_ratio -- просто еліас

FROM
  (
    SELECT DISTINCT DATE_FORMAT(`OCC_DATE`, '%Y-%m') AS yearmonth -- конвертую формати без дублікатів
    FROM major_crime_indicators
    WHERE `OCC_DATE` BETWEEN '2018-01-01' AND '2019-01-01' -- ось тут підкрутити дати якщо дуже довгий рантайм
  ) AS months -- еліас

ORDER BY months.yearmonth; -- сортуємо починаючи від найстарішого
