# PvZ Zombie Bugfix Checklist

**Verification rule:** the project was statically inspected, but GameMaker Studio was unavailable in this environment. Therefore, nothing below is marked **FIXED AND TESTED**. “FIXED BUT NOT TESTED” means a corresponding code path or asset-reference correction is present; it is not a promise that the behavior has been confirmed in a running game. This checklist includes the 2026-10-25 follow-up for Flag Zombie death layering and the shared particle image resolver.

Source reference: https://github.com/ruslan831/PlantsVsZombies-decompilation

## Reported zombie issues

### Flag Zombie
- [x] **FIXED BUT NOT TESTED** — Match `Zombie::DropFlag`: emit the flag-cloth particle on head loss or normal body death, hide the flag-holding layer, and restore the ordinary `anim_innerarm*` tracks so the inner arm is visible during the falling death animation. A one-shot guard prevents duplicate flag drops.
- [x] **FIXED BUT NOT TESTED** — Mark and detach the flag-pole Reanim child when the flag drops; setting the reference to `undefined` alone left an invisible attached child updating on the body.

### Shared particle image resolver
- [x] **FIXED BUT NOT TESTED** — Search both Reanim and particle image folders from both `working_directory` and `program_directory`, covering `parts/reanim`, `datafiles/parts/reanim`, `parts/images`, `datafiles/parts/images`, and the particle image directories.
- [x] **FIXED BUT NOT TESTED** — Resolve `IMAGE_REANIM_ZOMBIE_*` identifiers to the real PopCap filenames, including `Zombie_paper_paper3.png`, `Zombie_paper_glasses.png`, `PotatoMine_mashed.png`, and `Zombie_screendoor3.png`. The four named files were confirmed present in the project and registered in `PvZ.yyp` as Included Files.
- [x] **FIXED BUT NOT TESTED** — Evict stale `-1` image/frame-cache entries and avoid caching emitter definitions when a declared image failed to load, so one failed startup lookup cannot disable that particle effect for the entire session.
- [x] **FIXED BUT NOT TESTED** — Improve diagnostics to distinguish a path lookup failure, `sprite_add` failure, and a multi-frame crop failure instead of reporting all failures as a generic “missing or could not be cropped” warning.

### Screen Door Zombie
- [x] **FIXED BUT NOT TESTED** — Hide duplicate ordinary inner arms and show the screen-door-specific arm layers instead.
- [x] **FIXED BUT NOT TESTED** — While eating, hide the shield arm and restore the normal Zombie outer arm/hand; restore shield arm presentation when walking with the door intact.
- [x] **FIXED BUT NOT TESTED** — Keep the hair track visible for the screen-door variant.
- [x] **FIXED BUT NOT TESTED** — Door break now hides the door tracks, restores ordinary arms, and emits the original `ZombieDoor` particle with the correct case-sensitive original image mapping.

### Dancing Zombie / Backup Dancer
- [x] **FIXED BUT NOT TESTED** — Initialize Reanim `anim_name` before any state machine reads it, and update the value when a named animation is played. This addresses the reported `Variable <unknown_object>.anim_name not set before reading it` crash in `obj_zombie_backup_dancer`.
- [ ] **UNRESOLVED** — The prompt contains no separate description after “dancing zombie”; any additional dancer animation or formation problem beyond the reported crash still needs a concrete in-game reproduction.

### Ducky Tube variants
- [x] **FIXED BUT NOT TESTED** — All Ducky Tube variants on Pool rows now walk toward the pool, play the original `anim_jumpinpool` sequence, trigger a splash/sound once, then switch to swimming with whitewater tracks enabled.

### Snorkel Zombie
- [x] **FIXED BUT NOT TESTED** — Separate the up-to-eat, eating, and reverse/down-from-eat states. A lost/dead target begins the reverse animation, preventing the “going out of water” clip from restarting every step.

### Zomboni
- [x] **FIXED BUT NOT TESTED** — Initialize `flat_tires` for every zombie before shared update logic reads it; addresses the reported missing-variable crash.
- [x] **FIXED BUT NOT TESTED** — Keep vehicle damage-stage image overrides and emit tire/smoke effects on state transitions instead of spawning smoke repeatedly every update.

