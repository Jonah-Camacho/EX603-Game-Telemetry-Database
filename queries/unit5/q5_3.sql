-- 5.3 A - How many match and mode pairs are possible?
WITH source_counts AS (
    SELECT (SELECT COUNT(*) FROM matches) AS match_count,
           (SELECT COUNT(*) FROM game_modes) AS mode_count
)
SELECT match_count,
       mode_count,
       match_count * mode_count AS expected_rows,
       (SELECT COUNT(*) FROM matches CROSS JOIN game_modes) AS cross_join_rows
FROM source_counts;

-- 5.3 B - How will PostgreSQL run the three-table join?
EXPLAIN
SELECT mp.participation_id,
       p.player_name,
       m.match_label,
       mp.joined_at
FROM match_participants AS mp
INNER JOIN players AS p ON p.player_id = mp.player_id
INNER JOIN matches AS m ON m.match_id = mp.match_id
ORDER BY mp.participation_id;