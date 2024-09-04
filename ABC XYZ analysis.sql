
with tab as (
  SELECT 
   dr_ndrugs as product,
   COALESCE(SUM(dr_kol),0) as quantity,
   COALESCE(SUM(dr_kol*dr_croz-dr_sdisc), 0) as revenue,
   COALESCE(SUM(dr_kol*(dr_croz-dr_czak)-dr_sdisc), 0) as profit
FROM sales
GROUP by dr_ndrugs
  ),
xyz_sales as (
  SELECT
   dr_ndrugs as product,
   to_char(dr_dat, 'YYYY-WW') as yw,
   COALESCE(SUM(dr_kol),0) as sales
FROM sales s 
GROUP BY product, yw
),
xyz_analysis as(
  SELECT 
   product, 
   CASE 
     WHEN STDDEV_SAMP(sales)/AVG(sales)>0.25 THEN 'Z'
     WHEN STDDEV_SAMP(sales)/AVG(sales)>0.10 THEN 'Y'
     ELSE 'X'
  END xyz_sales
  FROM xyz_sales
  GROUP BY product 
  HAVING COUNT(DISTINCT yw)>=4
)
SELECT t.product,
CASE 
  when SUM(quantity) OVER (order by quantity DESC)/sum(quantity) over () <= 0.8 THEN 'A'
  when SUM(quantity) OVER (order by quantity DESC)/sum(quantity) over () <= 0.95 THEN 'B'
  ELSE 'C'
  end amount_abc,
CASE 
  when sum(profit) OVER (ORDER by profit DESC)/sum(profit) OVER () <= 0.8 THEN 'A'
  when sum(profit) OVER (ORDER by profit DESC)/sum(profit) OVER () <= 0.95 THEN 'B'
  ELSE 'C'
  end profit_abc, 
CASE 
  when sum(revenue) over (order by revenue DESC)/sum(revenue) over () <=0.8 then 'A'
  when sum(revenue) over (order by revenue DESC)/sum(revenue) over () <=0.95 then 'B'
  ELSE 'C'
  end revenue_abc,
xyz.xyz_sales
FROM tab t 
LEFT JOIN
xyz_analysis xyz 
ON xyz.product=t.product
ORDER BY 1