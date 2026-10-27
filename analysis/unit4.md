# Analysis

Each event is a participation record. 'player_id' identifies the player and 'match_id' identifies  the producers. The metric is score. There was a failure when a participation was abondoned due to 'Netowrk timeout'. All of the events are included in the calculation which would also include those without reason for disconnection.

## Task 4.1

**4.1a:** The data contains 200 scores totaling 3,628.19. The average is 18.14, the minimum is 0.00, and the maximum is 70.86. There are 30 distinct players. All 34 scores of zero are from abandoned participations. Since zero is allowed by the schema, these values do not automatically mean there is a data error or network failure.

**4.1b:** Producer 6 has the most events with 21. Producer 5 has the highest average score at 23.06, while producer 11 has the lowest at 11.94. Producers 14 and 15 have no events, so their averages are NULL.

**4.1c:** I chose a minimum of 10 events because a rate based on only a few records may not represent a producer’s usual performance. This keeps 12 producers and 194 of the 200 events. Producer 4 is excluded because it only has six events. The remaining samples are still small, so more data would help confirm these results.

**4.1d:** Grouping by server region and ranked status gives seven combinations. OCE has a 2.17% failure rate for ranked activity and 15.38% for unranked activity. EU’s ranked rate is 16.67%, but that is based on only six events.

The live-operations manager would use this breakdown to decide which producers need investigation. Average scores do not show how spread out the scores are, and event counts do not show whether the same players appear multiple times. Next, I would look at individual scores, which players were affected, event times, and server logs for producers 2 and 3.

## Task 4.2

**Part A:** The query answers two questions: How many events did each producer have? How many of those events were failures? Producer 2 has three failures, and producer 3 has two. These are the largest failure counts.

**Part B:** The APAC, EU, NA, OCE, and SA rows are regional subtotals. The `ALL REGIONS` row is the grand total, with 200 events, 12 failures, and a 6.00% failure rate. The regional director would use the subtotals to decide where to investigate. The grand total helps leadership decide how much attention and resources the platform needs overall.

**Part C:** The pipeline answers: What is the combined failure rate for producers with at least 10 events? The CTE calculates totals for each producer, and the outer query keeps the qualifying producers and combines their results. This gives a baseline of 5.67%, with 11 failures across 194 events and 12 producers. The calculation uses the combined failure and event counts instead of averaging each producer’s percentage.

## Reflection

Using conditional aggregation allowed me to be able to calculate the total number of events and failures using the same query. If I did it using the two query method then I would have needed to calculate them separately and then combine them together. Doing them separately would also make it easier to accidentally use different conditions or leave out records that did not have a disconnect reason.

At a million rows, the difference matters because two queries could read the same table twice. This would increase the work that is on the database while also making it take longer. The Conditional aggregations allows for a single pass through of the records in order to calculate it. It also keeps the counts based on the same data. If I ran the queries separately and new records were added between them, the totals might not match.

I would still check the actual execution times because indexes and caching can affect performance. For me, the main benefit is that the related numbers stay together, making the calculation easier to review and reducing the chance of using the wrong total for the failure rate.

