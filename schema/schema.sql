-- =================================================================
-- EX 603 Assignment 2 — schema.sql
-- Theme: Game Telemetry
-- Author: Jonah Camacho
-- Target: PostgreSQL 14+
-- =================================================================
-- Reset. Reverse creation order, so no dependency blocks a drop.
 
DROP TABLE IF EXISTS match_modes    CASCADE;
DROP TABLE IF EXISTS match_participants   CASCADE;
DROP TABLE IF EXISTS game_modes   CASCADE;
DROP TABLE IF EXISTS matches   CASCADE;
DROP TABLE IF EXISTS players    CASCADE;

---------------------------------------------------------------------------
-- 1. players - created first because it doesn't reference another table.
---------------------------------------------------------------------------

CREATE TABLE players (
    player_id INTEGER GENERATED ALWAYS AS IDENTITY,
    player_name VARCHAR(50) NOT NULL,

    CONSTRAINT pk_players
        PRIMARY KEY (player_id),

    CONSTRAINT chk_players_id_positive
        CHECK (player_id > 0),

    CONSTRAINT chk_players_name
        CHECK (char_length(btrim(player_name)) BETWEEN 1 AND 50)
);

----------------------------------------------------------------------------
-- 2. matches - second because it also doesn't reference another table
----------------------------------------------------------------------------

CREATE TABLE matches (
    match_id INTEGER GENERATED ALWAYS AS IDENTITY,
    match_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL,
    duration_minutes INTEGER NOT NULL,

    CONSTRAINT pk_matches
        PRIMARY KEY (match_id),

    CONSTRAINT chk_matches_id_positive
        CHECK (match_id > 0),

    CONSTRAINT chk_matches_name
        CHECK (char_length(btrim(match_name)) BETWEEN 1 AND 100),

    CONSTRAINT chk_matches_duration
        CHECK (duration_minutes >= 0)
);

------------------------------------------------------------------------------
-- 3. game_modes - Also doens't reference another table so created third
------------------------------------------------------------------------------

CREATE TABLE game_modes (
    mode_id INTEGER GENERATED ALWAYS AS IDENTITY,
    game_mode_name VARCHAR(50) NOT NULL,

    CONSTRAINT pk_game_modes
        PRIMARY KEY (mode_id),

    CONSTRAINT uq_game_modes_name
        UNIQUE (game_mode_name),

    CONSTRAINT chk_game_modes_id_positive
        CHECK (mode_id > 0),

    CONSTRAINT chk_game_modes_name
        CHECK (char_length(btrim(game_mode_name)) BETWEEN 1 AND 50)
);


-------------------------------------------------------------------------------
-- 4. match_participants - depends on matches and players
-- Each row is a player's final result after a match
-------------------------------------------------------------------------------

CREATE TABLE match_participants (
    match_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    recorded_at TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    placement INTEGER NOT NULL,

    score INTEGER
        GENERATED ALWAYS AS (9 - placement) STORED,

    CONSTRAINT pk_match_participants
        PRIMARY KEY (match_id, player_id),

    CONSTRAINT uq_match_participants_placement
        UNIQUE (match_id, placement),

    CONSTRAINT fk_match_participants_match
        FOREIGN KEY (match_id)
        REFERENCES matches (match_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_match_participants_player
        FOREIGN KEY (player_id)
        REFERENCES players (player_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_match_participants_placement
        CHECK (placement BETWEEN 1 AND 8),

    CONSTRAINT chk_match_participants_score
        CHECK (score BETWEEN 1 AND 8)
);

----------------------------------------------------------------------------------
-- 5. match_modes - depends on matches and game_modes
-- Duplicate mode assignments are prevented by the composite key
----------------------------------------------------------------------------------

CREATE TABLE match_modes (
    match_id INTEGER NOT NULL,
    mode_id INTEGER NOT NULL,

    CONSTRAINT pk_match_modes
        PRIMARY KEY (match_id, mode_id),

    CONSTRAINT fk_match_modes_match
        FOREIGN KEY (match_id)
        REFERENCES matches (match_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_match_modes_mode
        FOREIGN KEY (mode_id)
        REFERENCES game_modes (mode_id)
        ON DELETE RESTRICT
);