### Catapult Zombie
- [x] **FIXED BUT NOT TESTED** — Death uses the source-style Catapult explosion particle/sound and direct no-body death instead of an unrelated fade-out death animation.
- [x] **FIXED BUT NOT TESTED** — Set the source ammunition counter to 20 and advance ammo/ball/pole visuals from the remaining counter. The asset's visible ball positions are not a literal one-sprite-per-shot 20-ball inventory.
- [x] **FIXED BUT NOT TESTED** — Crush at most the first valid non-spiky plant in its overlap for a step, avoiding deletion of every overlapping plant in one update.
- [x] **FIXED BUT NOT TESTED** — Exclude Catapult from the shared ladder-climbing path.

### Balloon Zombie
- [x] **FIXED BUT NOT TESTED** — Create a real propeller Reanim using the original `Propeller` layer and attach it to the body's `hat` track.

### Pogo Zombie
- [x] **FIXED BUT NOT TESTED** — Include the root-relative shadow for Pogo.
- [x] **FIXED BUT NOT TESTED** — Use Pogo-specific broken outer-arm / stump and damaged stick-hand parts when the arm is lost.
- [x] **FIXED BUT NOT TESTED** — Hide the intact stick hand/outer-arm tracks and use the damaged hand/grip parts after arm loss.
- [x] **FIXED BUT NOT TESTED** — Parse original particle `<ImageCol>` values and crop the Pogo particle to its specified zero-based cell (`ImageCol=2`) instead of drawing the full three-stage sheet. Structural/image-path checks pass; the particle still needs visual confirmation in GameMaker.

### Ladder Zombie / zombies using ladders
- [x] **FIXED BUT NOT TESTED** — Use the original ladder-break particle and correct exact-case source art instead of the generic zombie-arm image.
- [x] **FIXED BUT NOT TESTED** — Use Ladder-specific detached-arm art.
- [x] **FIXED BUT NOT TESTED** — Hide both the lost outer lower-arm and hand tracks so the intact hand is not left attached.
- [x] **FIXED BUT NOT TESTED** — Track which ladder a zombie has already climbed so the same zombie does not re-enter the same climb path repeatedly; Catapult is excluded.

### Gargantuar / Red-Eye Gargantuar
- [x] **FIXED BUT NOT TESTED** — Body/head/arm/foot damage-stage overrides use the original part filenames; Red-Eye uses the intact Red-Eye head at spawn and its damaged head for the damaged stage.
- [x] **FIXED BUT NOT TESTED** — Move the drawn body down 10 pixels by changing the special Gargantuar body offset from `y - 6` to `y + 4`.
- [x] **FIXED BUT NOT TESTED** — Defer the Gargantuar death thump to the later death-animation window (`anim_time >= 0.88`) and guard it against replay. The exact perceived timing/audio mix remains unverified.

### Imp
- [x] **FIXED BUT NOT TESTED** — Hide the lost outer lower-arm/hand tracks and use the Imp-specific detached arm image rather than a basic Zombie hand.

### Newspaper Zombie
- [x] **FIXED BUT NOT TESTED** — Detached-arm particle uses the original Newspaper left lower-arm part (`Zombie_paper_leftarm_lower`) rather than the generic hand particle.

### Football Zombie
- [x] **FIXED BUT NOT TESTED** — Helmet destruction emits the original helmet particle using case-correct sprite resolution.
- [x] **FIXED BUT NOT TESTED** — Use the Football-specific detached arm/hand art instead of a hand-only generic piece.
- [x] **FIXED BUT NOT TESTED** — The shared death path clears eating and plays the death animation directly; it no longer deliberately switches to a run clip first. Must verify the exact eat-to-death timing in-game.

### Jack-in-the-Box Zombie
- [x] **FIXED BUT NOT TESTED** — Track the active music sound handle, avoid starting a second overlapping instance, and stop the active sound on the pop/death path.

### Digger Zombie
- [x] **FIXED BUT NOT TESTED** — Increase underground movement speed from the previous local value and emit finite dirt bursts on a cadence rather than continuously attaching an emitter every step.
- [ ] **UNRESOLVED** — The reported one-tile horizontal offset after emerging has not been calibrated against an in-game screenshot. The root position is kept stable during emergence to avoid a speculative teleport; this needs visual verification and a precise offset correction if still present.

