# Task 1.3: Integrity Constraints

## Primary keys

- players: player_id uniquely identifies each player.
- matches: match_id uniquely identifies each match.
- game_modes: mode_id uniquely identifies each mode.
- match_participants: (match_id, player_id) prevents duplicate player results in a match.
- match_modes: (match_id, mode_id) prevents duplicate mode assignments.

## Data rules

- All attributes are non-null to prevent missing information.
- All IDs are positive integers.
- player_name and game_mode_name contain 1-50 characters.
- match_name contains 1-100 characters.
- Names cannot be blank or contain only spaces.
- game_mode_name is unique using case-sensitive comparison to prevent exact duplicates.
- is_active is true or false.
- duration_minutes is an integer >= 0 to prevent negative durations.
- recorded_at is a valid timestamp with time zone.
- placement is an integer from 1-8 and cannot repeat within a match, preventing ties.
- score is an integer from 1-8 and equals 9 - placement, ensuring correct points.

## Foreign keys and deletion rules

- match_participants.player_id references players.player_id.
  ON DELETE RESTRICT prevents deleting a player with recorded results.

- match_participants.match_id references matches.match_id.
  ON DELETE RESTRICT prevents deleting a match with recorded results.

- match_modes.match_id references matches.match_id.
  ON DELETE CASCADE removes the mode assignments when a match is deleted.

- match_modes.mode_id references game_modes.mode_id.
  ON DELETE RESTRICT prevents deleting a mode assigned to a match.

All foreign keys must reference existing records. A match with results cannot be deleted. A match without results can be deleted along with its mode assignments.