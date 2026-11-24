-- 6.2 A - How does Match_02's score change between consecutive events?
WITH neighboring_scores AS (
    SELECT match_id,
           participation_id,
           joined_at,
           score,
           LAG(score) OVER match_order AS previous_score,
           LEAD(score) OVER match_order AS next_score
    FROM match_participants
    WINDOW match_order AS (PARTITION BY match_id ORDER BY joined_at, participation_id)
)
SELECT m.match_label,
       n.participation_id,
       n.joined_at,
       n.score,
       n.previous_score,
       n.next_score,
       n.score - n.previous_score AS score_delta
FROM neighboring_scores AS n
JOIN matches AS m ON m.match_id = n.match_id
WHERE n.match_id = 2
ORDER BY n.joined_at, n.participation_id;

-- 6.2 B - How does the timeout total track against a cap of 10 in 2023?
WITH daily_timeouts AS (
    SELECT joined_at::date AS event_day,
           COUNT(*) FILTER (
               WHERE participation_status = 'abandoned'
                 AND disconnect_reason = 'Network timeout'
           ) AS timeouts
    FROM match_participants
    WHERE joined_at >= DATE '2023-01-01' AND joined_at < DATE '2024-01-01'
    GROUP BY joined_at::date
), progress AS (
    SELECT event_day,
           timeouts,
           SUM(timeouts) OVER (
               ORDER BY event_day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS running_timeouts,
           ROUND(AVG(timeouts) OVER (
               ORDER BY event_day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           ), 2) AS avg_timeouts_7_recorded_days,
           10 AS timeout_cap
    FROM daily_timeouts
)
SELECT event_day,
       timeouts,
       running_timeouts,
       avg_timeouts_7_recorded_days,
       timeout_cap,
       timeout_cap - running_timeouts AS cap_remaining
FROM progress
ORDER BY event_day;

-- 6.2 C - Which matches have at least 90 days between consecutive events?
WITH event_pairs AS (
    SELECT match_id,
           participation_id,
           joined_at,
           LAG(joined_at) OVER (
               PARTITION BY match_id ORDER BY joined_at, participation_id
           ) AS previous_joined_at
    FROM match_participants
), gaps AS (
    SELECT match_id,
           participation_id,
           previous_joined_at,
           joined_at,
           joined_at - previous_joined_at AS gap_length
    FROM event_pairs
)
SELECT m.match_label, g.previous_joined_at, g.joined_at, g.gap_length
FROM gaps AS g
JOIN matches AS m ON m.match_id = g.match_id
WHERE g.gap_length >= INTERVAL '90 days'
ORDER BY g.gap_length DESC, g.match_id, g.participation_id;
