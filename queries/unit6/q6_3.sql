-- 6.3 A - What are the three highest-scoring events for each match?
-- A tie for third goes to the lower participation ID so the list stays at three.
WITH ranked_events AS (
    SELECT match_id,
           participation_id,
           score,
           ROW_NUMBER() OVER score_order AS score_rank,
           FIRST_VALUE(score) OVER score_order AS best_score
    FROM match_participants
    WINDOW score_order AS (PARTITION BY match_id ORDER BY score DESC, participation_id)
)
SELECT m.match_label, r.score_rank, r.participation_id, r.score, r.best_score
FROM ranked_events AS r
JOIN matches AS m ON m.match_id = r.match_id
WHERE r.score_rank <= 3
ORDER BY r.match_id, r.score_rank;

-- 6.3 B - How does the confirmed network timeout rate change each month?
WITH monthly_counts AS (
    SELECT DATE_TRUNC('month', joined_at) AS month_start,
           COUNT(*) AS events,
           COUNT(*) FILTER (
               WHERE participation_status = 'abandoned'
                 AND disconnect_reason = 'Network timeout'
           ) AS timeouts
    FROM match_participants
    GROUP BY DATE_TRUNC('month', joined_at)
), calendar AS (
    SELECT GENERATE_SERIES(MIN(month_start), MAX(month_start), INTERVAL '1 month')
           AS month_start
    FROM monthly_counts
), monthly_rates AS (
    SELECT c.month_start,
           COALESCE(m.events, 0) AS events,
           COALESCE(m.timeouts, 0) AS timeouts,
           100.0 * m.timeouts / NULLIF(m.events, 0) AS timeout_pct
    FROM calendar AS c
    LEFT JOIN monthly_counts AS m ON m.month_start = c.month_start
), comparison AS (
    SELECT month_start,
           events,
           timeouts,
           timeout_pct,
           LAG(timeout_pct) OVER (ORDER BY month_start) AS previous_timeout_pct
    FROM monthly_rates
)
SELECT month_start::date AS month,
       events,
       timeouts,
       ROUND(timeout_pct, 2) AS timeout_pct,
       ROUND(previous_timeout_pct, 2) AS previous_timeout_pct,
       ROUND(timeout_pct - previous_timeout_pct, 2) AS change_pp,
       ROUND(100.0 * (timeout_pct - previous_timeout_pct)
             / NULLIF(previous_timeout_pct, 0), 2) AS change_pct,
       events = 0 AS missing_month
FROM comparison
ORDER BY month_start;
