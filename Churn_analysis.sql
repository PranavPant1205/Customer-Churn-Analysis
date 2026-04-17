create database churn_analysis;
use churn_analysis;

create table churn_data(
customerId varchar(50),
gender varchar(20),
SeniorCitizen int,
Partner varchar(20),
Dependents varchar(20),
tenure int,
PhoneService varchar(20),
MultipleLines varchar(20),
InternetService varchar(20),
OnlineSecurity varchar(20),
OnlineBackup varchar(20),
DeviceProtection varchar(20),
TechSupport varchar(20),
StreamingTV varchar(20),
StreamingMovies varchar(30),
Contract varchar(30),
PaperlessBilling varchar(30),
PaymentMethod varchar(30),
MonthlyCharges Decimal(10,2),
TotalCharges Decimal(10,2),
Churn Varchar(10)	
);

-- calcualting churn percentage
select churn,count(*) as total_customers,
round(count(*)*100.0/(select count(*) from churn_data),2) as percentage
from churn_data
group by churn;

-- Calculating churn percentage by contract type
select contract,count(*) as total_customers,sum(case when Churn='Yes' then 1 else 0 end) as churned_customers,
round(sum(case when Churn='Yes' then 1 else 0 end)*100.0/count(*),2) as churn_percentage
from churn_data
group by contract 
order by churn_percentage desc;

-- Calculating churn percentage by paymentmethod
select PaymentMethod,count(*) as total_customers,sum(case when Churn='Yes' then 1 else 0 end) as churned_customers,
round(sum(case when Churn='Yes' then 1 else 0 end)*100.0/count(*),2) as churn_percentage
from churn_data
group by PaymentMethod
order by churn_percentage desc;

-- Churn By Tenure Group
select case 
		when tenure<12 then '0-1 Year'
        when tenure>=12 and tenure<24 then '1-2 Year'
        when tenure>=24 and tenure<48 then '2-4 Year'
        else '4+ Years'
		end as tenure_group,
        count(*) as total_cusotmers,
        sum(case when Churn='Yes' then 1 else 0 end) as churned_customers,
        round(sum(case when Churn='Yes' then 1 else 0 end)*100.0/count(*),2) as churn_percentage
        from churn_data
        group by tenure_group
        order by churn_percentage desc;

-- Intenet Service Impact on Churn
select InternetService,count(*) as total_customers,sum(case when Churn='Yes' then 1 else 0 end) as churned_customers,
round(sum(case when Churn='Yes' then 1 else 0 end)*100.0/count(*),2) as churn_percentage
from churn_data
group by InternetService
order by churn_percentage desc;	

-- Total Monthly Revenued from Churned Customers
SELECT 
    ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue_from_churned
FROM churn_data
WHERE Churn = 'Yes';


-- Identifying high risk segment
select count(*) as total_customers,
sum(case when Churn='Yes' then 1 else 0 end) as churned_customers,
round(sum(case when Churn='Yes' then 1 else 0 end)*100.0/count(*),2) as churn_percentage
from churn_data
where Contract='Month-to-month' and PaymentMethod='Electronic Check';


-- Monthly revenue from churned customers in high risk segment
select round(sum(MonthlyCharges),2) as monthly_revenue_at_risk
from churn_data
where Contract='Month-to-month' and PaymentMethod='Electronic Check' and Churn='Yes';

-- percentage of customers in high risk segment
select round(count(*)*100.0/(select count(*) from churn_data ),2) as high_risk_percentage
from churn_data 
where contract="Month-to-month"
and PaymentMethod="Electronic Check";

-- Comparing high risk vs remaining customers
SELECT 
    CASE 
        WHEN Contract = 'Month-to-month' 
        AND PaymentMethod = 'Electronic check'
        THEN 'High Risk Segment'
        ELSE 'Other Customers'
    END AS customer_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_percentage
FROM churn_data
GROUP BY customer_segment;