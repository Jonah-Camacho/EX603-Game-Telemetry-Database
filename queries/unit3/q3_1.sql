\set ON_ERROR_STOP on
\pset pager off

-- 3.1 setup: Has the data load? Requirement: table counts.
-- Finding: 30 players, 15 matches, 28 platforms, 5 modes, 25 mode links, 200 participations.
SELECT 'players' AS table_name, COUNT(*) AS row_count FROM players
UNION ALL SELECT 'matches', COUNT(*) FROM matches
UNION ALL SELECT 'match_platforms', COUNT(*) FROM match_platforms
UNION ALL SELECT 'game_modes', COUNT(*) FROM game_modes
UNION ALL SELECT 'match_modes', COUNT(*) FROM match_modes
UNION ALL SELECT 'match_participants', COUNT(*) FROM match_participants;

-- 3.1a: Which ranked matches have at least eight players? Requirement: SELECT, WHERE, ORDER BY, LIMIT.
-- Finding: Nine matches qualify.
SELECT match_id, match_label, player_count
FROM matches
WHERE is_ranked = TRUE AND player_count >= 8
ORDER BY player_count DESC, match_id
LIMIT 10;

-- 3.1b: Which participation statuses exist? Requirement: DISTINCT.
-- Finding: abandoned, contested, finished.
SELECT DISTINCT participation_status
FROM match_participants
ORDER BY participation_status;

-- 3.1c(i): Which scores are between 20 and 30? Requirement: BETWEEN.
-- Finding: The first ten matching records are shown in ID order.
SELECT participation_id, score
FROM match_participants
WHERE score BETWEEN 20 AND 30
ORDER BY participation_id
LIMIT 10;

-- 3.1c(ii): Which records are abandoned or contested? Requirement: IN.
-- Finding: The first ten matching records are shown.
SELECT participation_id, participation_status
FROM match_participants
WHERE participation_status IN ('abandoned', 'contested')
ORDER BY participation_id
LIMIT 10;

-- 3.1d(i): Which match labels end in 1? Requirement: LIKE.
-- Finding: Match_01 and Match_11.
SELECT match_id, match_label
FROM matches
WHERE match_label LIKE 'Match%1'
ORDER BY match_id;

-- 3.1d(ii): Which records have no disconnect reason? Requirement: IS NULL, COALESCE.
-- Finding: 166 records have no reason; the first ten are shown.
SELECT participation_id, participation_status,
       COALESCE(disconnect_reason, 'No reason provided') AS reason_label
FROM match_participants
WHERE disconnect_reason IS NULL
ORDER BY participation_id
LIMIT 10;

-- 3.1e: How long did each participation last? Requirement: computed columns, CASE.
-- Finding: Durations are shown in hours and three plain-language categories.
SELECT participation_id, duration_min,
       ROUND(duration_min / 60.0, 2) AS duration_hours,
       CASE
           WHEN duration_min < 10 THEN 'Under 10 minutes'
           WHEN duration_min < 20 THEN '10 to under 20 minutes'
           ELSE '20 minutes or longer'
       END AS session_length
FROM match_participants
ORDER BY participation_id
LIMIT 10;
