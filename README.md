# Revenue Metrics Analysis | SQL & Tableau

Gaming revenue and paying-user analysis using PostgreSQL and Tableau. Created as a final project for the GoIT Data Analytics course.

📊 [View the interactive Tableau dashboard](https://public.tableau.com/views/Final_Project_17867137332110/RevenueMetricsDashboard)

## Project goal

Prepare a monthly dataset to track revenue, paying users, churn, and reactivation, and explore the components of revenue change.

## Tools and techniques

- PostgreSQL: CTEs, joins, aggregations, CASE expressions, and date functions
- GENERATE_SERIES: building a calendar that includes months without payments
- LAG: comparing revenue with the previous calendar month
- Tableau: interactive dashboard and metric visualization

## Data sources

The SQL query uses two course database tables:

- `project.games_payments`: payment dates, user IDs, games, and revenue in USD
- `project.games_paid_users`: user language, age, and device information

The output contains one row per user, game, and calendar month, from the first payment month through the latest month in the dataset.

## Metrics prepared in SQL

| Metric | Definition |
| --- | --- |
| MRR | Monthly gaming revenue in USD |
| Paid user | User–game pair with positive revenue in the month |
| New paid user | User–game pair in its first payment month |
| New MRR | Revenue from new paid users |
| Churned user | User–game pair with revenue in the previous month and zero revenue in the current month |
| Churned revenue | Previous-month revenue lost through churn |
| Expansion MRR | Revenue increase for users paying in both consecutive months |
| Contraction MRR | Revenue decrease for users paying in both consecutive months |
| Reactivated user | Previously paying user–game pair returning after at least one month without payments |
| Reactivation MRR | Revenue from reactivated users |

## SQL workflow

1. Aggregate payments by month, user, and game.
2. Identify the first payment month for each user–game pair.
3. Generate a monthly calendar, including months without payments.
4. Join revenue and user attributes.
5. Calculate previous-month revenue using LAG.
6. Create revenue components and user-status indicators for Tableau.

## Repository contents

- [SQL script](sql/revenue_metrics.sql)
- [Interactive dashboard](https://public.tableau.com/views/Final_Project_17867137332110/RevenueMetricsDashboard)

## How to use

Run `sql/revenue_metrics.sql` in PostgreSQL with access to the two source tables and their required columns. Export the query result for analysis in Tableau.

Source data and database credentials are not included in this repository.

## Methodology notes

- MRR is the project label for monthly gaming revenue; it does not imply contractual subscription revenue.
- User indicators are calculated per user–game pair. Summing them across games may count the same person more than once.
- Churn means a month without payment immediately after a paying month; a user can reactivate later.
- The calendar ends at the latest payment month in the source data. Churn after that month cannot be observed.
- The user attributes table is expected to contain one row per user–game pair.

## Author

**Nataliia Snihova**

[Tableau Public](https://public.tableau.com/app/profile/nataliia.snihova/vizzes)

---

## Українською

Навчальний проєкт з аналізу доходу та платних користувачів ігор, виконаний за допомогою PostgreSQL і Tableau.

SQL-скрипт формує помісячний набір даних, враховує місяці без платежів і визначає нових платників, відтік, повернення користувачів, зростання та скорочення доходу.

Результати представлені в інтерактивному дашборді Tableau. Код демонструє роботу з CTE, об’єднанням таблиць, агрегуванням, календарем місяців і віконною функцією LAG.
