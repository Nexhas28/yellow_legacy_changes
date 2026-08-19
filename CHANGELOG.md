# Changelog

## [1.10.4] - 2026-08-19

### Changed

- Viridian Forest rare 1% grass encounter changed from Pidgeotto to Pikachu.

## [1.10.3] - 2026-08-05

### Fixed

- The Poliwag line keeps its vanilla Gen 1 evolutions: Poliwag to
  Poliwhirl at level 18, Poliwhirl to Poliwrath by **Water Stone**
  (was wrongly set to a level-18 Poliwhirl -> Poliwrath evolution).
- Bug attacks are no longer super effective against Poison; the Gen 1
  chart bug is removed (Bug is now neutral to Poison).

## [1.10.2] - 2026-08-05

### Changed

- The sibling-file loaders (learnsets/trainers/rematches, Hard Mode, Crystal
  Tear) were deduplicated into one `loadSibling` helper (~45 lines removed,
  same error logs).
- `speciesId` and `constId` are now built in a single `pokemon:each()` pass
  instead of two.
- The forced-SET style wrap only forces when an options table exists, so a
  stub or broken save can't crash it.
- `gameData()` helper hoists the two repeated `src.core.Game.data` reads.

## [1.10.1] - 2026-08-04

### Changed

- The **HARD MODE** toggle moved from MODS > yellow_legacy_changes to
  the in-game **OPTIONS** menu: a ON/OFF row right under BATTLE STYLE
  (persisted in options.lua as before, still flips a run at any time).

## [1.10.0] - 2026-08-04

### Added

- **Hard Mode** as an optional challenge: offered with a YES/NO prompt
  in Oak's intro when starting a new game, and toggleable at any time in
  the OPTIONS menu (persisted in options.lua, default OFF).
  Hard Mode enforces:
  - **Forced SET style** — the free-switch prompt after an enemy faint
    never appears (your stored SHIFT/SET preference is restored
    untouched after each battle).
  - **No items in battle** — every battle use is refused with
    "Items can't be used in battle!" and spends no turn or item.  Poké
    Balls are exempt, so catching still works; enemy trainers keep their
    items.
  - **Level caps by gym badge** — 0 badges: 12, 1: 21, 2: 24, 3: 35,
    4: 43, 5: 50, 6: 53, 7: 55.  At the cap a mon gains no exp (stat exp
    still accrues like a max-level mon) and RARE CANDY is refused; gain
    resumes the moment the next badge lifts the cap.  After the 8th
    badge there is no cap at all.

## [1.9.3] - 2026-08-03

### Fixed

- Nidoran♂ and Nidoran♀ now appear in the wild.  The species resolution
  looked them up by display name, but the gendered display names
  ("NIDORAN♂" / "NIDORAN♀") both normalize to "NIDORAN" while the tables
  spelled them "Nidoran_m" / "Nidoran-f", so every Nidoran encounter,
  learnset and TM/HM slot was silently dropped.  Species resolution now
  falls back to the registry ids (NIDORAN_M / NIDORAN_F), keeping the two
  genders distinct.

## [1.9.2] - 2026-08-02

### Fixed

- Route 13 blue screen while surfing: Yellow Legacy adds a surf encounter
  table to maps the Red/Blue data has none for (Route 13), and the patch
  landed without a rate — a nil rate crashed the encounter roll on the
  first surf step.  Encounter patches now always carry a rate: the map's
  own existing water rate, else its grass rate, else the engine's vanilla
  surf rate.  A map's existing rates are unchanged.

## [1.9.1] - 2026-08-02

### Fixed

- Brock's rematch team (L64-65 OMASTAR / ONIX / KABUTOPS / GOLEM /
  NINETALES / AERODACTYL) now applies.  It was skipped because the hack
  does not rebalance Brock's main team, so trainers.lua omits the class;
  a class without a rebalanced team now appends the rematch team to its
  live vanilla parties instead (the rematch team never takes index 1).

## [1.9.0] - 2026-08-02

### Added

- The Crystal Tear post-game quest: after beating the Hall of Fame with
  all 150 obtainable species caught (Mew excluded -- it cannot be
  obtained), Professor Oak gifts the CRYSTAL TEAR key item.  Using it in
  Cerulean Cave B1F once Mewtwo is dealt with plays the "MEW!" reveal
  with Mew's cry and starts a battle with a level-75 Mew carrying
  PSYCHIC / MEGA PUNCH / AMNESIA / SOFTBOILED.  Whatever the outcome
  (win, catch, flee or loss) the tear then shatters and leaves the bag:
  the encounter is one shot for good.
