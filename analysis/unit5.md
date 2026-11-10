# Unit 5 Analysis

For this dataset I treated the player as the actor, the match as the producer, the participation record as the event and the game mode as the catalog tag. I used the same definition of a failure as I did in Unit 4. A participation was a failure if it was abandoned and had a network timeout recorded.

## Task 5.1

1. For a live ops report that shows who joined each match and when they joined I'd use the three table join. That query returned 200 participation records. If a player reported a timeout the team could use the participation ID to find that particular event.

2. I used match_modes as a match can have more than one mode and a mode can be assigned to more than one match. Each row is a match mode pair so I can filter on the mode directly. Survival was on matches 2, 3, 5, 10 and 11. Matches 2 and 3 both had the Survival tag but match 5 also had it and had zero timeouts across 18 events. That makes me think there’s more to look at than just the mode of the game.

3. I did a self join to compare match 2 and 3 against the other matches in the same server regions. Match 2 had a failure rate of 18.75% across 16 events. Matches 6 and 11 were also APAC matches and had lower failure rates at 4.76% (across 21 events) and 6.25% (across 16 events) respectively. Match 3 had a failure rate of 15.38% across 13 events. The other OCE matches had between 11 and 18 events and failure rates between 0% and 5.88%. The one thing that stood out was that match 3 was unranked whereas the other OCE matches were all ranked. The event counts were pretty much the same so I’d look at other differences between the matches, the samples are just too small to say what caused the failures.

## Task 5.2

1. The left join gave 15 distinct matches, the inner join 13. The two missing from the inner join were matches 14 and 15 (Match_14 and Match_15). Neither of those had a participation record.

2. All I can tell from the data is that there was no participation for those matches. They may have been cancelled or just not used at all, or they may have actually taken place with no participation recorded.

3. If leadership were only looking at the inner join then they'd see 13 matches and would miss the two that had no activity recorded at all.

4. Leadership could use this list to verify that the matches did take place as scheduled and that the platform had indeed recorded the player activity.

5. I'd ask the live ops team to check the schedule and logs for matches 14 and 15. If either one actually happened then I'd go and see why there's no participation record for it. If it was cancelled or just not used then I'd record that as the status so the team are aware of why there are no events.

The left join and the right join with the tables reversed both came back with 202 rows prior to the grouping. That was 200 participation records and one row each for matches 14 and 15. I checked the match and participation IDs in both directions and there was no difference. The full outer join also looked for any participation records that didn't have a corresponding match and found none as every participation record must have a match via a foreign key.

I also tried NOT EXISTS and EXCEPT. NOT EXISTS looks at each match in turn for a participation record and retains the match if there is no participation record. EXCEPT starts off with all the match IDs and then removes those which appear in the participation table. Both queries returned matches 14 and 15.

## Task 5.3

### Cross join

There are 15 matches and 5 game modes so the cross join returns 75 rows. I could use that as a list of all possible match/game mode combinations and then compare that to the match_modes table to see which of the combinations were actually assigned. If I'd expected to see only the ones that were actually assigned and I saw all 75 then I'd check whether I'd omitted a join condition.

### Execution plan

```text
                                                                   QUERY PLAN
----------------------------------------------------------------------------------------------------------------
 Sort  (cost=35.98..36.48 rows=200 width=532) (actual time=1.963..1.968 rows=200.00 loops=1)
   Sort Key: mp.participation_id
   Sort Method: quicksort  Memory: 35kB
   Buffers: shared hit=27 read=6
   ->  Nested Loop  (cost=12.40..28.34 rows=200 width=532) (actual time=1.873..1.937 rows=200.00 loops=1)
         Buffers: shared hit=24 read=6
         ->  Hash Join  (cost=12.25..17.80 rows=200 width=278) (actual time=1.668..1.695 rows=200.00 loops=1)
               Hash Cond: (mp.player_id = p.player_id)
               Buffers: shared read=4
               ->  Seq Scan on match_participants mp  (cost=0.00..5.00 rows=200 width=24) (actual time=0.818..0.825 rows=200.00 loops=1)
                     Buffers: shared read=3
               ->  Hash  (cost=11.00..11.00 rows=100 width=262) (actual time=0.840..0.840 rows=30.00 loops=1)
                     Buckets: 1024  Batches: 1  Memory Usage: 10kB
                     Buffers: shared read=1
                     ->  Seq Scan on players p  (cost=0.00..11.00 rows=100 width=262) (actual time=0.825..0.827 rows=30.00 loops=1)
                           Buffers: shared read=1
         ->  Memoize  (cost=0.15..0.41 rows=1 width=262) (actual time=0.001..0.001 rows=1.00 loops=200)
               Cache Key: mp.match_id
               Cache Mode: logical
               Hits: 187  Misses: 13  Evictions: 0  Overflows: 0  Memory Usage: 2kB
               Buffers: shared hit=24 read=2
               ->  Index Scan using matches_pkey on matches m  (cost=0.14..0.40 rows=1 width=262) (actual time=0.016..0.016 rows=1.00 loops=13)
                     Index Cond: (match_id = mp.match_id)
                     Index Searches: 13
                     Buffers: shared hit=24 read=2
 Planning:
   Buffers: shared hit=257 read=25 dirtied=1
 Planning Time: 9.612 ms
 Execution Time: 2.003 ms
(29 rows)
```

PostgreSQL used sequential scans on `match_participants` and `players` and joined them with a hash join. The report needs every participation record, and the player table is small, so scanning both tables makes sense here. PostgreSQL then used a nested loop and the `matches_pkey` index to look up matches. It cached the results by match ID, so 187 of the 200 lookups used the cache and only 13 needed an index search.

PostgreSQL estimated 200 participation records, which matched the actual count. It estimated 100 player rows, but the scan returned 30. The last step sorted the 200 result rows by participation ID. The query took 2.003 ms to execute.

As the participation table gets bigger we'd be looking at how long PostgreSQL is taking to read the records and whether it's going to have to sort the entire result set by participation ID. A report filtered down to a single match would be a different case as it would only be looking at a tiny proportion of the events.

### Reflection

If the report still needs every event as the dataset grows then I can see PostgreSQL just scanning the participation table and doing hash joins. It could build hash tables for players and matches and then use those to find the relevant player and match as it reads through each participation record. That would work quite well whilst those two tables are small, though reading and sorting more events would presumably take longer.

If I filtered the report down to one match then an index on match_participants.match_id would be useful to allow PostgreSQL to find just those events. A nested loop would make sense if there were only a handful of rows to look up via the primary key indexes. A merge join would also be appropriate if both sides of the join were large and PostgreSQL could read them in join key order (i.e. it could read both inputs in order without having to sort them first).

I'd keep the table statistics up to date so that PostgreSQL has better information when it comes to working out how many rows it's going to match. Once you've changed the query or added an index you'd run EXPLAIN ANALYZE to compare the estimated row count with the actual row count and see whether the query had in fact run any faster.