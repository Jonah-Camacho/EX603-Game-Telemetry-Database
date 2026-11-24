# Unit 6 Closing Memo

## Is the timeout problem improving?

The recorded network timeout rate improved across the four quarters of 2023. There were **12 confirmed timeouts across 200 participation events (6.00%)**. The quarterly rates below use the summed event and timeout counts from the monthly report.

| Quarter | Confirmed timeouts | Participation events | Timeout rate |
|---|---:|---:|---:|
| Q1 | 4 | 53 | 7.55% |
| Q2 | 3 | 48 | 6.25% |
| Q3 | 3 | 51 | 5.88% |
| Q4 | 2 | 48 | 4.17% |

December still needs investigation. It had **2 timeouts in 16 events (12.50%)** after October and November recorded zero. With only 12 confirmed timeouts for the year, a few events can change the rate substantially. [Task 6.3B monthly report](../queries/unit6/q6_3.sql)

## What should the team do next quarter?

1. **Review the December incidents and the highest-priority matches.** Check the connection logs for December 14 and 17. Start the match-level review with Match_02 and Match_03, which accounted for 5 of the 12 confirmed timeouts. Compare them with matches in the same server regions. Both have the Survival tag, and Match_05 also has the tag with 0 timeouts in 18 events, so the tag alone cannot establish a cause. [Task 6.2B daily totals](../queries/unit6/q6_2.sql) · [Unit 4 failure counts](../queries/unit4/q4_2.sql) · [Unit 5 mode and regional joins](../queries/unit5/q5_1.sql)
2. **Track the numerator, denominator, and missing periods.** Review confirmed timeouts and total participations weekly, then compare the next quarter's rate with Q4's 4.17%. Flag periods with missing telemetry separately. Start by checking whether Match_09's 112-day gap lines up with the match schedule or missing ingestion records. [Task 6.3B monthly report](../queries/unit6/q6_3.sql) · [Task 6.2C gap report](../queries/unit6/q6_2.sql)