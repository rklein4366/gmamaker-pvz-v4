# PvZ Zomboss Low-Health Smoke, Flashing and Death Fix (v5.1 installer compatibility update)

This package retains the v5 Zomboss behavior patch and fixes the installer check that rejected a project when the existing `pvz_lawn_spawn_particle` declaration had a different whitespace or parameter-list spelling.

## What changed in this installer update

- Finds `pvz_lawn_spawn_particle` by its function declaration instead of requiring one exact literal header line.
- Preserves existing parameters and adds only missing optional `Boss_head` track-follow parameters.
- Inserts only missing emitter metadata fields, leaving already-present fields alone.
- Recognizes harmless comment/whitespace differences in the existing particle-follow block.
- Still prepares and validates all source changes in memory before it creates a backup folder or writes any project source. If another essential code block does not match, it stops before writing and reports the specific check that failed.

## What the v5 behavior patch covers

- Uses the original Zomboss damage-stage thresholds: stage 1 below 80% health and stage 2 below 50% health.
- Uses original damaged head, jaw, hand/thumb and foot sprites and the `Boss_head` smoke offsets.
- Below 10% health, adds the original grayscale bounce pulse, critical explosion and small-explosion Foley.
- Follows smoke from the live `Boss_head` Reanim track instead of leaving it at a fixed coordinate.
- Routes lethal boss damage through the staged `anim_head_leave` sequence, boss explosion plus `bossexplosion.ogg` and `gargantudeath.ogg`, active boss fire/ice projectile cleanup, and the body/Dr. Edgar `anim_death` animations at 18 FPS.
- Creates the six surrounding fire Reanim effects when a fireball is destroyed, uses `IceBallDeath` for an iceball, ends trail emitters, fades tracked music handles, and kills other live zombies as `BossDie` does.
- Avoids generic detached-arm/head logic for Zomboss, which the original `CanLoseBodyParts()` excludes.

## Install

1. Extract this ZIP to a separate patch folder; you do not need to copy the installer files into the GameMaker project.
2. Run `RUN_INSTALLER_AND_KEEP_WINDOW_OPEN.bat`.
3. Paste the full path to the project folder containing `PvZ.yyp`.
4. Read the installer summary. Changed files are backed up to a timestamped `_pvz_boss_low_health_death_v5_1_backup_...` folder.
5. Reopen `PvZ.yyp` in GameMaker and test the boss fight.

If validation fails, the window remains open and the log is written to your Desktop (or Temp if the Desktop is unavailable). A validation failure occurs before project source is written.

## Verification note

The behavior patch is based on `Lawn/Zombie.cpp` equivalents: `GetBodyDamageIndex`, `TakeBodyDamage`, `ApplyBossSmokeParticles`, `Draw` (`BOSS_FLASH_HEALTH_FRACTION`), `BossStartDeath`, `BossDie`, and `PlayDeathAnim`. The updated installer was statically checked against the source layout available to me, including the alternate function-header matching logic. GameMaker is not available in this environment, so the project has not been compiled or play-tested here. Please compile and test in GameMaker before treating the runtime behavior as confirmed.