- `check_crystal_tear_gift` script verb (the Oak gift condition:
  Hall of Fame + 150 owned, Mew excluded).

## [1.8.0] - 2026-08-02

### Changed

- The Rival's Eevee / Eeveelution is replaced with the starter line that
  matches his route, so the Rival carries a full starter the whole game:
  Bulbasaur line for the Jolteon route, Charmander line for the Flareon
  route, and Squirtle line for the Vaporeon route (Oak's Lab through
  Champion, including the champion rematch being untouched).
- Early rival battles (Oak's Lab, Route 22, Cerulean, S.S. Anne) use
  fixed party indexes in the engine's Yellow scripts, so a
  `trainer.party` hook now swaps in the route's starter line there based
  on the player's `save.rivalStarter`; the Oak's Lab fight uses the
  Jolteon-route starter (Bulbasaur) since the route is decided by its
  result.
- The Jolteon route no longer doubles up on Grass types: Exeggutor is
  replaced by Magneton on the Route 22 rematch and Champion teams (same
  levels and the Flareon team's Magneton movesets).

## [1.7.0] - 2026-08-01

### Changed

- The rival classes (OPP_RIVAL1/2/3) are now patched only when the game
  is Yellow.  On Red or Blue the rival keeps the normal counter-pick
  starter teams — the engine's `rival_battle` command selects the party
  from the player's starter choice — and the Yellow Legacy Eevee teams
  (including the Champion rematch team) never apply.  The hack is a
  Yellow hack; its Eevee rival was leaking into Red/Blue playthroughs.

## [1.6.0] - 2026-08-01

### Added

- The hack's rematch teams (`data/trainers/parties.asm` "; Rematch" rows)
  for the seven gym leaders, the Elite Four and the Champion, appended to
  each class's parties with a `rematchIndex` marker.  A trainer-rematch
  mod (Trainer Rematch 0.2.0+) reads the marker and uses the team when it
  triggers a rematch; without one, nothing changes.

## [1.5.0] - 2026-08-01

### Added

- Evolution changes from the Yellow Legacy disassembly
  (`data/pokemon/evos_moves.asm`): the four trade evolutions become level
  evolutions — KADABRA at 42, MACHOKE at 38, GRAVELER at 38, HAUNTER at 42 —
  and POLIWHIRL evolves into POLIWRATH at 18 (was 25).

## [1.4.0] - 2026-08-01

### Added

- Trainer and gym-leader team updates from the Yellow Legacy disassembly
  (cRz-Shadows/Pokemon_Yellow_Legacy, data/trainers/parties.asm): 44
  classes rebalanced -- route trainers, Rocket grunts, the Rival, Gym
  Leaders, Elite Four and Champion. Levels and species follow the hack's
  teams exactly; party indexes are preserved so every battle maps to the
  same team as before.
- Only existing trainer classes are touched (no new trainers); appended
  rematch / Victory-Road battles from the hack are not ported.

## [1.0.0] - 2026-08-01

### Added

- Move changes from Yellow Legacy (TSP) PDF pages 11-14: 73 moves
  rebalanced (power/accuracy/pp), 5 type changes, 11 effect changes,
  FOCUS ENERGY functional at 2x crit, LEECH SEED flat 1/8 drain.
- Stat changes from pages 15-19: 27 species base stats rebalanced.

## [1.3.0] - 2026-08-01

### Changed

- The DRAGON PHYS toggle moved from the OPTIONS menu to the mod's own
  options in MODS > yellow_legacy_changes, using the per-mod options
  API (mod.options:define + mod.options_changed).

## [1.2.0] - 2026-08-01

### Added

- GHOST attacks now use the Special stat (Yellow Legacy type change).
- Ghost is now super effective against Psychic, fixing the Gen 1 chart
  bug that made Psychic immune.
- A **DRAGON PHYS** toggle in MODS > yellow_legacy_changes: switches
  DRAGON moves to the physical stat at runtime; persisted in options.lua,
  default OFF.

## [1.1.0] - 2026-08-01

### Added

- Learnsets for all 151 species from 'Yellow Legacy Data.xlsx' (sheet 1),
  replacing each species' level-up move list; level-1 entries seed the
  starting moves.
- TM/HM compatibility lists for 146 species (sheet 2), in TM01..HM05 order.
- Encounter changes for 57 maps (sheet 3): grass, surf and rod slot tables;
  encounter rates stay vanilla. Rod pools live behind per-map fishing
  groups for the Old, Good and Super Rods.
- Name resolution: species and move display names are resolved against the
  player's imported data at load, so the workbook's names never go stale.
