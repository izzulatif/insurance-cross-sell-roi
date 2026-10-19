CREATE DATABASE IF NOT EXISTS insurancesale_db;
USE insurancesale_db;

-- Optional: Drop tables in reverse dependency order if re-running the script
DROP TABLE IF EXISTS fact_cross_sell_campaigns;
DROP TABLE IF EXISTS dim_vehicles;
DROP TABLE IF EXISTS dim_customers;

-- 1. Parent Dimension Table: Customers
CREATE TABLE dim_customers (
    customer_id INT NOT NULL, 
    gender VARCHAR(10) NOT NULL, 
    age TINYINT UNSIGNED NOT NULL, 
    driving_license TINYINT(1) NOT NULL, 
    region_code SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (customer_id),
		INDEX idx_customer_region (region_code),
		INDEX idx_customer_age (age)
) ENGINE=InnoDB;

-- 2. Child Dimension Table: Vehicles
CREATE TABLE dim_vehicles (
    vehicle_id INT NOT NULL,
    customer_id INT NOT NULL,
    vehicle_age VARCHAR(15) NOT NULL,
    vehicle_age_order TINYINT UNSIGNED NOT NULL,
    vehicle_damage TINYINT(1) NOT NULL,
    previously_insured TINYINT(1) NOT NULL,
    PRIMARY KEY (vehicle_id),
    UNIQUE KEY uq_vehicles_customer (customer_id),
		INDEX idx_vehicle_funnel (previously_insured, vehicle_damage, vehicle_age_order),
    CONSTRAINT fk_vehicles_customer
        FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id)
) ENGINE=InnoDB;

CREATE TABLE fact_cross_sell_campaigns (
    campaign_id INT NOT NULL,
    customer_id INT NOT NULL,
    annual_premium DECIMAL(10, 2) NOT NULL,
    policy_sales_channel SMALLINT UNSIGNED NOT NULL,
    tenure_days SMALLINT UNSIGNED NOT NULL,
    response TINYINT(1) NOT NULL,
    PRIMARY KEY (campaign_id),
		INDEX idx_campaign_customer (customer_id),
		INDEX idx_campaign_channel (policy_sales_channel),
		INDEX idx_campaign_response (response),
    CONSTRAINT fk_campaigns_customer
        FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id)
) ENGINE=InnoDB;