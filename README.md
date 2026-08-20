# Yellow Legacy Changes

Applies the **move changes** and **stat changes**
 from *Yellow Legacy* to the Gen 1 recompilation.

Try it: enable the mod, then check a rebalanced mon's stats in the
Pokédex, or fight with a buffed move (Solar Beam 180, Explosion 250,
Twineedle 40x2...). Ghost attacks now use the Special stat and are
super effective against Psychic, and Bug attacks are no longer super
effective against Poison; the **DRAGON PHYS** toggle in MODS > yellow_legacy_changes flips Dragon
moves to the physical stat (persisted, default OFF).

## Hard Mode

An optional challenge with three rules: **forced SET style** (no free
switch after an enemy faint), **no items in battle** (Poké Balls
excepted — catching still works; enemy trainers keep their items), and
**level caps by gym badge**.  Oak asks "Play HARD MODE?" when you start
a new game, and the **HARD MODE** row in the in-game **OPTIONS** menu
(right under BATTLE STYLE) flips a run at any time (persisted, default
OFF).

| Badges | Level cap | Badges | Level cap |
|---|---|---|---|
| 0 | 12 | 4 | 43 |
| 1 | 21 | 5 | 50 |
| 2 | 24 | 6 | 53 |
| 3 | 35 | 7 | 55 |

At the cap a Pokémon gains no experience (stat exp still accrues, like
at level 100) and RARE CANDY is refused; gaining resumes the moment the
next badge lifts the cap.  After the **8th badge there is no cap**.
Mons already past the cap when Hard Mode is switched on just earn
nothing until the cap catches up — nothing is rolled back.

## Crystal Tear quest (post-game)

After beating the Hall of Fame with all 150 obtainable species caught
(Mew excluded -- it cannot be obtained in-game), talk to Professor Oak
in his lab: he gifts the **CRYSTAL TEAR** key item.  Take it to
**Cerulean Cave B1F** once Mewtwo has been dealt with (defeated,
caught or fled) and use it from the bag: a "MEW!" reveal plays with
Mew's cry, then a **level-75 Mew** appears carrying PSYCHIC /
MEGA PUNCH / AMNESIA / SOFTBOILED.  Whatever the outcome -- win, catch,
flee, or lose -- the **CRYSTAL TEAR shatters** and leaves the bag: the
encounter is one shot for good.

Tables show the **new values**; `(+X)` / `(-X)` marks how much the value
moved from vanilla.

## Move changes

