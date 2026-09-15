# Unit 1: Modelling Justification and Reflection

## Justification
For creating this Game Telemetry database I looked into a game that I would be familiar with and then simplified it down to the basics. This is how I came to the decision of using this simplified Team Fight Tactic game as the basis for the database while keeping the five relations required in the Game Telemetry theme. Players will store player identities, matches will store match details, and match_participants will store the final player results. Game_modes will contain reusable labels, and match_modes will connect those labels to the matches. I kept the game details such as champions, traits, items, and individual rounds outside the scope because the main concept will be around the player performance and match activity. This will allow for the project to be manageable while still allowing for useful comparisons of placement, score, and participation over time.

For the players, matches, and game_modes primary keys I decided on using a positive integer. Names can repeat or change so they were not decided to be a reliable identifier. Using an ID would allow a name to change without needing to change the connections between records. Player names and match names can repeat but the game mode names will not so with case sensitive comparisons we could prevent duplicate labels.

For the match_participants, I chose a composite primary key that uses player_id and match_id. Using both can identify one player’s result in one match and prevent that result from being recorded twice. The combination of match_id and placement is unique so two players cannot receive the same placement. With placement being limited to integers from 1 to 8 then it will allow for a max of 8 results per match. The composite primary key for match_modes uses match_id and mode_id which would prevent the same mode from being assigned to a match more than one time.

When it comes to deletion rules, I went with ON DELETE RESTRICT for the player and match foreign keys in match_participants. This prevents the deletion of a player or match that has a recorded result. This would allow for better preservation of history for reports. Deciding on RESTRICT for the mode foreign key in match_modes allows for the assignment of modes to not be deleted. With the match foreign key in match_modes, it uses ON DELETE CASCADE since the assignments are no longer needed if the match is deleted. Matches with results would be safe due to RESTRICT.

I enforced required values, valid domains, unique keys, and foreign keys in the database so that invalid data will be rejected even if it comes from another program or import. Names cannot be blank, the duration cannot be negative, and the placement must be between the values of 1 and 8. The points are determined by 9 - placement.

## Reflection


One decision that another designer could reasonably make differently would probably be storing the score separately from placement. Since score is always 9 - placement, another designer could store only placement and then calculate the score when it’s needed. This would avoid storing an extra value that be determined by the result.

I decided to keep score because it is the metric required by the Game Telemetry theme. It also makes the planning queries straightforward because they can directly calculate total or average scores. For example, the report could use the total points to compare, player by player, those scores across several matches without repeating the points formula in each query.

The disadvantage appears when a result needs to be corrected. If the placement changes, score must also change so the two values still agree. I included the equality rule in the database to prevent an update from leaving them inconsistent. Calculating score during a query would be simple, so I would not say that storing it provides a great advantage in performance compared to calculating it per query. Keeping it mainly supports the required structure and makes the score available for reporting, while the constraints protects it during inserts and updates.

