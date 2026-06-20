use tfl_db;
select * from tfl_commuter_trends;
select count(*) from tfl_commuter_trends;

-- Query 1: The "Chronic Bottleneck" Detector --

SELECT 
    Origin_Station,
    Transport_Mode,
    COUNT(*) AS total_journeys,
    AVG(Delay_Minutes) AS avg_delay,
    SUM(CASE WHEN Congestion_tier = 'Severe Friction' THEN 1 ELSE 0 END) AS severe_friction_count,
    ROUND(SUM(CASE WHEN Congestion_tier = 'Severe Friction' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS severe_friction_pct
FROM tfl_commuter_trends
GROUP BY Origin_Station, Transport_Mode
HAVING AVG(Delay_Minutes) > 10 
   AND (SUM(CASE WHEN Congestion_tier = 'Severe Friction' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) > 20
ORDER BY avg_delay DESC, severe_friction_pct DESC;


-- The "Overcharged Commuter" Vulnerability Finder --

SELECT 
    Journey_ID,
    Origin_Station,
    Destination_Station,
    Journey_Cost,
    (SELECT AVG(Journey_Cost) 
     FROM tfl_commuter_trends t2 
     WHERE t2.Origin_Station = t1.Origin_Station 
       AND t2.Destination_Station = t1.Destination_Station 
       AND t2.Journey_ID <> t1.Journey_ID) AS avg_cost_same_route,
    Journey_Cost - 
    (SELECT AVG(Journey_Cost) 
     FROM tfl_commuter_trends t2 
     WHERE t2.Origin_Station = t1.Origin_Station 
       AND t2.Destination_Station = t1.Destination_Station 
       AND t2.Journey_ID <> t1.Journey_ID) AS overcharge_amount
FROM tfl_commuter_trends t1
WHERE Journey_Cost > 1.5 * 
      (SELECT AVG(Journey_Cost) 
       FROM tfl_commuter_trends t2 
       WHERE t2.Origin_Station = t1.Origin_Station 
         AND t2.Destination_Station = t1.Destination_Station 
         AND t2.Journey_ID <> t1.Journey_ID)
ORDER BY overcharge_amount DESC;

-- The Peak vs. Off-Peak Stress Test --

SELECT 
    Origin_Station,
    Destination_Station,
    Transport_Mode,
    AVG(CASE WHEN Time_of_Day = 'Peak AM' THEN Total_Journey_Duration ELSE NULL END) AS avg_peak_am,
    AVG(CASE WHEN Time_of_Day = 'Off-Peak' THEN Total_Journey_Duration ELSE NULL END) AS avg_offpeak,
    ROUND(
        AVG(CASE WHEN Time_of_Day = 'Peak AM' THEN Total_Journey_Duration ELSE NULL END) 
        - AVG(CASE WHEN Time_of_Day = 'Off-Peak' THEN Total_Journey_Duration ELSE NULL END), 
    2) AS duration_difference
FROM tfl_commuter_trends
GROUP BY Origin_Station, Destination_Station, Transport_Mode
HAVING AVG(CASE WHEN Time_of_Day = 'Peak AM' THEN Total_Journey_Duration ELSE NULL END) 
       >= 2.0 * AVG(CASE WHEN Time_of_Day = 'Off-Peak' THEN Total_Journey_Duration ELSE NULL END)
ORDER BY duration_difference DESC;

-- Audit of Faulty Infrastructure (Ghost Tap Check) --

SELECT 
    Origin_Station,
    COUNT(*) AS total_journeys,
    SUM(CASE WHEN Total_Journey_Duration < 15 AND Journey_Cost >= 8.00 
             THEN 1 ELSE 0 END) AS suspicious_short_high_cost,
    ROUND(
        SUM(CASE WHEN Total_Journey_Duration < 15 AND Journey_Cost >= 8.00 
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
    2) AS ghost_tap_pct
FROM tfl_commuter_trends
GROUP BY Origin_Station
HAVING SUM(CASE WHEN Total_Journey_Duration < 15 AND Journey_Cost >= 8.00 THEN 1 ELSE 0 END) > 0
ORDER BY ghost_tap_pct DESC;