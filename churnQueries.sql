-- Customers who left
select *
FROM churn_data
WHERE churn = 'Yes';

-- Total number of churns
select count(*) AS total_churned_customers
FROM churn_data
WHERE churn = 'Yes';

-- Describing table data
PRAGMA table_info(churn_data);

-- Total customers
SELECT COUNT(*) AS total_customers
FROM churn_data;

-- Number of customers and segregation based on churn
SELECT Churn,
    COUNT(*) AS customer_count
FROM churn_data
GROUP BY Churn;

-- Churn rate
SELECT ROUND(
        100.0 * SUM(
            CASE
                WHEN Churn = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM churn_data;

-- Number of customers based on contracts(month-wise/year-wise)
SELECT Contract,
    COUNT(*) AS customers
FROM churn_data
GROUP BY Contract;

-- Number of churns based on contracts(month-wise/year-wise)
SELECT Contract,
    Churn,
    COUNT(*) AS total
FROM churn_data
GROUP BY Contract,
    Churn
ORDER BY Contract;

-- Number of churns based on gender.
select gender,
    COUNT(customerID) as total_customers,
    count(
        case
            when churn = 'Yes' then 1
        end
    ) as churned_customers
FROM churn_data
GROUP BY gender;

-- Churn rate based on gender. The data indicates that churn rate is almost similar but women are more likely to churn than men.
select gender,
    ROUND(
        100.0 * COUNT(
            case
                when churn = 'Yes' then 1
            end
        ) / COUNT(customerID),
        2
    ) AS churn_rate
FROM churn_data
GROUP BY gender;

-- Churn rate based on Contract. This query data indicates that customers with month-to-month contract are more likely to leave, their churn rate is 42.71 and very high comparatively.
select contract,
    churned_customers,
    customer_count,
    ROUND(100.0 * churned_customers / customer_count, 2) AS churn_rate
FROM (
        SELECT contract,
            count(Contract) AS customer_count,
            count(
                case
                    when churn = 'Yes' then 1
                end
            ) AS churned_customers
        FROM churn_data
        GROUP BY contract
    );

-- Average, maximum and minimum monthly-charges
SELECT ROUND(avg(MonthlyCharges), 2) as avg_monthlyCharge,
    max(MonthlyCharges) as max_MonthlyCharge,
    min(MonthlyCharges) as min_MonthlyCharge
from churn_data;

-- Churn rate based on monthly charges. High-paying(customers with high MonthlyCharges) are more likely to leave.
WITH avg_monthlycharges AS (
    SELECT AVG(MonthlyCharges) AS avg_charge
    FROM churn_data
),
customer_categories AS (
    SELECT CASE
            WHEN MonthlyCharges > (
                SELECT avg_charge
                FROM avg_monthlycharges
            ) THEN 'High Paying'
            ELSE 'Low Paying'
        END AS paying_category,
        Churn
    FROM churn_data
)
SELECT paying_category,
    COUNT(*) AS total_customers,
    COUNT(
        CASE
            WHEN Churn = 'Yes' THEN 1
        END
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(
            CASE
                WHEN Churn = 'Yes' THEN 1
            END
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_categories
GROUP BY paying_category;

-- The below query calculates churn-rate based on tenure, we can observe that there are high chances of new customers leaving whereas old customers are loyal and less likely to leave.
WITH customer_categories as (
    SELECT CASE
    WHEN tenure <= 12 then 'new'
    WHEN tenure >= 45 then 'long_term'
    else 'mid_term'
END as tenure_categories, churn from churn_data)
SELECT tenure_categories,
    COUNT(*) AS total_customers,
    COUNT(
        CASE
            WHEN churn = 'Yes' THEN 1
        END
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(
            CASE
                WHEN churn = 'Yes' THEN 1
            END
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_categories
GROUP BY tenure_categories;

-- The below query calculates churn-rate based on Payment method, we can observe that customers using electronic check have high churn rate.
WITH customer_categories as (
    SELECT CASE
    WHEN PaymentMethod = 'Electronic check' then 'Electronic_check'
    WHEN PaymentMethod = 'Credit card (automatic)' then 'Credit_card'
    WHEN PaymentMethod = 'Bank transfer (automatic)' then 'Bank_transfer'
    else 'mailed_check'
END as payment_categories, churn from churn_data)
SELECT payment_categories,
    COUNT(*) AS total_customers,
    COUNT(
        CASE
            WHEN churn = 'Yes' THEN 1
        END
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(
            CASE
                WHEN churn = 'Yes' THEN 1
            END
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_categories
GROUP BY payment_categories;

-- The below query calculates churn-rate based on InternetService categories, we can observe that customers having Fibre optics InternetService have high churn rate of 41.89%.
WITH customer_categories as (
    SELECT CASE
    WHEN InternetService = 'DSL' then 'DSL'
    WHEN InternetService = 'Fiber optic' then 'Fiber_optic'
    else 'No_internet'
END as InternetService_categories, churn from churn_data)
SELECT InternetService_categories,
    COUNT(*) AS total_customers,
    COUNT(
        CASE
            WHEN churn = 'Yes' THEN 1
        END
    ) AS churned_customers,
    ROUND(
        100.0 * COUNT(
            CASE
                WHEN churn = 'Yes' THEN 1
            END
        ) / COUNT(*),
        2
    ) AS churn_rate
FROM customer_categories
GROUP BY InternetService_categories;

-- The below query calculates revenue-loss-rate dure to churns, The revenue rate is 30.5% i.e., company loses 30.5% of the revenue.
WITH revenue_loss AS (
    SELECT 
        Churn,
        SUM(MonthlyCharges) AS revenue_loss
    FROM churn_data
    WHERE Churn = 'Yes'
),
total_revenue AS (
    SELECT 
        SUM(MonthlyCharges) AS total_revenue
    FROM churn_data
)
SELECT 
    rl.Churn,
    rl.revenue_loss,
    ROUND(
        100.0 * rl.revenue_loss / tr.total_revenue,
    2) AS revenue_loss_rate
FROM revenue_loss rl
CROSS JOIN total_revenue tr;