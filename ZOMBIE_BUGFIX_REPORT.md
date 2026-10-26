# PvZ1 Zombie Bugfix Pass — report and verification status

## Scope and source references

This pass modifies the supplied GameMaker project in place and aims to preserve existing systems and original assets. Original-code comparisons were made against the public PvZ decompilation, especially `Lawn/Zombie.cpp`, `Lawn/Board.cpp`, `Lawn/Plant.cpp`, and `Lawn/LawnMower.cpp`:

https://github.com/ruslan831/PlantsVsZombies-decompilation

## Summary

The targeted code pass addresses the reported initialization crashes, zombie animation/layer handling, original-part particle image mappings, Pogo particle-sheet cropping, water-entry transitions, Catapult shooting/death/crushing, arm-loss visuals, special-zombie states, Zomboss head timing/driver attachment/sounds, the Zomboni ice trail/speed/freeze appearance, vehicle-specific mower explosions, more original-style hitboxes, the layered moving pool effect, night-time sky sun, mower placement, numpad environment switching, and Lily Pad / Flower Pot initialization.

The detailed checklist is in **`ZOMBIE_BUGFIX_STATUS.md`**. It assigns one of the requested status labels to each reported issue; no item is labeled “FIXED AND TESTED” because I could not launch GameMaker in this environment.

## Static checks performed

- Parsed all 105 `.yy` / `.yyp` metadata files after normalizing GameMaker trailing commas: no parse errors.
- Verified all 100 resource paths in `PvZ.yyp` resolve to files in the project.
- Checked delimiter balance in all 284 `.gml` files while ignoring comments and quoted strings: no imbalance found.
- Scanned literal project-relative image references for exact-case asset matches: no missing literal references found.
- Checked core source assertions for the Reanim `anim_name` initialization, Zomboni `flat_tires` initialization and speed ramp, 20-count Catapult ammo value, particle `ImageCol` parsing and Pogo sheet columns, Zomboss head-driver attachment and down/leave phases, pool mesh and ice overlays, night-sun suppression, numpad controls, mower placement, and Lily Pad / Flower Pot lifecycle references.

## What remains unverified

**GameMaker Studio was not available to open, compile, or run this project.** The report therefore does not claim that the modified project compiles or that the visual/audio behavior is correct in game. The latest follow-up added code for the named fixes, but none of the visual/audio results have been validated by running the game. Reanimation layering, collision and animation timing, sound playback, pool transitions, attachment ordering, mower alignment, and special zombie interactions require engine testing. The Digger emergence offset and complete Dr. Zomboss encounter fidelity are explicitly unresolved in the checklist.

The Stage0 project also remains a test sandbox: it does not implement the full original PvZ board simulation and all Pool/Roof stacking and restriction rules.
