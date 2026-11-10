-- 5.1 Q1 - Who joined each match, and when?
SELECT mp.participation_id,
       p.player_name,
       m.match_label,
       mp.joined_at
FROM match_participants AS mp
INNER JOIN players AS p ON p.player_id = mp.player_id
INNER JOIN matches AS m ON m.match_id = mp.match_id
ORDER BY mp.participation_id;

-- 5.1 Q2 - Which matches are tagged Survival?
SELECT m.match_id,
       m.match_label,
       gm.mode_name
FROM matches AS m
INNER JOIN match_modes AS mm ON mm.match_id = m.match_id
INNER JOIN game_modes AS gm ON gm.mode_id = mm.mode_id
WHERE gm.mode_name = 'Survival'
ORDER BY m.match_id;

-- 5.1 Q3 - How do matches 2 and 3 compare with regional peers?
WITH match_activity AS (
    SELECT match_id,
           COUNT(*) AS events,
           ROUND(100.0 * AVG(CASE
               WHEN participation_status = 'abandoned'
                AND disconnect_reason = 'Network timeout' THEN 1
               ELSE 0
           END), 2) AS failure_pct
    FROM match_participants
    GROUP BY match_id
)
SELECT m.match_id AS flagged_id,
       peer.match_id AS peer_id,
       m.server_region,
       m.is_ranked AS flagged_ranked,
       peer.is_ranked AS peer_ranked,
       COALESCE(a.events, 0) AS flagged_events,
       COALESCE(b.events, 0) AS peer_events,
       a.failure_pct AS flagged_failure_pct,
       b.failure_pct AS peer_failure_pct
FROM matches AS m
INNER JOIN matches AS peer
    ON peer.server_region = m.server_region
   AND peer.match_id <> m.match_id
LEFT JOIN match_activity AS a ON a.match_id = m.match_id
LEFT JOIN match_activity AS b ON b.match_id = peer.match_id
WHERE m.match_id IN (2, 3)
ORDER BY m.match_id, peer.match_id;