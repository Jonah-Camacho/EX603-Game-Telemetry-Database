\set ON_ERROR_STOP on
\pset pager off


-- 3.3a: Which players had abandoned network timeouts in ranked matches? Requirement: IN subquery.
SELECT p.player_id, p.player_name
FROM players AS p
WHERE p.player_id IN (
    SELECT mp.player_id
    FROM match_participants AS mp
    JOIN matches AS m ON m.match_id = mp.match_id
    WHERE m.is_ranked = TRUE
      AND mp.participation_status = 'abandoned'
      AND mp.disconnect_reason = 'Network timeout'
)
ORDER BY p.player_id;

-- 3.3b: Which players had abandoned network timeouts in ranked matches? Requirement: WITH/CTE.
WITH ranked_timeouts AS (
    SELECT DISTINCT mp.player_id
    FROM match_participants AS mp
    JOIN matches AS m ON m.match_id = mp.match_id
    WHERE m.is_ranked = TRUE
      AND mp.participation_status = 'abandoned'
      AND mp.disconnect_reason = 'Network timeout'
)
SELECT p.player_id, p.player_name
FROM players AS p
JOIN ranked_timeouts AS rt ON rt.player_id = p.player_id
ORDER BY p.player_id;

-- 3.3c: Which players had abandoned network timeouts in ranked matches? Requirement: third form, INTERSECT.
SELECT player_id, player_name
FROM players
INTERSECT
SELECT p.player_id, p.player_name
FROM players AS p
JOIN match_participants AS mp ON mp.player_id = p.player_id
JOIN matches AS m ON m.match_id = mp.match_id
WHERE m.is_ranked = TRUE
  AND mp.participation_status = 'abandoned'
  AND mp.disconnect_reason = 'Network timeout'
ORDER BY player_id;

-- 3.3d: Do all three forms return identical rows? Requirement: compare rows and duplicate counts.
WITH timeout_events AS (
    SELECT mp.player_id
    FROM match_participants AS mp
    JOIN matches AS m ON m.match_id = mp.match_id
    WHERE m.is_ranked = TRUE
      AND mp.participation_status = 'abandoned'
      AND mp.disconnect_reason = 'Network timeout'
),
form_in AS (
    SELECT p.player_id, p.player_name
    FROM players AS p
    WHERE p.player_id IN (SELECT player_id FROM timeout_events)
),
form_cte AS (
    SELECT p.player_id, p.player_name
    FROM players AS p
    JOIN (SELECT DISTINCT player_id FROM timeout_events) AS rt
      ON rt.player_id = p.player_id
),
form_set AS (
    SELECT player_id, player_name FROM players
    INTERSECT
    SELECT p.player_id, p.player_name
    FROM players AS p
    JOIN timeout_events AS te ON te.player_id = p.player_id
)
SELECT 'IN vs CTE' AS comparison, COUNT(*) AS differing_rows
FROM (
    (SELECT player_id, player_name FROM form_in
     EXCEPT ALL SELECT player_id, player_name FROM form_cte)
    UNION ALL
    (SELECT player_id, player_name FROM form_cte
     EXCEPT ALL SELECT player_id, player_name FROM form_in)
) AS differences
UNION ALL
SELECT 'IN vs INTERSECT', COUNT(*)
FROM (
    (SELECT player_id, player_name FROM form_in
     EXCEPT ALL SELECT player_id, player_name FROM form_set)
    UNION ALL
    (SELECT player_id, player_name FROM form_set
     EXCEPT ALL SELECT player_id, player_name FROM form_in)
) AS differences;

-- 3.3e: Requirement: name an input condition that breaks equivalence.
-- Duplicate affected player rows in unconstrained staging data would be kept by IN
-- and the CTE join but removed by INTERSECT. The current primary key prevents this.
