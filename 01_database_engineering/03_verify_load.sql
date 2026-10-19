USE insurancesale_db;

-- 1. Check row counts across all 3 tables (All 3 should equal 381,109)
SELECT 'dim_customers' AS table_name, COUNT(*) AS total_rows FROM dim_customers
UNION ALL
SELECT 'dim_vehicles', COUNT(*) FROM dim_vehicles
UNION ALL
SELECT 'fact_cross_sell_campaigns', COUNT(*) FROM fact_cross_sell_campaigns;

-- 2. Verify relational join integrity and preview the first 5 joined rows
SELECT 
    c.customer_id,
    c.gender,
    c.age,
    v.vehicle_age,
    v.vehicle_damage,
    v.previously_insured,
    f.annual_premium,
    f.response
FROM dim_customers c
INNER JOIN dim_vehicles v ON c.customer_id = v.customer_id
INNER JOIN fact_cross_sell_campaigns f ON c.customer_id = f.customer_id
LIMIT 5;