### Bungee Zombie
- [x] **FIXED BUT NOT TESTED** — Replace the fake target connector with the original `BungeeCord.png` segment tiled vertically from the `Zombie_bungi_body` track toward the top of the screen, following the original `DrawBungeeCord` approach.
- [x] **FIXED BUT NOT TESTED** — Keep the plant visible through the grab/lift phase, then remove it only as it is carried away.
- [x] **FIXED BUT NOT TESTED** — Extend the grab hold and reduce the rise/lift speed so the theft sequence does not rush straight into the exit.

### Yeti Zombie
- [x] **FIXED BUT NOT TESTED** — Use the Yeti-specific detached arm/hand sprite and damaged upper-arm stump.
- [x] **FIXED BUT NOT TESTED** — When retreating, look for plants on the turned-around facing side and return to the eating state when a valid target is encountered.

### Dr. Zomboss
- [x] **FIXED BUT NOT TESTED** — The encounter has explicit `anim_head_enter`, `anim_head_idle`, row-specific `anim_head_attack_*`, and `anim_head_leave` transitions; the “going back up” sequence is represented in code.
- [x] **FIXED BUT NOT TESTED** — Head-down attack chooses fire/ice and creates a boss projectile at the attack animation event.
- [x] **FIXED BUT NOT TESTED** — Play an entry thump once as the entrance animation reaches its late frame.
- [x] **FIXED BUT NOT TESTED** — Attach the Dr. Edgar driver Reanim to the original `Boss_head2` track, using `anim_idle` at 18 fps and the decompilation’s `(28, -84)` offset and 1.2 scale. The invalid `Boss_RV` attachment caused the driver to appear detached from the head.
- [x] **FIXED BUT NOT TESTED** — Make plant target eligibility row-aware during head-down attacks instead of permanently testing the boss as row 0.
- [x] **FIXED BUT NOT TESTED** — Render the boss’s outer-arm tracks in a Draw End pass, after ordinary lawn zombies, to keep spawned zombies from appearing above/in front of the hand. This ordering still needs visual confirmation in GameMaker.
- [ ] **UNRESOLVED** — Full boss fight cadence, vulnerability, projectile collision, driver visibility during every attack, and the complaint that the encounter leaves too quickly remain unverified. The Stage0 boss is still a partial recreation, not a complete port of the original encounter.

## Board / plant requests

- [x] **FIXED BUT NOT TESTED** — Move lawn-mower instances to the test-room placement (`x = -20`, per-row y from `pvz_lawn_row_y(row, -20, 23)`). Visual alignment must still be checked in GameMaker.
- [x] **FIXED BUT NOT TESTED** — Numpad 1–6 maps to Day, Night, Pool Day, Pool Night, Roof, and Boss Roof and calls a board reset that clears live board objects and restarts camera/seed selection.
- [x] **FIXED BUT NOT TESTED** — Lily Pad and Flower Pot are mapped to existing plant objects and original `LilyPad` / `Pot` Reanimations, and included in the reduced seed chooser inventory.
- [ ] **UNRESOLVED** — Exact Lily Pad / Flower Pot chooser pixel placement and all original stacking/placement restrictions still need visual and gameplay validation; this test project only approximates some board-specific rules.

## Verification results and remaining limits

- [x] All 105 GameMaker `.yy` / `.yyp` files parse after normalizing trailing commas.
- [x] All 100 project manifest resource paths resolve.
- [x] All 284 GML files pass delimiter-balance validation ignoring comments/strings.
- [x] Static scan resolves 93 of the 95 unique `<Image>` identifiers in `datafiles/particles/*.xml` to original art; the five user-reported assets and the Flag Zombie cloth asset are present and registered as Included Files.
- [ ] **UNRESOLVED BUT UNUSED** — `SimpleParticle.xml` references nonexistent `IMAGE_SUN` (`sun.png`), and `CircleEvenSpacing.xml` references nonexistent `IMAGE_PROJECTILE` (`projectile.png`). These identifiers are not present in the original resource manifest and neither effect name is referenced by the current GML code. No unrelated sun/projectile artwork was substituted for these unused generic definitions.
- [x] Static source assertions pass for Reanim `anim_name` initialization, Zomboni `flat_tires` initialization, Catapult ammo set to 20, `<ImageCol>` parsing/Pogo sheet columns, boss row-aware targeting, Numpad 1–6 controls, mower placement, Lily Pad and Flower Pot support.
- [ ] **UNRESOLVED — Engine test:** GameMaker Studio was not available here, so the project was not opened or compiled and none of these changes have been playtested. Verify animation layering, death timing, particles, sound timing, the lawn mower's visible position, pool transitions, and all boss behavior in GameMaker before treating this as complete.


