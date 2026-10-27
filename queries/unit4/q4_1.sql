-- 4.1a (aggregates): What are the score statistics and distinct player count?
SELECT COUNT(score) AS score_count,
       SUM(score) AS total_score,
       ROUND(AVG(score), 2) AS avg_score,
       MIN(score) AS min_score,
       MAX(score) AS max_score,
       COUNT(DISTINCT player_id) AS players
FROM match_participants;

-- 4.1b (GROUP BY): How many events and what average score does each producer have?
SELECT m.match_id,
       COUNT(mp.participation_id) AS events,
       ROUND(AVG(mp.score), 2) AS avg_score
FROM matches AS m
LEFT JOIN match_participants AS mp ON mp.match_id = m.match_id
GROUP BY m.match_id
ORDER BY events DESC, m.match_id;

-- 4.1c (HAVING): What are the failure rates for producers with at least 10 events?
SELECT match_id,
       COUNT(*) AS events,
       ROUND(100.0 * AVG(CASE WHEN participation_status = 'abandoned'
                              AND disconnect_reason = 'Network timeout'
                             THEN 1 ELSE 0 END), 2) AS failure_pct
FROM match_participants
GROUP BY match_id
HAVING COUNT(*) >= 10
ORDER BY failure_pct DESC, match_id;

-- 4.1d (two dimensions): How does performance vary by server region and ranked status?
SELECT m.server_region,
       m.is_ranked,
       COUNT(*) AS events,
       ROUND(AVG(mp.score), 2) AS avg_score,
       ROUND(100.0 * AVG(CASE WHEN mp.participation_status = 'abandoned'
                              AND mp.disconnect_reason = 'Network timeout'
                             THEN 1 ELSE 0 END), 2) AS failure_pct
FROM match_participants AS mp
JOIN matches AS m ON m.match_id = mp.match_id
GROUP BY m.server_region, m.is_ranked
ORDER BY m.server_region, m.is_ranked DESC;