| Move | Power | Acc | PP | Change |
|---|---|---|---|---|
| Barrage | 20 (+5) | 100% (+15) | 20 | Damage & accuracy buff |
| Bind | 15 | 95% (+10) | 20 | Accuracy buff |
| Comet Punch | 25 (+7) | 100% (+15) | 25 (+10) | Damage, accuracy & PP buff |
| Constrict | 40 (+30) | 100% | 35 | Large damage buff |
| Disable | — | 75% (+20) | 20 | Accuracy buff |
| Dizzy Punch | 70 | 100% | 20 (+10) | 10% confuse chance |
| Double Slap | 20 (+5) | 100% (+15) | 35 (+25) | Accuracy buff |
| Double-Edge | 120 (+20) | 100% | 10 (-5) | Damage buff, PP nerf |
| Explosion | 250 (+80) | 100% | 5 | Large damage buff |
| Focus Energy | — | — | 30 | Functional: 2x crit rate |
| Fury Attack | 15 | 100% (+15) | 20 | Accuracy buff |
| Fury Swipes | 20 (+2) | 100% (+20) | 15 | Damage & accuracy buff |
| Glare | — | 90% (+15) | 30 | Accuracy buff |
| Mega Kick | 120 | 85% (+10) | 10 (+5) | Accuracy & PP buff |
| Pay Day | 60 (+20) | 100% | 20 | Damage buff |
| Rage | 60 (+40) | 100% | 20 | Large damage buff |
| Razor Wind | 80 | 100% (+25) | 10 | Functions like Hyper Beam |
| Selfdestruct | 200 (+70) | 100% | 5 | Large damage buff |
| Skull Bash | 100 | 100% | 15 | Functions like Hyper Beam |
| Soft-Boiled | — | — | 5 (-5) | PP nerf |
| Sonic Boom | — | 100% (+10) | 20 | Accuracy buff |
| Supersonic | — | 70% (+15) | 20 | Accuracy buff |
| Tackle | 35 | 100% (+5) | 35 | Accuracy buff |
| Take Down | 95 (+5) | 100% (+15) | 20 | Damage & accuracy buff |
| Transform | — | 100% | 10 | Increased priority |
| Tri Attack | 85 (+5) | 100% | 15 (+5) | 30% burn chance |
| Fire Punch | 70 (-5) | 100% | 15 | Damage nerf, burn chance up |
| Fire Spin | 15 | 85% (+15) | 15 | Accuracy buff |
| Blizzard | 120 | 85% (-5) | 5 | Accuracy nerf |
| Ice Punch | 70 (-5) | 100% | 15 | Damage nerf |
| Thunder | 120 | 85% (+15) | 5 (-5) | Accuracy buff, PP nerf |
| ThunderPunch | 70 (-5) | 100% | 15 | Damage nerf |
| Fly | 70 | 100% (+5) | 15 | Accuracy buff |
| Gust | 40 | 100% | 35 | Now **Flying** type |
| Sky Attack | 120 (-20) | 85% (-5) | 5 | No charge-up turn |
| Wing Attack | 60 (+25) | 100% | 35 | Large damage buff |
| Cut | 55 (+5) | 100% (+5) | 30 | Now **Bug** type |
| Leech Life | 50 (+30) | 100% | 25 (+10) | Large damage & PP buff |
| Pin Missile | 20 (+6) | 100% (+15) | 30 (+10) | Damage, accuracy & PP buff |
| Twineedle | 40×2 (+15) | 100% | 20 | Large damage buff |
| Absorb | 30 (+10) | 100% | 25 (+5) | Damage & PP buff |
| Egg Bomb | 100 | 100% (+25) | 10 | Now **Grass** type |
| Leech Seed | — | 90% | 10 | Drains 1/8 HP per turn |
| Mega Drain | 65 (+25) | 100% | 20 (+10) | Large damage & PP buff |
| Petal Dance | 90 (+20) | 100% | 20 | Damage buff |
| Solar Beam | 180 (+60) | 100% | 10 | Massive damage buff |
| Vine Whip | 40 (+5) | 100% | 25 (+15) | Damage & PP buff |
| Lick | 40 (+20) | 100% | 30 | Damage buff |
| Night Shade | 60 (+60) | 100% | 15 | No longer fixed damage |
| Rock Slide | 75 | 95% (+5) | 10 | 10% flinch chance |
| Rock Throw | 50 | 95% (+30) | 25 (+10) | Accuracy & PP buff |
| Bone Club | 65 | 100% (+15) | 20 | Accuracy buff |
| Bonemerang | 50×2 | 90% | 20 (+10) | PP buff |
| Dig | 70 (-30) | 100% | 10 | Damage nerf |
| Bubble | 10 (-10) | 100% | 30 | Damage nerf |
| Clamp | 35 | 85% (+10) | 10 | Accuracy buff |
| Crabhammer | 110 (+20) | 100% (+15) | 10 | Damage & accuracy buff |
| Hydro Pump | 120 | 85% (+5) | 10 (+5) | Accuracy & PP buff |
| Waterfall | 70 (-10) | 100% | 15 | Damage nerf, 10% flinch |
| Psywave | — | 95% (+15) | 15 | Improved formula |
| Hi Jump Kick | 120 (+35) | 90% | 20 | Large damage buff |
| Jump Kick | 90 (+20) | 95% | 25 | Damage buff |
| Karate Chop | 50 | 95% (-5) | 25 | Now **Fighting** type |
| Low Kick | 50 | 100% (+10) | 20 | Accuracy buff |
| Rolling Kick | 70 (+10) | 100% (+15) | 15 | Damage & accuracy buff |
| Submission | 80 | 100% (+20) | 25 | Accuracy buff |
| Acid | 65 (+25) | 100% | 30 | Large damage buff |
| Poison Gas | — | 85% (+30) | 35 | Accuracy buff |
| PoisonPowder | — | 90% (+15) | 40 | Accuracy buff |
| Poison Sting | 35 (+20) | 100% | 35 | Damage buff |
| Sludge | 90 (+25) | 100% | 20 | Large damage buff |
| Smog | 40 | 80% (+10) | 20 | Accuracy buff |
| Slam | 80 | 100% (+25) | 20 | Now **Dragon** type, 10% flinch |

