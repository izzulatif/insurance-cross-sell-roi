-- Enable local infile if not already active
SET GLOBAL local_infile = 1;

-- 1. Load dim_customers first
LOAD DATA LOCAL INFILE 'D:/Personal Projects/Health-to-Auto Insurance Cross-Sell Funnel & Campaign ROI Simulator/dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'   -- (Use '\r\n' on Windows if you see line-ending warnings)
IGNORE 1 ROWS;

-- 2. Load dim_vehicles second
LOAD DATA LOCAL INFILE 'D:/Personal Projects/Health-to-Auto Insurance Cross-Sell Funnel & Campaign ROI Simulator/dim_vehicles.csv'
INTO TABLE dim_vehicles
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. Load fact_cross_sell_campaigns third
LOAD DATA LOCAL INFILE 'D:/Personal Projects/Health-to-Auto Insurance Cross-Sell Funnel & Campaign ROI Simulator/fact_cross_sell_campaigns.csv'
INTO TABLE fact_cross_sell_campaigns
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