## Follow-up pass — 2026-10-25

- [x] **FIXED BUT NOT TESTED** — Keep the Zomboss head-down sequence on its intended timing: idle down for 500 logic ticks, spit, idle after the spit for 300 ticks, then play `anim_head_leave` before returning to boss idle. The generic animation-loop fallback no longer interrupts the head idle/leave phases.
- [x] **FIXED BUT NOT TESTED** — Add timed hydraulic and head-leave impact sounds, plus the spawn/stomp hydraulic sound. Events are guarded to play once per animation phase rather than every frame.
- [x] **FIXED BUT NOT TESTED** — Add the original pool-safe fifth-track fallback for sixth-row Zomboss spawn/head attacks.
- [x] **FIXED BUT NOT TESTED** — Correct the boss driver attachment to `Boss_head2` and split the outer arm into the foreground draw pass.
- [x] **FIXED BUT NOT TESTED** — Use the original Zomboni speed ramp, maintain its per-row ice strip state and draw the ice cap/repeated ice texture, raise the rendered Zomboni another 20 pixels, and prevent its vehicle body from receiving the normal blue freeze tint.
- [x] **FIXED BUT NOT TESTED** — Give Zomboni and Catapult the original vehicle-specific mower explosions and prevent the normal detached-arm treatment.
- [x] **FIXED BUT NOT TESTED** — Refine common zombie collision rectangles for Football, Digger, Gargantuar, Zomboni/Catapult, Snorkel, Balloon, and Bobsled Team, and keep the boss body untargetable when its head is up.
- [x] **FIXED BUT NOT TESTED** — Use `background3.jpg` for Pool Day and Pool Night, and port the original `PoolEffect` 15×5 animated mesh/sine offsets, day/night base/shading images and caustic layer. Add the original-style per-row Zomboni ice overlay.
- [x] **FIXED BUT NOT TESTED** — Disable natural falling sky sun on both night environments while leaving plant-generated sun behavior intact.
- [x] **FIXED BUT NOT TESTED** — Route Lily Pad and Flower Pot through the existing lawn plant init/step/draw lifecycle to avoid calls into the legacy `pvz_test_*` path.



## Continuation pass — 2026-10-25

- Fixed bracketed decimal parsing so malformed normalized ranges like `.3.8` cannot be passed to `real()`; tab-separated ranges are also accepted.
- Restored source Zomboss render-group assignments and draws back leg/front leg/main body separately; removed idle animation restarts while cooldowns count down.
- Matched detached head/arm ground constraints to the original XML heights, but changed manual loose-fragment handling to settle at first ground contact after the reported repeated-fall/spin issue. XML-emitter particles with zero reflect now become grounded rather than receiving gravity again on subsequent ticks.
- Basic/cone/bucket zombies now use the full `ZombieArm.png` particle; newspaper uses `Zombie_paper_leftarm_lower`; special zombies use the original source-specific image overrides and emit only one arm particle.
- Digger underground speed matches source `mVelX` range 0.66–0.68; shooters, Chomper, and collision paths ignore underground diggers.
- Gargantuars are excluded from the ordinary ladder-climb code and can select laddered nut/pumpkin obstacles to smash.
- Balloon propeller uses `SetFramesForLayer`-style setup on the lowercase `propeller` track and attaches to the `hat` track with its imported base transform compensated so the blade art aligns with the hat anchor.
- The decimal range parser has an additional last-resort guard against adjacent leading-dot decimals such as `.3.8` before any final numeric conversion.
- Boss idle waits for its first complete idle loop before allowing an attack transition to interrupt it.
- Loose fragment spin now stops at the first ground contact instead of beginning/restarting a spin after a bounce.

Static validation is required after packaging; GameMaker runtime testing is not available in this environment.
