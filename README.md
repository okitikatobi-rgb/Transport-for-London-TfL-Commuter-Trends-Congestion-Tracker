# Transport-for-London-TfL-Commuter-Trends-Congestion-Tracker

**An automated data engineering + rule-based AI + BI solution to analyze, clean, enrich, and visualize London’s transport network performance.**

## Overview

This project builds an end-to-end analytics platform that processes raw TfL tap-in/tap-out journey data, removes anomalies, applies a deterministic **non-ML expert system** to classify congestion severity, stores enriched data in MySQL, and delivers interactive executive dashboards in Power BI.

The solution identifies chronic bottlenecks, overcharged commuters, peak-hour stress, and quantifies the human impact of delays — turning raw journey logs into actionable commuter insights.

## Key Objectives

- Automate data cleaning and anomaly detection ("teleportation" and "ghost tap" filtering).
- Engineer meaningful transit metrics and apply explainable rule-based AI for congestion classification.
- Deliver advanced SQL analysis using only core relational techniques.
- Create dynamic, narrative-driven Power BI dashboards with what-if simulation capabilities.

## Tech Stack

- **Python**: pandas, SQLAlchemy, custom forward-chaining Logic Engine
- **Database**: MySQL
- **BI & Visualization**: Power BI (Power Query + DAX)
- **Core Techniques**: Heuristic filtering, Feature Engineering, Rule-Based Expert System, Correlated Subqueries, Conditional Aggregation, Time Intelligence

## Project Phases

### Phase 1: Python – Data Engineering & Non-ML AI System

**Automated pipeline** that turns messy raw data into clean, AI-enriched analytics-ready records.

**Key Steps:**

1. **Data Ingestion & Transformation**  
   Load `tfl_journeys_2024.csv` and standardize all datetime fields.

2. **Heuristic Anomaly Filtering (Teleportation Filter)**  
   Detect and quarantine impossible journeys (negative duration, unrealistically short trips across London, etc.).  
   Corrupted records are saved to `tfl_quarantined_data.csv` for auditing.

3. **Feature Engineering**  
   - `Total_Journey_Duration` (minutes)  
   - `Cost_Per_Minute` (value-for-money metric)  
   - `Time_of_Day` categories (Peak AM, Off-Peak, Peak PM)

4. **Non-ML AI Integration – Deterministic Logic Engine**  
   A forward-chaining expert system evaluates every journey against a knowledge base of transit rules.  
   Example rule:  
   `IF Time_of_Day = 'Peak AM' AND Delay_Minutes > 15 AND Total_Journey_Duration > 60 THEN Congestion_Tier = 'Severe Friction'`

   Output includes an explainable `Congestion_Tier` (Smooth → Minor Delays → High Friction → Severe Friction).

5. **Database Loading**  
   Uses SQLAlchemy to create the `tfl_commuter_trends` table and load the fully enriched dataset.

### Phase 2: SQL – Relational Transit & Efficiency Analysis

Advanced analytical queries **without CTEs or Window Functions**:

- **Chronic Bottleneck Detector** – HAVING clause to find Origin + Mode combinations with high average delay and severe friction percentage.
- **Overcharged Commuter Finder** – Correlated subquery to detect journeys with abnormally high fares (possible penalty fares).
- **Peak vs Off-Peak Stress Test** – Conditional aggregation showing routes where journey time doubles during rush hour.
- **Ghost Tap Audit** – Percentage of short journeys that still hit the daily fare cap (indicating tap-out reader failures).

### Phase 3: Power BI – Executive Dashboards & Congestion Tracking

Enterprise-grade interactive dashboard with:

- Time-series trends for passenger volume and delays
- Slicers for Transport Mode and Congestion Tier
- Geographic visualization of bottlenecks
- **Smart Narrative Generation** using DAX (dynamic sentences explaining current conditions)
- Conditional formatting on KPIs
- **What-If "Signal Upgrade" Parameter** – Simulate delay reductions (2–10 minutes) and instantly see recovered commuter man-hours

## Project Structure

- TfL-Commuter-Tracker/
- ├── data/
- │   ├── raw/
- │   ├── processed/
- │   └── quarantined/
- ├── src/
- │   ├── python/
- │   │   ├── ingestion.py
- │   │   ├── anomaly_filter.py
- │   │   ├── feature_engineering.py
- │   │   ├── logic_engine.py
- │   │   └── db_loader.py
- │   └── sql/
- │       ├── bottlenecks.sql
- │       ├── overcharged.sql
- │       └── ...
- ├── powerbi/
- │   └── TfL_Commuter_Trends.pbix
- ├── notebooks/
- ├── requirements.txt
- ├── README.md
- └── .gitignore
