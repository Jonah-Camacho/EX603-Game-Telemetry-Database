-- 5.2 A1 - How many events per match, including zero?
SELECT m.match_id,
       m.match_label,
       COUNT(mp.participation_id) AS events
FROM matches AS m
LEFT JOIN match_participants AS mp ON mp.match_id = m.match_id
GROUP BY m.match_id, m.match_label
ORDER BY m.match_id;

-- 5.2 A2 - How many events per match with activity?
SELECT m.match_id,
       m.match_label,
       COUNT(mp.participation_id) AS events
FROM matches AS m
INNER JOIN match_participants AS mp ON mp.match_id = m.match_id
GROUP BY m.match_id, m.match_label
ORDER BY m.match_id;

-- 5.2 A3 - How many matches does the inner join exclude?
SELECT COUNT(DISTINCT m.match_id) AS all_matches,
       COUNT(DISTINCT mp.match_id) AS matches_with_events,
       COUNT(DISTINCT m.match_id) - COUNT(DISTINCT mp.match_id) AS excluded_matches
FROM matches AS m
LEFT JOIN match_participants AS mp ON mp.match_id = m.match_id;

-- 5.2 B1 - Does the right join keep every match?
SELECT m.match_id,
       m.match_label,
       COUNT(mp.participation_id) AS events
FROM match_participants AS mp
RIGHT JOIN matches AS m ON m.match_id = mp.match_id
GROUP BY m.match_id, m.match_label
ORDER BY m.match_id;

-- 5.2 B2 - Do the left and right join results match?
WITH left_results AS (
    SELECT m.match_id, mp.participation_id
    FROM matches AS m
    LEFT JOIN match_participants AS mp ON mp.match_id = m.match_id
),
right_results AS (
    SELECT m.match_id, mp.participation_id
    FROM match_participants AS mp
    RIGHT JOIN matches AS m ON m.match_id = mp.match_id
),
left_only AS (
    SELECT * FROM left_results
    EXCEPT
    SELECT * FROM right_results
),
right_only AS (
    SELECT * FROM right_results
    EXCEPT
    SELECT * FROM left_results
)
SELECT (SELECT COUNT(*) FROM left_results) AS left_rows,
       (SELECT COUNT(*) FROM right_results) AS right_rows,
       (SELECT COUNT(*) FROM left_only) AS left_only_rows,
       (SELECT COUNT(*) FROM right_only) AS right_only_rows;

-- 5.2 B3 - Which matches or events are unmatched?
SELECT COALESCE(m.match_id, mp.match_id) AS match_id,
       m.match_label,
       COUNT(mp.participation_id) AS events,
       CASE
           WHEN m.match_id IS NULL THEN 'event without a match'
           WHEN mp.match_id IS NULL THEN 'match without events'
           ELSE 'matched'
       END AS join_status
FROM matches AS m
FULL OUTER JOIN match_participants AS mp ON mp.match_id = m.match_id
GROUP BY m.match_id, m.match_label, mp.match_id
ORDER BY match_id;

-- 5.2 C1 - Which matches have no events?
SELECT m.match_id
FROM matches AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM match_participants AS mp
    WHERE mp.match_id = m.match_id
)
ORDER BY m.match_id;

-- 5.2 C2 - Which matches have no events?
SELECT match_id FROM matches
EXCEPT
SELECT match_id FROM match_participants
ORDER BY match_id;
