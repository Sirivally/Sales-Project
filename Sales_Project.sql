create database Project_Sales

--- examining the dataset 
select * from [dbo].[sales_data_sample]

-- checking unique values 
select distinct YEAR_ID from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample]
select distinct STATUS from [dbo].[sales_data_sample]
select distinct DEALSIZE from [dbo].[sales_data_sample]
select distinct TERRITORY from [dbo].[sales_data_sample]
select distinct country from [dbo].[sales_data_sample]
select distinct CUSTOMERNAME from [dbo].[sales_data_sample]

--- Analysis
--- Grouping by Productline to get to know which productline has most revenue i.e. that produactline has most sales
select Productline , sum(sales) as revenue from [dbo].[sales_data_sample] 
group by Productline 
order by revenue desc  

--- Grouping by year to get to know which year got most revenue i.e. on that year most sales were done
select YEAR_ID, sum(sales) as revenue from [dbo].[sales_data_sample] 
group by YEAR_ID 
order by revenue desc  

--- to know why year 2005 has low sales
select distinct MONTH_ID from [dbo].[sales_data_sample]
where YEAR_ID=2005  --- Because the dataset has only 5 months of information of year 2005  

--- Grouping by DEALSIZE to get to know which DEALSIZE got most revenue i.e. on that DEALSIZE most sales were done
select DEALSIZE, sum(sales) as revenue from [dbo].[sales_data_sample] 
group by DEALSIZE 
order by revenue desc 

--- Which month got best sales and in which year ? How much was earned that month ?
--- on that month how much is the revenue and how many ordernumbers were sold
select count(ordernumber) frequency , sum(sales) Revenue , month_id ,YEAR_ID from [dbo].[sales_data_sample]
group by MONTH_ID , YEAR_ID
order by revenue desc      --- November 2004 is the month which got most revenue

--- on which product the revenue was most in nov 2004
select PRODUCTLINE,sum(sales) revenue , count(ordernumber) frequency from [dbo].[sales_data_sample]
where YEAR_ID=2003 and Month_id=11
group by PRODUCTLINE
order by revenue desc   --- Classic cars were in sale most in nov 2003

--- Who is the best customer ( RFM ) 
drop table if exists #RFM
;with RFM as 
(  select customername,
       sum(sales) MonetaryValue, 
	   Avg(sales) AverageMonetaryValue,
	   count(ordernumber) frequency , 
	   max(orderdate) as Recent_Purchased_Date ,
	   (select max(orderdate) from [dbo].[sales_data_sample]) as max_order_date ,
	   Datediff(DD,max(orderdate),(select max(orderdate) from [dbo].[sales_data_sample]) )  as recency
   from [dbo].[sales_data_sample] 
   group by CUSTOMERNAME 
),
rfm_calc as 
(	select r.* ,
		 NTILE(4) OVER (ORDER BY recency desc) RFM_recency ,
		 NTILE(4) OVER (ORDER BY frequency) RFM_frequency ,
		 NTILE(4) OVER (ORDER BY MonetaryValue) RFM_monetary
	from RFM r
)
select c.* , RFM_recency+RFM_frequency+RFM_monetary as RFM_cell,
      cast(RFM_recency as varchar ) +cast(RFM_frequency as varchar) +cast(RFM_monetary as varchar) RFM_cell_string
INTO #RFM
from rfm_calc c

select CUSTOMERNAME,RFM_recency,RFM_frequency,RFM_monetary,
       case 
	     when RFM_Cell_string in (111,112,121,122,211,212,221) then 'Not Active'
		 when RFM_Cell_string in (123,132,133,144,244) then 'cannot lose'
		 when RFM_Cell_string in (222,223,232,233,234) then 'were potential churners' 
		 when RFM_Cell_string in (311,322,412,421) then 'New customers'
		 when RFM_Cell_string in (332,333,343,422,423) then 'Active'
		 when RFM_Cell_string in (344,433,434,443,444) then 'Loyal'
	   end rfm_status
from #RFM             --- here we can do this customer segmentation using RFM_cell too (like if value in greater than 8 then it has higher scope ) but it doesn't give accurate conclusion 

--- the products that are most sold
select distinct ordernumber , stuff(
	(select ','+PRODUCTCODE 
		 from [dbo].[sales_data_sample] p 
		  where ordernumber in 
			( select ordernumber 
			from 
			( select ordernumber , count(status) as no_of_items_shipped
			from [dbo].[sales_data_sample]
			where status='shipped'
			group by ordernumber
			) as m
			where no_of_items_shipped=2 ) 
			and p.ORDERNUMBER= s.ORDERNUMBER
			for xml path (''))
			,1,1,'') Productcodes
from [dbo].[sales_data_sample] s
order by 2 desc



select Distinct(priceeach) from [dbo].[sales_data_sample]
select count(priceeach) from [dbo].[sales_data_sample] where PRICEEACH>90 and PRICEEACH<=100
select distinct country from [dbo].[sales_data_sample] where YEAR_ID = 2005