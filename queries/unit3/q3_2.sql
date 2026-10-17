\set ON_ERROR_STOP on
\pset pager off

-- 3.2A(i): How many records does the broken filter keep? Requirement: inequality on a nullable column.
SELECT COUNT(*) AS broken_not_timeout_count
FROM match_participants
WHERE disconnect_reason <> 'Network timeout';

-- 3.2A(ii): How many NULL records were silently omitted? Requirement: omitted-row count.
SELECT COUNT(*) AS silently_omitted_count
FROM match_participants
WHERE disconnect_reason IS NULL;

-- 3.2A(iii): Do the counts account for every record? Requirement: compare counts with the table total.
SELECT COUNT(*) AS table_total,
       COUNT(CASE WHEN disconnect_reason <> 'Network timeout' THEN 1 END)
           AS broken_kept,
       COUNT(CASE WHEN disconnect_reason IS NULL THEN 1 END)
           AS silently_omitted,
       COUNT(CASE WHEN disconnect_reason = 'Network timeout' THEN 1 END)
           AS known_timeouts,
       COUNT(CASE WHEN disconnect_reason <> 'Network timeout'
                  OR disconnect_reason = 'Network timeout' THEN 1 END)
           AS counted_by_both_comparisons
FROM match_participants;

-- 3.2A(iv): How many records have no recorded timeout, including NULLs? Requirement: repair with IS NULL.
SELECT COUNT(*) AS repaired_not_recorded_timeout_count
FROM match_participants
WHERE disconnect_reason <> 'Network timeout'
   OR disconnect_reason IS NULL;

-- 3.2A(v): What are the overall and ranked timeout rates? Requirement: audit the failure rate.
WITH scoped AS (
    SELECT mp.participation_status, mp.disconnect_reason, m.is_ranked
    FROM match_participants AS mp
    JOIN matches AS m ON m.match_id = mp.match_id
),
totals AS (
    SELECT 'All participations' AS population,
           COUNT(*) AS total,
           COUNT(CASE WHEN participation_status = 'abandoned'
                       AND disconnect_reason = 'Network timeout' THEN 1 END)
               AS timeouts,
           COUNT(disconnect_reason) AS with_reason
    FROM scoped
    UNION ALL
    SELECT 'Ranked participations', COUNT(*),
           COUNT(CASE WHEN participation_status = 'abandoned'
                       AND disconnect_reason = 'Network timeout' THEN 1 END),
           COUNT(disconnect_reason)
    FROM scoped
    WHERE is_ranked = TRUE
)
SELECT population, total, timeouts,
       ROUND(100.0 * timeouts / NULLIF(total, 0), 2) AS timeout_percent,
       ROUND(100.0 * timeouts / NULLIF(with_reason, 0), 2)
           AS incorrect_reason_only_percent
FROM totals
ORDER BY population;

-- 3.2B(i): Can WHERE use a SELECT alias? Requirement: reproduce the alias error (intentional).
\set ON_ERROR_STOP off
SELECT participation_id, duration_min,
       ROUND(duration_min / 60.0, 2) AS duration_hours
FROM match_participants
WHERE duration_hours >= 0.25
ORDER BY participation_id
LIMIT 10;
\set ON_ERROR_STOP on

-- 3.2B(ii): Can repeating the expression fix the error? Requirement: first alias rewrite.
SELECT participation_id, duration_min,
       ROUND(duration_min / 60.0, 2) AS duration_hours
FROM match_participants
WHERE ROUND(duration_min / 60.0, 2) >= 0.25
ORDER BY participation_id
LIMIT 10;

-- 3.2B(iii): Can a CTE make the alias available? Requirement: second alias rewrite.
WITH sessions AS (
    SELECT participation_id, duration_min,
           ROUND(duration_min / 60.0, 2) AS duration_hours
    FROM match_participants
)
SELECT participation_id, duration_min, duration_hours
FROM sessions
WHERE duration_hours >= 0.25
ORDER BY participation_id
LIMIT 10;
