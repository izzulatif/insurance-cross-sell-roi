USE insurancesale_db;

-- Query 1 - The Cross-Sell Qualifying & Conversion Funnel
WITH funnel_counts AS (
	SELECT
		COUNT(*) AS stage_1_total,
        SUM(CASE WHEN c.driving_license = 1 THEN 1 ELSE 0 END) AS stage_2_licensed,
        SUM(CASE WHEN c.driving_license = 1 AND v.previously_insured = 0 THEN 1 ELSE 0 END) AS stage_3_uninsured,
        SUM(CASE WHEN c.driving_license = 1 AND v.previously_insured = 0 AND v.vehicle_damage = 1 THEN 1 ELSE 0 END) AS stage_4_damaged,
        SUM(CASE WHEN c.driving_license = 1 AND v.previously_insured = 0 AND v.vehicle_damage = 1 AND f.response = 1 THEN 1 ELSE 0 END) AS stage_5_converted
    FROM dim_customers c
		LEFT JOIN dim_vehicles v ON c.customer_id = v.customer_id
        LEFT JOIN fact_cross_sell_campaigns f ON c.customer_id = f.customer_id
),

funnel_unpivoted AS (
	SELECT
		1 AS stage_order,
        '1. Total Health Policyholders' AS funnel_stage,
        stage_1_total AS customer_count
	FROM funnel_counts
    
    UNION ALL
    
    SELECT
		2 AS stage_order,
        '2. Licensed Drivers' AS funnel_stage,
        stage_2_licensed AS customer_count
	FROM funnel_counts
    
    UNION ALL
    
    SELECT
		3 AS stage_order,
        '3. Uninsured Vehicle Owners' AS funnel_stage,
        stage_3_uninsured AS customer_count
	FROM funnel_counts
    
    UNION ALL
    
     SELECT
		4 AS stage_order,
        '4. Prior Vehicle Damage — High Intent' AS funnel_stage,
        stage_4_damaged AS customer_count
	FROM funnel_counts
    
    UNION ALL
    
     SELECT
		5 AS stage_order,
        '5. Converted Buyers' AS funnel_stage,
        stage_5_converted AS customer_count
	FROM funnel_counts
)

SELECT
	stage_order, 
    funnel_stage, 
    customer_count,
    ROUND(customer_count * 100.0 / FIRST_VALUE(customer_count) OVER (ORDER BY stage_order), 2) AS pct_of_total_base,
    ROUND(customer_count * 100.0 / LAG(customer_count) OVER (ORDER BY stage_order), 2) AS stage_to_stage_conversion_pct,
    ROUND(100.0 - (customer_count * 100.0 / LAG(customer_count) OVER (ORDER BY stage_order)), 2) AS stage_drop_off_pct
FROM funnel_unpivoted
;

-- Query 2 - Sales Channel & Region Efficiency Ranking
SELECT
	f.policy_sales_channel,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN c.driving_license = 1 AND v.previously_insured = 0 AND v.vehicle_damage = 1 THEN 1 ELSE 0 END) AS qualified_high_intent_leads,
    SUM(f.response) AS total_conversions,
    ROUND(AVG(f.response) * 100, 2) AS overall_conversion_rate_pct,
    ROUND(
		SUM(
			CASE WHEN c.driving_license = 1 AND v.previously_insured = 0 AND v.vehicle_damage = 1 AND f.response = 1 THEN 1 ELSE 0 END) * 100.0
			/ NULLIF(SUM(CASE WHEN c.driving_license = 1 AND v.previously_insured = 0 AND v.vehicle_damage = 1 THEN 1 ELSE 0 END), 0), 2) 
	AS qualified_conversion_rate_pct,
    ROUND(AVG(f.annual_premium), 2) AS avg_health_premium,
    DENSE_RANK() OVER (ORDER BY AVG(f.response) * 100 DESC) AS conversion_rank,
    ROUND(SUM(f.response) * 100.0 / SUM(SUM(f.response)) OVER (), 2) AS pct_of_total_company_conversions
FROM dim_customers c
	LEFT JOIN dim_vehicles v ON c.customer_id = v.customer_id
	LEFT JOIN fact_cross_sell_campaigns f ON c.customer_id = f.customer_id
GROUP BY f.policy_sales_channel
HAVING COUNT(*) >= 1000
ORDER BY conversion_rank ASC LIMIT 15;


-- Query 3 - Premium Tiering & Customer Vintage Analysis
WITH customer_deciles AS (
	SELECT 
		c.driving_license, 
        v.previously_insured, 
        v.vehicle_damage, 
        f.annual_premium, 
        f.tenure_days, 
        f.response,
        NTILE(10) OVER (ORDER BY f.annual_premium ASC) AS premium_decile
	FROM dim_customers c
		LEFT JOIN dim_vehicles v ON c.customer_id = v.customer_id
        LEFT JOIN fact_cross_sell_campaigns f ON c.customer_id = f.customer_id
)

