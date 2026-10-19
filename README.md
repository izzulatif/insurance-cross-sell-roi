# 🎯 **Health-to-Auto Insurance Cross-Sell Funnel & Campaign ROI Simulator**
Strategic Business Analytics, Machine Learning Propensity Modeling, and Interactive BI Forecasting

---

## 📌 **Executive Summary & Key Achievements**
This project transitions an actuarial perspective into a high-impact commercial data analytics framework. Utilizing a dataset of 381,109 health insurance policyholders, I built an end-to-end data pipeline (MySQL, Python, and Power BI) to optimize cross-sell telemarketing outreach for a secondary Auto Insurance product.
Financial Impact: Developed a Propensity-to-Buy model (ROC-AUC: 0.8461) that isolates 90.54% of all auto insurance buyers within the top 40% of scored leads, enabling marketing to eliminate 60% of cold outbound calls and protect profit margins.

Strategic SQL Insights: Pinpointed that 45.86% of leads immediately disqualify at Stage 3 of the sales funnel because they are already insured. By restricting outreach to uninsured drivers with prior vehicle damage, campaign conversion rates surge from 12.26% to 25.06%.

Interactive BI Simulation: Designed a dynamic "What-If" Campaign ROI Simulator in Power BI using advanced DAX parameters, allowing business stakeholders to instantly calculate expected campaign costs, net commission revenue, and overall ROI based on targeting thresholds.

---

## 💻 Tech Stack
Database: MySQL (Advanced CTEs, Window Functions, Database Views, NTILE Deciles, Normalization)

Programming: Python 3.10 (Pandas, Numpy, SciPy, Scikit-Learn, SQLAlchemy, PyMySQL)

Business Intelligence: Power BI (Dynamic DAX, Slicer Parameters, User-Experience Dashboard Design)

---

## 📊 Analytics Pipeline Architecture
Phase 1: ETL & Database Engineering (MySQL)
  * **Normalized a flat, uncleaned 381,109-row dataset into a star schema: dim_customers, dim_vehicles, and fact_cross_sell_campaigns.
  * **Standardized binary flags to int8 (1/0) for optimal storage, execution speed, and modeling compatibility.
  * **Managed secure bulk-data loading via optimized LOAD DATA LOCAL INFILE scripts, ensuring rapid, transactional database ingestion.

Phase 2: Advanced SQL Business Analytics
  * **Funnel Analytics: Leveraged CTEs, UNION ALL unpivoting, and window functions (FIRST_VALUE, LAG) to map out conversion rates and identify funnel drop-offs in a single-pass query.
  * **Sales Channel Efficiency: Evaluated 155 different sales channels using GROUP BY and HAVING COUNT(*) >= 1000 to identify high-volume revenue engines, using nested window aggregates (SUM(SUM()) OVER()) to compute market-share contribution.
  * **Customer Persona Matrix: Segmented demographics to isolate "Golden Goose" cohorts (e.g., Early Career drivers with vehicle damage converting at 33.26% overall).
  * **Database View: Saved the final business routing rules into a secure database view (vw_priority_cross_sell_leads).

Phase 3: Python Statistical Testing & Machine Learning
  * **Categorical Significance: Ran Chi-Square Tests of Independence paired with Cramér's V (Effect Size). Proved that prior vehicle damage (V = 0.3542) and lack of previous insurance (V = 0.3412) are the most powerful predictors of purchase behavior.
  * **Continuous Variable Significance: Conducted Welch's t-Test and Mann-Whitney U tests to prove that customer vintage/tenure is statistically insignificant (p ≈ 0.51) and should be dropped from modeling, while age and premium sizes are highly significant (p < 0.0001).
  * **Propensity Model: Trained an interpretable Logistic Regression model to output individual buy-propensities. Outliers in annual_premium were stabilized via logarithmic transformation (np.log1p), and non-linear age sweet-spots were captured via targeted binary age binning.
  * **Validation: Achieved an ROC-AUC of 0.8461 and an excellent Brier Score of 0.0884 (probability calibration error).
  * **Decile Analysis: Grouped the scored test set into 10 Propensity Deciles to export a Gain/Lift chart.

Phase 4: Interactive Power BI ROI Simulator
  * **Mapped out dynamic DAX measures incorporating campaign assumptions (RM 1,200 auto premium, RM 5.00 cost-per-call, 15% broker commission, RM 100 customer onboarding cost).
  * **Created a customized Line and Stacked Column Chart to overlay the rising curve of Cumulative Gain % against the falling line of Campaign ROI %, showing stakeholders the optimal campaign target limits.