## Stat changes

| Pokémon | HP | Atk | Def | SPC | Spd |
|---|---|---|---|---|---|
| Charmander | 39 | 52 | 43 | 55 (+5) | 65 |
| Charmeleon | 58 | 64 | 58 | 70 (+5) | 80 |
| Charizard | 78 | 84 | 78 | 95 (+10) | 100 |
| Arbok | 62 (+2) | 95 (+10) | 69 | 65 | 90 (+10) |
| Pikachu | 45 (+10) | 55 | 50 (+20) | 55 (+5) | 90 |
| Clefable | 95 | 70 | 73 | 95 (+10) | 60 |
| Vulpix | 45 (+7) | 41 | 45 (+5) | 70 (+5) | 75 (+10) |
| Wigglytuff | 140 | 70 | 55 (+10) | 85 (+35) | 45 |
| Golbat | 75 | 80 | 70 | 75 | 100 (+10) |
| Oddish | 50 (+5) | 50 | 55 | 75 | 30 |
| Gloom | 70 (+10) | 65 | 70 | 85 | 40 |
| Vileplume | 90 (+15) | 80 | 85 | 100 | 50 |
| Venomoth | 70 | 75 (+10) | 60 | 95 (+5) | 100 (+10) |
| Diglett | 10 | 70 (+15) | 25 | 45 | 95 |
| Dugtrio | 35 | 90 (+10) | 50 | 70 | 120 |
| Ponyta | 50 | 85 | 55 | 65 | 100 (+10) |
| Rapidash | 65 | 100 | 70 | 80 | 115 (+10) |
| Farfetch'd | 62 (+10) | 75 (+10) | 65 (+10) | 68 (+10) | 70 (+10) |
| Muk | 105 | 105 | 75 | 85 (+20) | 50 |
| Onix | 75 (+40) | 80 (+35) | 160 | 65 (+35) | 85 (+15) |
| Marowak | 60 | 80 | 110 | 80 (+30) | 45 |
| Hitmonlee | 65 (+15) | 120 | 70 (+17) | 60 (+25) | 93 (+6) |
| Hitmonchan | 60 (+10) | 50 (-55) | 79 | 105 (+70) | 76 |
| Lickitung | 95 (+5) | 70 (+15) | 85 (+10) | 75 (+15) | 30 |
| Magmar | 65 | 95 | 57 | 95 (+10) | 93 |
| Eevee | 70 (+15) | 65 (+10) | 65 (+10) | 70 (+5) | 55 |
| Porygon | 75 (+10) | 70 (+10) | 70 | 95 (+20) | 40 |

## Learnset, TM/HM and encounter changes (Data.xlsx)

- **Learnsets:** all 151 species get the workbook's level-up move lists
  (sheet 1); level-1 entries become the starting moves.
- **TM/HM:** 146 species get the workbook's machine compatibility lists
  (sheet 2), in TM01..HM05 order.
- **Encounters:** 57 maps get the workbook's grass, surf and rod slot
  tables (sheet 3). Encounter rates stay vanilla; fishing uses per-map
  pools for the Old, Good and Super Rods.
- Species and move names are resolved against your imported data at load,
  so the workbook's display names always map to the right ids.

## Rematch teams

The hack's rematch teams (the seven gym leaders, the Elite Four and the
Champion, levels 64-77) ship as extra party indexes marked
`rematchIndex`.  They only become reachable with a trigger mod that reads
the marker: **[Trainer Rematch](https://github.com/ShaneMcGovernIE/trainer_rematch)
is required to fight them** — without it the teams stay dormant in the
data.

## Notes

- Trade evolutions become level evolutions, like the hack: Kadabra at 42,
  Machoke at 38, Graveler at 38, Haunter at 42.  The Poliwag line keeps its
  vanilla shape: Poliwag to Poliwhirl at level 18, Poliwhirl to Poliwrath
  with a Water Stone.
- The rival teams are patched **only on Yellow**.  On Red or Blue the
  rival keeps the normal counter-pick starter teams (the engine picks the
  party from your starter choice), so no Eevee and no Yellow Legacy rival
  content shows up there — including the Champion rematch team.
- PSYWAVE keeps its vanilla damage formula; only its accuracy is changed.
- Stat patches are partial: a stat the document does not change is
  untouched.