SELECT
	premium_decile,
    COUNT(*) AS customer_count,
    MIN(annual_premium) AS min_premium,
    MAX(annual_premium) AS max_premium,
    ROUND(AVG(annual_premium), 2) AS avg_premium,
    ROUND(AVG(tenure_days), 1) AS avg_tenure_days,
    ROUND(AVG(CASE WHEN driving_license = 1 AND previously_insured = 0 AND vehicle_damage = 1 THEN 1 ELSE 0 END) * 100, 2) AS qualified_lead_pct,
    ROUND(AVG(response) * 100, 2) AS conversion_rate_pct
FROM customer_deciles
GROUP BY premium_decile
ORDER BY premium_decile ASC;

-- Query 4 - Target Customer Persona Matrix
SELECT
	CASE 
		WHEN c.age < 30 THEN '1. Young Drivers (20-29)'
        WHEN c.age BETWEEN 30 AND 44 THEN '2. Early Career / Family (30-44)'
        WHEN c.age BETWEEN 45 AND 59 THEN '3. Peak Earning / Mid-Life (45-59)'
        ELSE '4. Seniors (60+)' END 
	AS age_group,
    v.vehicle_age,
    CASE WHEN v.vehicle_damage = 1 THEN 'Damaged' ELSE 'No Damage' END AS damage_status,
    COUNT(*) AS uninsured_lead_count,
    SUM(f.response) AS conversions,
    ROUND(AVG(f.response) * 100, 2) AS persona_conversion_rate_pct,
    ROUND(AVG(f.annual_premium), 2) AS avg_health_premium,
    ROUND(SUM(f.response) * 100.0 / SUM(SUM(f.response)) OVER (), 2) AS pct_of_all_uninsured_conversions
FROM dim_customers c
	LEFT JOIN dim_vehicles v ON c.customer_id = v.customer_id
	LEFT JOIN fact_cross_sell_campaigns f ON c.customer_id = f.customer_id
WHERE c.driving_license = 1 AND v.previously_insured = 0
GROUP BY age_group, v.vehicle_age, damage_status
ORDER BY persona_conversion_rate_pct DESC
;

-- Query 5 - Creating the Reusable SQL VIEW for High-Value Untapped Leads
-- PART A: Create the Reusable Priority Lead Scoring & Routing View
-- Filters strictly for Stage 4 High-Intent Leads (181,975 customers)
CREATE OR REPLACE VIEW vw_priority_cross_sell_leads AS
	SELECT 
		c.customer_id,
		c.gender,
		c.age,
		CASE
			WHEN c.age < 30 THEN '1. Young Drivers (20-29)'
			WHEN c.age BETWEEN 30 AND 44 THEN '2. Early Career / Family (30-44)'
			WHEN c.age BETWEEN 45 AND 59 THEN '3. Peak Earning / Mid-Life (45-59)'
			ELSE '4. Seniors (60+)'
		END AS age_group,
		c.region_code,
		v.vehicle_age,
		f.policy_sales_channel,
		f.annual_premium,
		f.tenure_days,
		f.response,
		-- Actionable Lead Routing Tier based on Queries 1-4 findings:
		CASE
			WHEN c.age BETWEEN 30 AND 59
			 AND f.policy_sales_channel IN (26, 124, 154, 155, 156, 157, 163, 122, 25)
				THEN 'Tier 1: Priority Agent Call (30-59 Core Channels)'
			WHEN c.age >= 30
				THEN 'Tier 2: Secondary Outbound (Other 30-59 & Seniors)'
			ELSE 'Tier 3: Low-Cost Digital Nurture (Under 30)'
		END AS lead_priority_tier
	FROM dim_customers c
		INNER JOIN dim_vehicles v ON c.customer_id = v.customer_id
		INNER JOIN fact_cross_sell_campaigns f ON c.customer_id = f.customer_id
	WHERE c.driving_license = 1
	  AND v.previously_insured = 0
	  AND v.vehicle_damage = 1;
      
-- PART B: Query the View to Size the Untapped Revenue Opportunity by Tier
SELECT
    lead_priority_tier,
    COUNT(*) AS total_qualified_leads,
    SUM(response) AS historical_conversions,
    SUM(CASE WHEN response = 0 THEN 1 ELSE 0 END) AS untapped_opportunity_leads,
    ROUND(AVG(response) * 100, 2) AS tier_conversion_rate_pct,
    ROUND(AVG(annual_premium), 2) AS avg_health_premium,
    ROUND(SUM(response) * 100.0 / SUM(SUM(response)) OVER (), 2) AS pct_of_stage4_conversions
FROM vw_priority_cross_sell_leads
GROUP BY lead_priority_tier
ORDER BY lead_priority_tier ASC;