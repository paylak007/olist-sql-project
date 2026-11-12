# Olist E-Commerce SQL Analysis

SQL analysis of ~100K orders from the Brazilian e-commerce marketplace Olist (2016–2018).
Answers 10 business questions using JOINs, CTEs, HAVING, CASE and window functions.

## Key Findings

1. **97% of orders are delivered** (96,478 of 99,441), so revenue analysis uses delivered orders only.
2. **Late delivery hurts satisfaction:** average review score is 4.29 for on-time orders vs 2.57 for late ones (-1.72 points). About 8.1% of delivered orders arrive late.
3. **Geographic concentration:** São Paulo (SP) has 40,501 delivered orders, about 3.3x more than Rio de Janeiro (12,350).
4. **Seasonality:** revenue peaked in November 2017 (Black Friday, +52.4% MoM, 987K) and dropped 26.5% in December.
5. **Seller concentration:** the top seller earned 229K, and the top 5 sellers together earned about 1.04M.
6. **Product mix:** health_beauty, watches_gifts and bed_bath_table lead revenue; watches_gifts combines high volume (5,991 items) with a high average price (201).

## Skills Demonstrated
JOIN (up to 4 tables), GROUP BY / HAVING, CASE, CTE, ROW_NUMBER() OVER (PARTITION BY), LAG() OVER, date functions.

## Data
[Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
CSV files are not included due to size.

## Files
- `queries.sql`: all 10 queries with business questions

## Notes
- Review-based metrics (Q7) cover only orders that have a review.
- Monthly data for 2018 ends in August.

## Author
Paylak Janamyan