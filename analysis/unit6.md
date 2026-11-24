# Unit 6 Analysis

I treated each match as a producer and each participation record as an event. I counted a timeout when the event was marked `abandoned` and the reason was `Network timeout`.

## Task 6.1 — Averages, rankings, and bands

1. Which scores were unusually high or low for their match? The `GROUP BY` query gives me one average for each of the 13 matches with events. The window query keeps all 200 scores alongside their match averages, so I can see which scores stand out. For example, participation ID 18 scored 47.81 in Match_02, well above the match average of 17.02.
2. I'd use `DENSE_RANK()` for a match activity leaderboard because tied matches share a rank and the next rank stays consecutive. Match_05 and Match_07 each had 18 events, so they both get rank 4 and Match_12 gets rank 5. `ROW_NUMBER()` gives the tied matches 4 and 5. `RANK()` gives them both 4 and then jumps to 6.
3. `NTILE(4)` divides the 15 matches into groups of 4, 4, 4, and 3. The match ID breaks the tie between Match_05 and Match_07, so they end up in different bands even though they had the same event count.

[Task 6.1 SQL](../queries/unit6/q6_1.sql)

## Task 6.2 — Neighbors, running totals, and gaps

1. On December 17, a Match_02 event scored zero, 20.29 points below the previous event. I'd flag a drop like that and check the event status and connection logs for a timeout.
2. I set a cap of 10 timeouts for 2023. A simple `SUM()` gives the final count of 12. The running total shows when the count first went over the cap, reaching 11 on December 14.
3. I averaged the daily timeout counts over the current recorded day and up to six previous days with records. I chose that window to smooth daily jumps and still pick up spikes. It can cover more than seven calendar days. With a running total, `ROWS` adds tied rows one at a time. `RANGE` includes all rows tied at the current sort value together.
4. Match_09 had just over 112 days between consecutive records, from January 5 to April 28. I'd treat that as a gap in recorded participation and check the schedule and data load logs to see whether activity stopped or records were missed.

[Task 6.2 SQL](../queries/unit6/q6_2.sql)

## Task 6.3 — Reporting patterns

1. I'd show the top three scores in a match highlights panel. One score would leave out other strong results, and ten would be too many to scan. The lower participation ID breaks a tie for third.
2. November had 0 timeouts in 14 events. December had 2 in 16, an increase of 12.50 percentage points. Since November's rate was zero, the relative percent change is undefined. I'd check both December incidents and show the event counts alongside the rates. All 12 months had events.


## Reflection

I'd build a report that shows each participation's score alongside the match average and the score from the previous event. If a score looked low, I could see how far it was from the average and how it had changed since the last event in that match. I'd keep the participation ID and join time on the same row so I could find the event in the logs. Consecutive events can come from different players, so I'd use a big drop to flag a record for review.

`GROUP BY match_id` gives me one average per match. To get the event details, I'd have to join those averages back to the participation records and work out the previous event separately. With window functions, I can partition `AVG()` by match to put the average on each event row. I can also use `LAG()` within each match, ordered by join time and then `participation_id`, to get the previous score.