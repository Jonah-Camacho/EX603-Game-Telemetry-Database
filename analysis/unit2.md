# Unit 2: Constraints and Implementation Decisions

## Foreign-Key Constraints

| Foreign key | ON DELETE | Reason |
|---|---|---|
| `match_participants.match_id` | `RESTRICT` | Match with recorded player results cannot be deleted |
| `match_participants.player_id` | `RESTRICT` | Player with recorded match results cannot be deleted |
| `match_modes.match_id` | `CASCADE` | Deletion of a match will also remove the mode assignment because it will no longer have a match to describe |
| `match_modes.mode_id` | `RESTRICT` | A game mode cannot be deleted if it is assigned to an existing match |

## ON DELETE Reasoning

The `RESTRICT` rules will preserve the historical results. Deleting a player or match with participant records is blocked because allowing the deletion would either remove useful performance history or leave records without their required parent. A game mode is also restricted from deletion while matches use it because removing it would erase part of those matches classifications.

The match foreign key in `match_modes` uses `CASCADE`. When a match is deleted, its mode assignments have no independent meaning and can be removed automatically. Using `RESTRICT` would require those association rows to be deleted manually before deleting the match.

## CHECK Constraints

- `chk_players_id_positive` prevents zero or negative player IDs.
- `chk_players_name` prevents blank player names and enforces the 50-character limit.
- `chk_matches_id_positive` prevents zero or negative match IDs.
- `chk_matches_name` prevents blank match names and enforces the 100-character limit.
- `chk_matches_duration` prevents a negative match duration.
- `chk_game_modes_id_positive` prevents zero or negative mode IDs.
- `chk_game_modes_name` prevents blank game-mode names and enforces the 50-character limit.
- `chk_match_participants_placement` prevents placements outside the valid range of 1 through 8.
- `chk_match_participants_score` prevents scores outside the valid range of 1 through 8.

These constraints prevent invalid values that could otherwise be introduced through user input, application errors, or data imports.

## Implementation Change

During the implementation, `score` was changed to a stored generated column that is calculated as `9 - placement`. This would prevent placement and score from becoming inconsistent while keeping score available for reporting. I also changed the primary key of `match_participants` from (player_id, recorded_at) to (match_id, player_id). This key will identify a player's result in a specific match and prevent it from being recorded twice.