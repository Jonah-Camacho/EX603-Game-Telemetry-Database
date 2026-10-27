-- 4.2A (conditional aggregation): How many events and failures does each producer have?
SELECT m.match_id,
       COUNT(mp.participation_id) AS events,
       SUM(CASE WHEN mp.participation_status = 'abandoned'
                 AND mp.disconnect_reason = 'Network timeout'
                THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * SUM(CASE WHEN mp.participation_status = 'abandoned'
                              AND mp.disconnect_reason = 'Network timeout'
                             THEN 1 ELSE 0 END)
             / NULLIF(COUNT(mp.participation_id), 0), 2) AS failure_pct
FROM matches AS m
LEFT JOIN match_participants AS mp ON mp.match_id = m.match_id
GROUP BY m.match_id
ORDER BY failures DESC, m.match_id;

-- 4.2B (ROLLUP): What are the regional subtotals and platform grand total?
SELECT CASE WHEN GROUPING(m.server_region) = 1
            THEN 'ALL REGIONS' ELSE m.server_region END AS region,
       COUNT(*) AS events,
       SUM(CASE WHEN mp.participation_status = 'abandoned'
                 AND mp.disconnect_reason = 'Network timeout'
                THEN 1 ELSE 0 END) AS failures,
       ROUND(100.0 * AVG(CASE WHEN mp.participation_status = 'abandoned'
                              AND mp.disconnect_reason = 'Network timeout'
                             THEN 1 ELSE 0 END), 2) AS failure_pct
FROM match_participants AS mp
JOIN matches AS m ON m.match_id = mp.match_id
GROUP BY ROLLUP (m.server_region)
ORDER BY GROUPING(m.server_region), m.server_region;

-- 4.2C (CTE and second aggregation): What is the baseline for producers with 10+ events?
WITH producer_totals AS (
    SELECT match_id,
           COUNT(*) AS events,
           SUM(CASE WHEN participation_status = 'abandoned'
                     AND disconnect_reason = 'Network timeout'
                    THEN 1 ELSE 0 END) AS failures
    FROM match_participants
    GROUP BY match_id
)
SELECT COUNT(*) AS producers,
       SUM(events) AS events,
       SUM(failures) AS failures,
       ROUND(100.0 * SUM(failures)
             / NULLIF(SUM(events), 0), 2) AS baseline_pct
FROM producer_totals
WHERE events >= 10;