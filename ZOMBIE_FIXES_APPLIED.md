# PvZ zombie stability and behavior patch

This is a targeted pass over the existing GameMaker Stage0 project. It does not replace the original sprites or rewrite the project architecture. The decompilation reference used for source comparisons is https://github.com/ruslan831/PlantsVsZombies-decompilation.

The new issue-by-issue checklist is in **`ZOMBIE_BUGFIX_STATUS.md`**. It calls out which changes are implemented in code, what remains unresolved, and the testing limitation.

Key code-level changes include safe Reanim clip-name initialization and Zomboni tire-state initialization; original sprite/particle filename resolution; selection of the original `ImageCol` for particle sprite sheets (including the Pogo broken-stick frame); shield/arm visibility handling; Ducky Tube and Snorkel pool-entry/eat transitions; Catapult ammo/death/crushing behavior; special arm/particle art; Bungee cord/target handling; ladder re-entry prevention; boss row-targeting; numpad board reset; mower placement; and Lily Pad / Flower Pot chooser mappings.

**Verification limit:** static project checks have passed, but GameMaker Studio could not be launched here. Do not interpret code inspection as an in-game test; all affected behaviors still need to be exercised in the GameMaker IDE. The current project remains a Stage0 gameplay test sandbox rather than a complete port of every original PvZ board rule and boss-fight detail.
