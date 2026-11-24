-- 6.1 Q1a - How does each event's score compare with its match average?
SELECT p.participation_id,
       m.match_label,
       p.score,
       ROUND(AVG(p.score) OVER (PARTITION BY p.match_id), 2) AS match_avg_score
FROM match_participants AS p
JOIN matches AS m ON m.match_id = p.match_id
ORDER BY p.match_id, p.participation_id;

-- 6.1 Q1b - What is the average score for each match with recorded events?
SELECT m.match_label,
       COUNT(*) AS events,
       ROUND(AVG(p.score), 2) AS match_avg_score
FROM match_participants AS p
JOIN matches AS m ON m.match_id = p.match_id
GROUP BY p.match_id, m.match_label
ORDER BY p.match_id;

-- 6.1 Q2 - How does tie handling change the match activity rankings?
WITH match_counts AS (
    SELECT m.match_id, m.match_label, COUNT(p.participation_id) AS events
    FROM matches AS m
    LEFT JOIN match_participants AS p ON p.match_id = m.match_id
    GROUP BY m.match_id, m.match_label
)
SELECT match_label,
       events,
       ROW_NUMBER() OVER (ORDER BY events DESC, match_id) AS row_number,
       RANK() OVER (ORDER BY events DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY events DESC) AS dense_rank
FROM match_counts
ORDER BY events DESC, match_id;

-- 6.1 Q3 - Which activity band does each match fall into?
WITH match_counts AS (
    SELECT m.match_id, m.match_label, COUNT(p.participation_id) AS events
    FROM matches AS m
    LEFT JOIN match_participants AS p ON p.match_id = m.match_id
    GROUP BY m.match_id, m.match_label
)
SELECT match_label,
       events,
       NTILE(4) OVER (ORDER BY events DESC, match_id) AS activity_band
FROM match_counts
ORDER BY events DESC, match_id;
