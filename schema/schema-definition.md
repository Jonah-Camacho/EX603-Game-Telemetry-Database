# Task 1.1: Define the Relation Schema

This design will model the final player results for a simplified and generalized version of a Team Fight Tactic (TFT) style game. All attributes are required, non-null, and atomic. The design will assume that there are 8 possible final placements with no ties being awarded. The results will be recorded once the placement is finalized.

## players - actor

'players(player_id, player_name)'

**Primary key:** player_id

| Attribute | Domain |
| --------- | ------ |
| player_id | Positive int. |
| player_name | Text, 1-50 char. |


## matches - producer

'matches(match_id, match_name, is_active, duration_minutes)

**Primary key:** match_id

| Attribute | Domain |
| --------- | ------ |
| match_id | Positive int. |
| match_id | Text, 1-100 char. |
| is_active | Boolean: true = in progress, false = ended |
| duration_minutes | Int. >= 0; elapsed min., final duration if is_active = false |


## match_participants - event

`match_participants(match_id, player_id, recorded_at, placement, score)`

**Primary key:** (match_id, player_id)

| Attribute | Domain |
| --------- | ------ |
| match_id | Positive int. referencing matches.match_id |
| player_id | Positive int. referencing players.player_id |
| recorded_at | Timestamp with time zone; when the final result was recorded |
| placement | Int. from 1-8 |
| score | Int. from 1-8; score = 9 - placement |

## game_modes - catalog

`game_modes(mode_id, game_mode_name)`

**Primary key:** mode_id

| Attribute | Domain |
| --------- | ------ |
| mode_id | Positive int. |
| game_mode_name | Text, 1-50 char. |

## match_modes - junction

`match_modes(match_id, mode_id)`

**Primary key:** (match_id, mode_id)

| Attribute | Domain |
| --------- | ------ |
| match_id | Positive int. referencing matches.match_id |
| mode_id | Positive int. referencing game_modes.mode_id |