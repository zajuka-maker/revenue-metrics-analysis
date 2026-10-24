-- Revenue Metrics Analysis
-- SQL dialect: PostgreSQL
-- Output: one row per user, game, and calendar month,
-- from the first payment month through the latest month in the dataset.
-- Monthly gaming revenue is labeled MRR for this project.

WITH user_monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', gp.payment_date)::date AS payment_month,
        gp.user_id,
        gp.game_name,
        SUM(gp.revenue_amount_usd) AS monthly_revenue
    FROM project.games_payments AS gp
    GROUP BY
        DATE_TRUNC('month', gp.payment_date)::date,
        gp.user_id,
        gp.game_name
),

data_range AS (
    SELECT
        MAX(payment_month) AS max_month
    FROM user_monthly_revenue
),

user_first_payment AS (
    SELECT
        user_id,
        game_name,
        MIN(payment_month) AS first_payment_month
    FROM user_monthly_revenue
    GROUP BY
        user_id,
        game_name
),

-- Include months without payments to identify churn and reactivation.
user_month_calendar AS (
    SELECT
        ufp.user_id,
        ufp.game_name,
        ufp.first_payment_month,
        GENERATE_SERIES(
            ufp.first_payment_month,
            dr.max_month,
            INTERVAL '1 month'
        )::date AS payment_month
    FROM user_first_payment AS ufp
    CROSS JOIN data_range AS dr
),

revenue_calendar AS (
    SELECT
        umc.payment_month,
        umc.user_id,
        umc.game_name,
        umc.first_payment_month,
        COALESCE(umr.monthly_revenue, 0) AS monthly_revenue,
        gpu.language,
        gpu.age,
        gpu.has_older_device_model
    FROM user_month_calendar AS umc
    LEFT JOIN user_monthly_revenue AS umr
        ON umc.user_id = umr.user_id
        AND umc.game_name = umr.game_name
        AND umc.payment_month = umr.payment_month
    LEFT JOIN project.games_paid_users AS gpu
        ON umc.user_id = gpu.user_id
        AND umc.game_name = gpu.game_name
),

revenue_with_previous_month AS (
    SELECT
        *,
        LAG(monthly_revenue, 1, 0) OVER (
            PARTITION BY user_id, game_name
            ORDER BY payment_month
        ) AS previous_month_revenue
    FROM revenue_calendar
)

SELECT
    payment_month,
    user_id,
    game_name,
    language,
    age,
    has_older_device_model,
    first_payment_month,

    monthly_revenue AS mrr,
    previous_month_revenue AS previous_month_mrr,

    CASE
        WHEN monthly_revenue > 0
        THEN 1
        ELSE 0
    END AS paid_user,

    CASE
        WHEN previous_month_revenue > 0
        THEN 1
        ELSE 0
    END AS previous_month_paid_user,

    CASE
        WHEN payment_month = first_payment_month
             AND monthly_revenue > 0
        THEN 1
        ELSE 0
    END AS new_paid_user,

    CASE
        WHEN payment_month = first_payment_month
             AND monthly_revenue > 0
        THEN monthly_revenue
        ELSE 0
    END AS new_mrr,

    CASE
        WHEN monthly_revenue = 0
             AND previous_month_revenue > 0
        THEN 1
        ELSE 0
    END AS churned_user,

    CASE
        WHEN monthly_revenue = 0
             AND previous_month_revenue > 0
        THEN previous_month_revenue
        ELSE 0
    END AS churned_revenue,

    CASE
        WHEN monthly_revenue > previous_month_revenue
             AND previous_month_revenue > 0
        THEN monthly_revenue - previous_month_revenue
        ELSE 0
    END AS expansion_mrr,

    CASE
        WHEN monthly_revenue < previous_month_revenue
             AND monthly_revenue > 0
        THEN previous_month_revenue - monthly_revenue
        ELSE 0
    END AS contraction_mrr,

    CASE
        WHEN payment_month > first_payment_month
             AND monthly_revenue > 0
             AND previous_month_revenue = 0
        THEN 1
        ELSE 0
    END AS reactivated_user,

    CASE
        WHEN payment_month > first_payment_month
             AND monthly_revenue > 0
             AND previous_month_revenue = 0
        THEN monthly_revenue
        ELSE 0
    END AS reactivation_mrr

FROM revenue_with_previous_month
ORDER BY
    payment_month,
    user_id;
