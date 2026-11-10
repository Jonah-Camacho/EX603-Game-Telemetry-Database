# Unit 5 Findings and Recommendations

## Investigate matches with frequent timeouts

I’d go with Match_02 and Match_03. Match_02 had 3 network timeouts from 16 recorded participations (18.75%) and Match_03 had 2 from 13 (15.38%). Combined they make up 5 of the 12 network timeouts recorded on the platform.

I’d ask the live ops team to have a look at the server and connection logs around those five timeouts and compare them to the logs from other matches in the same regions. Both of the matches in question were Survival tagged, but other Survival matches had either significantly fewer timeouts or none at all. I’d look at the logs to see if the same server or connection issue was occurring more than once.

## Follow up on matches with no recorded participation

Match_14 and Match_15 were both on the schedule but neither of them had any player activity recorded. I’d query the scheduling team to confirm whether either match actually took place. If one did take place then I’d have the telemetry team check whether any of the records were missed. If a match was cancelled or simply didn't go ahead then I’d have the scheduling team update its status so that leadership can see why there was no activity.