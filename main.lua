-- Yellow Legacy by TSP -- move changes (pages 11-14), stat changes
-- (pages 15-19), trainer / gym-leader team updates and evolution changes
-- from the design PDF and the cRz-Shadows/Pokemon_Yellow_Legacy
-- disassembly.  Values are the NEW numbers; the patches touch only the
-- fields the document changes.
--
-- Yellow Legacy is a Yellow hack: its rival parties are Eevee-based.  On
-- Red or Blue the rival must keep the normal counter-pick starter teams
-- (the engine's rival_battle command selects the party from the player's
-- starter choice), so the rival classes -- including their rematch teams
-- -- are only patched when the running game is Yellow.
--
-- Engine behavior changes that the data cannot express ride on wrapped
-- seams (installed on game.ready, the nuzlocke pattern):
--   * FOCUS ENERGY is functional: exactly 2x the usual crit rate, instead
--     of the Gen 1 bug (faithful ruleset) or the engine's 4x (modern).
--   * LEECH SEED drains a flat 1/8 of max HP per turn, without the Gen 1
--     toxic-counter glitch.
--
-- Learnset, TM/HM, encounter and trainer-party changes ship in
-- learnsets.lua and trainers.lua (generated from 'Yellow Legacy Data.xlsx'
-- and the disassembly's data/trainers/parties.asm): species and move
-- display names are resolved against the player's imported data at load,
-- so the files work on any build without shipping a name table.
-- The Crystal Tear post-game quest ships in crystal_tear.lua (pure rows
-- and conditions, wired below on game.ready).
local applyTables, resolveTables, encounterPatchFor
-- whether the rival patches landed (true when the running game is Yellow);
-- read by applyTables, exported for tests via the exports table
local rivalPatchEnabled = false
-- resolved rival early-battle route variants (see trainers.lua
-- rivalVariants); read by the trainer.party hook below
local resolvedVariants = nil
-- load one sibling file (learnsets/trainers/rematches/hardmode/crystal_tear)
-- into a table; logs and returns nil on any failure so callers fall back
-- safely.  The data files return their tables directly.
local function loadSibling(mod, name)
  local source = mod:read(name)
  if not source then
    mod.log:error("%s missing from %s -- reinstall the mod", name, mod.path)
    return nil
  end
  local chunk, compileErr = load(source, "@" .. mod.path .. "/" .. name)
  if not chunk then
    mod.log:error("%s did not compile: %s", name, tostring(compileErr))
    return nil
  end
  local ok, data = pcall(chunk)
  if not ok then
    mod.log:error("%s failed to load: %s", name, tostring(data))
    return nil
  end
  return data
end

local function applyLegacyTables(mod)
  local merged = {}
  for _, name in ipairs({ "learnsets.lua", "trainers.lua", "rematches.lua" }) do
    local data = loadSibling(mod, name)
    if data == nil then return end
    for k, v in pairs(data) do merged[k] = v end
  end
  local resolved = applyTables(mod, merged)
  resolvedVariants = resolved and resolved.rivalVariants or nil
end

-- Pure resolution of one tables struct (the shape learnsets.lua returns)
-- against a content facade: display names -> ids.  Reads only (get/each),
-- so headless tests can drive it after the loader freezes registries.
-- Returns the resolved struct plus unknown-name counts.
resolveTables = function(content, data)
  local function norm(s) return (s:gsub("[^%w]", ""):upper()) end

  local moveId, speciesId = {}, {}
  for id, rec in content.moves:each() do
    if rec and rec.name then moveId[norm(rec.name)] = id end
  end
  local constId = {}
  for id, rec in content.pokemon:each() do
    if rec and rec.name then speciesId[norm(rec.name)] = id end
    -- trainer parties name species by ROM constant ("NIDORAN_M"), which
    -- matches the registry's ids, not the display names -- resolve against
    -- the ids themselves
    if rec then constId[norm(id)] = id end
  end

  local counts = { moves = 0, species = 0, maps = 0, trainers = 0 }
  local function moveByName(name)
    local id = moveId[norm(name)]
    if not id then counts.moves = counts.moves + 1 end
    return id
  end
  local function speciesByName(name)
    -- display names first, then ROM constants ("NIDORAN_M") / the mod's
    -- workbook spellings ("Nidoran_m", "Nidoran-f"): the gendered species
    -- display names ("NIDORAN♂" / "NIDORAN♀") both normalize to
    -- "NIDORAN", so the id map is the only way to tell them apart
    local key = norm(name)
    local id = speciesId[key] or constId[key]
    if not id then counts.species = counts.species + 1 end
    return id
  end
  local function speciesByConst(name)
    local id = constId[norm(name)]
    if not id then counts.species = counts.species + 1 end
    return id
  end

  local out = { learnsets = {}, tmhm = {}, encounters = {}, rods = {},
                trainers = {}, rematches = {}, rivalVariants = {} }

  for name, entries in pairs(data.learnsets or {}) do
    local id = speciesByName(name)
    if id then
      local learnset, level1 = {}, {}
      for _, e in ipairs(entries) do
        local mid = moveByName(e[2])
        if mid then
          learnset[#learnset + 1] = { level = e[1], move = mid }
          if e[1] == 1 then level1[#level1 + 1] = mid end
        end
      end
      out.learnsets[id] = { learnset = learnset, level1 = level1 }
    end
  end

  for name, moves in pairs(data.tmhm or {}) do
    local id = speciesByName(name)
    if id then
      local list = {}
      for _, m in ipairs(moves) do
        local mid = moveByName(m)
        if mid then list[#list + 1] = mid end
      end
      out.tmhm[id] = list
    end
  end

  for mid, enc in pairs(data.encounters or {}) do
    local entry = {}
    if enc.grass and #enc.grass > 0 then
      local slots = {}
      for _, s in ipairs(enc.grass) do
        local sp = speciesByName(s[2])
        if sp then slots[#slots + 1] = { level = s[1], species = sp } end
      end
      if #slots > 0 then entry.grass = slots end
    end
    if enc.water and #enc.water > 0 then
      local slots = {}
      for _, s in ipairs(enc.water) do
        local sp = speciesByName(s[2])
        if sp then slots[#slots + 1] = { level = s[1], species = sp } end
      end
      if #slots > 0 then entry.water = slots end
    end
    for rod, slots in pairs(enc.rods or {}) do
      local list = {}
      for _, s in ipairs(slots) do
        local sp = speciesByName(s[2])
        if sp then list[#list + 1] = { species = sp, level = s[1] } end
      end
      if #list > 0 then
        out.rods[rod] = out.rods[rod] or {}
        out.rods[rod][mid] = list
      end
    end
    if next(entry) then
      if content.encounters:get(mid) then
        out.encounters[mid] = entry
      else
        counts.maps = counts.maps + 1
      end
    end
  end

  -- trainers: whole-party replacement per class, party indexes preserved.
  -- A class with any unknown species is dropped whole (never partial).
  for id, entry in pairs(data.trainers or {}) do
    local ok, parties = true, {}
    for _, party in ipairs(entry.parties or {}) do
      local slots = {}
      for _, s in ipairs(party) do
        local sp = speciesByConst(s.species)
        if not sp then
          ok = false
          break
        end
        slots[#slots + 1] = { level = s.level, species = sp }
      end
      if not ok then break end
      parties[#parties + 1] = slots
    end
    if ok and #parties > 0 then
      out.trainers[id] = { parties = parties }
    else
      counts.trainers = counts.trainers + 1
    end
  end

  -- rematches: the hack's "; Rematch" teams, same resolution as trainer
  -- parties (ROM constants); a team with any unknown species is dropped
  -- whole, like a trainer class
  for id, team in pairs(data.rematches or {}) do
    local ok, slots = true, {}
    for _, s in ipairs(team) do
      local sp = speciesByConst(s.species)
      if not sp then
        ok = false
        break
      end
      slots[#slots + 1] = { level = s.level, species = sp }
    end
    if ok and #slots > 0 then
      out.rematches[id] = slots
    else
      counts.trainers = counts.trainers + 1
    end
  end

  -- rivalVariants: early-battle route variants (base starter lines), same
  -- species resolution as trainer parties; a party with any unknown
  -- species is dropped whole.  Shape: [oppClass][partyIndex][rivalStarter]
  -- with rivalStarter 1 JOLTEON / 2 FLAREON / 3 VAPOREON.
  for id, byParty in pairs(data.rivalVariants or {}) do
    local outParties = {}
    for partyIndex, byStarter in pairs(byParty) do
      local outStarters = {}
      for starter, party in pairs(byStarter) do
        local ok, slots = true, {}
        for _, s in ipairs(party) do
          local sp = speciesByConst(s.species)
          if not sp then
            ok = false
            break
          end
          slots[#slots + 1] = { level = s.level, species = sp }
        end
        if ok then outStarters[tonumber(starter)] = slots end
      end
      if next(outStarters) then outParties[tonumber(partyIndex)] = outStarters end
    end
    if next(outParties) then out.rivalVariants[id] = outParties end
  end

  return out, counts
end

-- Pure application of one tables struct (the shape learnsets.lua returns),
-- so headless tests can drive the resolver + patch mechanics with fixture
-- names.  Species and move names are display names resolved against the
-- merged view; unknown names are counted and skipped.
applyTables = function(mod, data)
  local resolved, counts = resolveTables(mod.content, data)
  if resolved == nil then return end

  -- the hack is Yellow-based; its rival teams are Eevee parties, which on
  -- Red/Blue would break the rival's normal counter-pick starter
  -- selection (rival_battle picks the party from the player's starter).
  -- The rival classes are patched only when the running game is Yellow.
  local GameVersion = require("src.core.GameVersion")
  rivalPatchEnabled = GameVersion.isYellow()
  local RIVAL_CLASSES = { OPP_RIVAL1 = true, OPP_RIVAL2 = true,
                          OPP_RIVAL3 = true }

  -- learnsets: replace wholesale (level 1 entries also seed level1Moves)
  for id, entry in pairs(resolved.learnsets) do
    local patch = { learnset = entry.learnset }
    if #entry.level1 > 0 then patch.level1Moves = entry.level1 end
    mod.content.pokemon:patch(id, patch)
  end

  -- tmhm: the workbook's per-species machine lists, in TM/HM order
  for id, list in pairs(resolved.tmhm) do
    mod.content.pokemon:patch(id, { tmhm = list })
  end

  -- encounters: grass + surf slot tables.  A rate is always carried into
  -- the patch: deep-merge preserves unpatched leaves, so maps whose base
  -- data HAS a water/grass table keep their own rate, while a table the
  -- base lacks (Yellow Legacy adds surf where the Red/Blue data has none,
  -- e.g. Route 13) still rolls instead of crashing on a nil rate.  The
  -- fallback chain borrows the map's sibling table, then the engine's
  -- vanilla surf rate.
  encounterPatchFor = function(base, entry)
    local patch = {}
    if entry.grass then
      patch.grass = { slots = entry.grass }
      local rate = base and base.grass and base.grass.rate
                   or (base and base.water and base.water.rate) or 5
      patch.grass.rate = rate
    end
    if entry.water then
      patch.water = { slots = entry.water }
      local rate = base and base.water and base.water.rate
                   or (base and base.grass and base.grass.rate) or 5
      patch.water.rate = rate
    end
    return patch
  end
  for mid, entry in pairs(resolved.encounters) do
    mod.content.encounters:patch(mid, encounterPatchFor(
      mod.content.encounters:get(mid), entry))
  end

  -- fishing: per-map rod pools behind the three rod keys
  local poolKeys = { OLD_ROD = "legacyOldRod", GOOD_ROD = "legacyGoodRod",
                     SUPER_ROD = "legacySuperRod" }
  local fishing, pools = {}, {}
  for rod, perMap in pairs(resolved.rods) do
    if next(perMap) then
      fishing[rod] = { perMap = poolKeys[rod] }
      pools[poolKeys[rod]] = perMap
    end
  end
  if next(fishing) then
    mod.content.field:override("fishing", fishing)
    for key, perMap in pairs(pools) do
      mod.content.field:patch(key, perMap)
    end
  end

  -- trainers: whole-party replacement per class (party indexes preserved,
  -- so every battle that references an index still maps to the right team)
  for id, entry in pairs(resolved.trainers) do
    if RIVAL_CLASSES[id] and not rivalPatchEnabled then
      -- Red/Blue: keep the imported counter-pick starter teams untouched
    else
      mod.content.trainers:patch(id, entry)
    end
  end

  -- rematches: append the hack's rematch team to the class's parties and
  -- mark its index, so a trainer-rematch mod can pick the team.  Classes
  -- this mod rebalances append to the rebalanced parties; a class it does
  -- not rebalance (Brock keeps the vanilla team, so trainers.lua omits
  -- him) appends to the live base parties instead, so its rematch team is
  -- never lost.  The rematch team never takes index 1 of a class it does
  -- not own.  Rival rematch teams are Yellow Legacy content, so they
  -- follow the same version gate.
  for id, team in pairs(resolved.rematches) do
    if RIVAL_CLASSES[id] and not rivalPatchEnabled then
      -- Red/Blue: the rival keeps its normal teams, rematch included
    else
      local entry = resolved.trainers[id]
      if not entry then
        local base = mod.content.trainers:get(id)
        if base and type(base.parties) == "table" and #base.parties > 0 then
          entry = { parties = base.parties }
        end
      end
      if not entry then
        mod.log:warn("rematch team for %s skipped (no parties to append to)", id)
      else
        local parties = entry.parties
        local patch = { parties = {}, rematchIndex = #parties + 1 }
        for i = 1, #parties do patch.parties[i] = parties[i] end
        patch.parties[#patch.parties + 1] = team
        mod.content.trainers:patch(id, patch)
      end
    end
  end

  if counts.moves > 0 then
    mod.log:warn("%d unknown move names skipped", counts.moves)
  end
  if counts.species > 0 then
    mod.log:warn("%d unknown species names skipped", counts.species)
  end
  if counts.maps > 0 then
    mod.log:warn("%d unknown maps skipped", counts.maps)
  end
  if counts.trainers > 0 then
    mod.log:warn("%d trainer classes skipped", counts.trainers)
  end
  return resolved
end
return function(mod)
  local MOVES = {
    -- Normal / general
    BARRAGE = { power = 20, accuracy = 100 },
    BIND = { accuracy = 95 },
    COMET_PUNCH = { power = 25, accuracy = 100, pp = 25 },
    CONSTRICT = { power = 40 },
    DISABLE = { accuracy = 75 },
    DIZZY_PUNCH = { pp = 20, effect = "CONFUSION_SIDE_EFFECT" },
    DOUBLESLAP = { power = 20, accuracy = 100, pp = 35 },
    DOUBLE_EDGE = { power = 120, pp = 10 },
    EXPLOSION = { power = 250 },
    FOCUS_ENERGY = { pp = 30 },
    FURY_ATTACK = { accuracy = 100 },
    FURY_SWIPES = { power = 20, accuracy = 100 },
    GLARE = { accuracy = 90 },
    MEGA_KICK = { accuracy = 85, pp = 10 },
    PAY_DAY = { power = 60 },
    RAGE = { power = 60 },
    RAZOR_WIND = { power = 80, accuracy = 100, effect = "HYPER_BEAM_EFFECT" },
    SELFDESTRUCT = { power = 200 },
    SKULL_BASH = { power = 100, accuracy = 100, effect = "HYPER_BEAM_EFFECT" },
    SOFTBOILED = { pp = 5 },
    SONICBOOM = { accuracy = 100 },
    SUPERSONIC = { accuracy = 70 },
    TACKLE = { accuracy = 100 },
    TAKE_DOWN = { power = 95, accuracy = 100 },
    TRANSFORM = { pp = 10, priority = 1 },
    TRI_ATTACK = { power = 85, pp = 15, effect = "BURN_SIDE_EFFECT2" },
    -- Fire / Ice / Electric
    FIRE_PUNCH = { power = 70, effect = "BURN_SIDE_EFFECT2" },
    FIRE_SPIN = { accuracy = 85 },
    BLIZZARD = { accuracy = 85 },
    ICE_PUNCH = { power = 70 },
    THUNDER = { accuracy = 85, pp = 5 },
    THUNDERPUNCH = { power = 70 },
    -- Flying
    FLY = { accuracy = 100 },
    GUST = { type = "FLYING" },
    SKY_ATTACK = { power = 120, accuracy = 85, effect = "NO_ADDITIONAL_EFFECT" },
    WING_ATTACK = { power = 60 },
    -- Bug
    CUT = { power = 55, accuracy = 100, type = "BUG" },
    LEECH_LIFE = { power = 50, pp = 25 },
    PIN_MISSILE = { power = 20, accuracy = 100, pp = 30 },
    TWINEEDLE = { power = 40 },
    -- Grass
    ABSORB = { power = 30, pp = 25 },
    EGG_BOMB = { accuracy = 100, type = "GRASS" },
    LEECH_SEED = { accuracy = 90 },
    MEGA_DRAIN = { power = 65, pp = 20 },
    PETAL_DANCE = { power = 90 },
    SOLARBEAM = { power = 180 },
    VINE_WHIP = { power = 40, pp = 25 },
    -- Ghost / Rock / Ground
    LICK = { power = 40 },
    NIGHT_SHADE = { power = 60, effect = "NO_ADDITIONAL_EFFECT" },
    ROCK_SLIDE = { accuracy = 95, effect = "FLINCH_SIDE_EFFECT1" },
    ROCK_THROW = { accuracy = 95, pp = 25 },
    BONE_CLUB = { accuracy = 100 },
    BONEMERANG = { pp = 20 },
    DIG = { power = 70 },
    -- Water
    BUBBLE = { power = 10 },
    CLAMP = { accuracy = 85 },
    CRABHAMMER = { power = 110, accuracy = 100 },
    HYDRO_PUMP = { accuracy = 85, pp = 10 },
    WATERFALL = { power = 70, effect = "FLINCH_SIDE_EFFECT1" },
    PSYWAVE = { accuracy = 95 },
    -- Fighting
    HI_JUMP_KICK = { power = 120 },
    JUMP_KICK = { power = 90 },
    KARATE_CHOP = { accuracy = 95, type = "FIGHTING" },
    LOW_KICK = { accuracy = 100 },
    ROLLING_KICK = { power = 70, accuracy = 100 },
    SUBMISSION = { accuracy = 100 },
    -- Poison
    ACID = { power = 65 },
    POISON_GAS = { accuracy = 85, pp = 35 },
    POISONPOWDER = { accuracy = 90 },
    POISON_STING = { power = 35 },
    SLUDGE = { power = 90 },
    SMOG = { accuracy = 80 },
    -- Dragon / misc
    SLAM = { accuracy = 100, type = "DRAGON", effect = "FLINCH_SIDE_EFFECT1" },
  }

  local STATS = {
    CHARMANDER = { baseStats = { special = 55 } },
    CHARMELEON = { baseStats = { special = 70 } },
    CHARIZARD = { baseStats = { special = 95 } },
    ARBOK = { baseStats = { hp = 62, attack = 95, speed = 90 } },
    PIKACHU = { baseStats = { hp = 45, defense = 50, special = 55} },
    CLEFABLE = { baseStats = { special = 95 } },
    VULPIX = { baseStats = { hp = 45, defense = 45, special = 70, speed = 75 } },
    WIGGLYTUFF = { baseStats = { defense = 55, special = 85 } },
    GOLBAT = { baseStats = { speed = 100 } },
    ODDISH = { baseStats = { hp = 50 } },
    GLOOM = { baseStats = { hp = 70 } },
    VILEPLUME = { baseStats = { hp = 90 } },
    VENOMOTH = { baseStats = { attack = 75, special = 95, speed = 100 } },
    DIGLETT = { baseStats = { attack = 70 } },
    DUGTRIO = { baseStats = { attack = 90 } },
    PONYTA = { baseStats = { speed = 100 } },
    RAPIDASH = { baseStats = { speed = 115 } },
    FARFETCHD = { baseStats = {
      hp = 62, attack = 90, defense = 65, special = 68, speed = 70,
    } },
    MUK = { baseStats = { special = 85 } },
    ONIX = { baseStats = { hp = 75, attack = 80, special = 65, speed = 85 } },
    MAROWAK = { baseStats = { special = 80 } },
    HITMONLEE = { baseStats = { hp = 65, defense = 70, special = 60, speed = 93 } },
    HITMONCHAN = { baseStats = { hp = 60, attack = 50, special = 105 } },
    LICKITUNG = { baseStats = { hp = 95, attack = 70, defense = 85, special = 75 } },
    MAGMAR = { baseStats = { special = 95 } },
    EEVEE = { baseStats = { hp = 70, attack = 65, defense = 65, special = 70 } },
    PORYGON = { baseStats = { hp = 75, attack = 70, special = 95 } },
  }

  -- Patch unconditionally: vanilla always carries every id, and a total
  -- conversion that tombstoned one simply wins over this op.  Deep
  -- registries accept patch on ids with no base record, which is also
  -- what keeps the headless fixture test able to verify the merged view.
  for id, patch in pairs(MOVES) do
    mod.content.moves:patch(id, patch)
  end
  for id, patch in pairs(STATS) do
    mod.content.pokemon:patch(id, patch)
  end

  -- Yellow Legacy evolution changes (data/pokemon/evos_moves.asm): the
  -- four trade evolutions become level evolutions, while the Poliwag line
  -- keeps its vanilla Gen 1 shape (Poliwag -> Poliwhirl at level 18,
  -- Poliwhirl -> Poliwrath by Water Stone).  Each of these species has
  -- exactly one evolution row, so the whole field is replaced.
  local EVOS = {
    KADABRA = { evolutions = { { method = "LEVEL", level = 42, species = "ALAKAZAM" } } },
    MACHOKE = { evolutions = { { method = "LEVEL", level = 38, species = "MACHAMP" } } },
    GRAVELER = { evolutions = { { method = "LEVEL", level = 38, species = "GOLEM" } } },
    HAUNTER = { evolutions = { { method = "LEVEL", level = 42, species = "GENGAR" } } },
    POLIWAG = { evolutions = { { method = "LEVEL", level = 18, species = "POLIWHIRL" } } },
    POLIWHIRL = { evolutions = { { method = "ITEM", item = "WATER_STONE", species = "POLIWRATH" } } },
  }
  for id, patch in pairs(EVOS) do
    mod.content.pokemon:patch(id, patch)
  end

  -- Yellow Legacy type changes: GHOST attacks become special, the Gen 1
  -- chart bug that made Psychic immune to Ghost is fixed (Ghost is now
  -- super effective against Psychic), and the Gen 1 bug that made Bug
  -- super effective against Poison is removed (Bug is now neutral to
  -- Poison).  Patch, not override: the type records and chart rows come
  -- from the engine's own registrations, and a total conversion that
  -- replaced them wins over this op.
  mod.content.type_chart:patch("GHOST", { category = "special" })
  mod.content.type_chart:patch("GHOST>PSYCHIC_TYPE", { multiplier = 20 })
  mod.content.type_chart:patch("BUG>POISON", { multiplier = 10 })

  applyLegacyTables(mod)

  -- ---- Hard Mode rules (hardmode.lua) ----
  -- Pure helpers: forced SET style, no items in battle (balls aside) and
  -- badge-gated level caps.  The gameplay wraps live below; the pure
  -- table is also what the headless test drives.
  local HardMode = {}
  do
    local loaded = loadSibling(mod, "hardmode.lua")
    if type(loaded) == "table" then HardMode = loaded end
  end

  -- ---- Crystal Tear post-game quest (crystal_tear.lua) ----
  local CrystalTear = {}
  do
    local loaded = loadSibling(mod, "crystal_tear.lua")
    if type(loaded) == "table" then CrystalTear = loaded end
  end

  -- the key item Oak hands over once the Hall of Fame run is complete
  mod.content.items:register("CRYSTAL_TEAR", {
    id = "CRYSTAL_TEAR", name = "CRYSTAL TEAR",
    price = 0, tossable = false, keyItem = true,
  })

  -- the gift script verb: lastCheck = Hall of Fame + 150 species owned
  -- (Mew excluded).  Used by the rows prepended to Oak's OAKS_LAB talk.
  mod.content.commands:register("check_crystal_tear_gift", function(ctx)
    ctx.lastCheck = CrystalTear.legacyComplete(ctx and ctx.save)
  end)

  -- Mew's level-up set so the level-75 wild Mew carries a strong moveset
  -- (PSYCHIC / MEGA_PUNCH / AMNESIA / SOFTBOILED at 75)
  mod.content.pokemon:patch("MEW", { learnset = CrystalTear.mewLearnset() })

  mod.events:on("game.ready", function(ev)
    local Strings = require("src.core.Strings")
    local Badges = require("src.inventory.Badges")

    -- ---- Hard Mode: forced SET battle style ----
    -- The free-switch prompt reads save.options.battleStyle at the moment
    -- the enemy's next mon is sent out (EnemySendOutFirstMon), so the
    -- wrap forces the read to "set" for the duration of that method only
    -- -- the player's stored preference is restored untouched afterwards.
    local BattleState = require("src.battle.BattleState")
    local vanillaEnemyMonFainted = BattleState.enemyMonFainted
    BattleState.enemyMonFainted = function(self)
      local opts = self.game and self.game.save and self.game.save.options
      local prev = opts and opts.battleStyle
      -- no options table (stub/broken save): fall through, never force a
      -- style we cannot restore afterwards
      local forced = opts ~= nil and prev ~= "set"
        and mod.options:get("hardMode") == true
      if forced then opts.battleStyle = "set" end
      local ok, err = pcall(vanillaEnemyMonFainted, self)
      if forced then opts.battleStyle = prev end
      if not ok then error(err, 0) end
    end

    -- ---- Hard Mode: no items in battle (Poké Balls excepted) ----
    -- Every battle use routes through ItemEffects.use (BagMenu keeps the
    -- ball result and calls BattleState:throwBall itself), so the wrap
    -- covers healers, X items, POKé DOLL, flutes and machines alike.
    -- A "failed" result keeps the item, leaves the bag open and spends
    -- no turn.  RARE CANDY sets exp by level directly (bypassing the
    -- exp hook below), so it gets its own field-use gate at the cap.
    local ItemEffects = require("src.inventory.ItemEffects")
    local vanillaItemUse = ItemEffects.use
    ItemEffects.use = function(data, save, itemId, target, battle, moveIndex, ow)
      if mod.options:get("hardMode") == true then
        if battle and not ItemEffects.isBall(itemId) then
          return "failed", { Strings("Items can't be\nused in battle!") }
        end
        if itemId == "RARE_CANDY"
           and HardMode.blocksRareCandy(data, target,
                                        Badges.count(data, save)) then
          return "failed", { Strings("It won't have\nany effect.") }
        end
      end
      return vanillaItemUse(data, save, itemId, target, battle, moveIndex, ow)
    end
  end)

  mod.events:on("game.ready", function()
    local Strings = require("src.core.Strings")
    local Flags = require("src.script.Flags")

    -- Oak's lab talk: prepend the gift branch to the base dialogue.  The
    -- branch is a mod-owned script (check_flag/set_flag rows are plain
    -- EVENT_* flags, no mod: fields), and it only replaces the base when
    -- the vanilla resolution really is the base script -- another mod's
    -- talk override for the same constant still wins.
    local MapScripts = require("src.script.MapScripts")
    local vanillaTalkScript = MapScripts.talkScript
    local oakGiftScript
    local function buildOakGiftScript()
      if oakGiftScript then return oakGiftScript end
      local base = MapScripts.baseTalk("OAKS_LAB", "TEXT_OAKSLAB_OAK1")
      if not base then return nil end
      local gift = CrystalTear.giftRows()
      local rows = {}
      for i, row in ipairs(gift) do rows[i] = row end
      for i, row in ipairs(base) do rows[#gift + i] = row end
      oakGiftScript = rows
      return rows
    end
    MapScripts.talkScript = function(mapId, textConst)
      if mapId == "OAKS_LAB" and textConst == "TEXT_OAKSLAB_OAK1" then
        local base = MapScripts.baseTalk(mapId, textConst)
        local resolved = vanillaTalkScript(mapId, textConst)
        if base and resolved == base then
          local script = buildOakGiftScript()
          if script then return script end
        end
      end
      return vanillaTalkScript(mapId, textConst)
    end

    -- the bag list instance, latched so the tear's use flow can close
    -- the bag before the reveal script runs (the overworld's script
    -- runner only ticks while the overworld is the top stack state)
    local activeBag = nil
    local BagMenu = require("src.ui.BagMenu")
    local vanillaBagNew = BagMenu.new
    BagMenu.new = function(game, opts)
      local list = vanillaBagNew(game, opts)
      activeBag = list
      return list
    end

    -- the reveal script, deferred one update when a map script is still
    -- running (e.g. a background NPC walk): it must not be started while
    -- the runner is busy, and the runner only ticks when the overworld
    -- is the top state -- which closing the bag just restored
    local pendingMewScript = nil
    local ScriptRunner = require("src.script.ScriptRunner")
    local vanillaRunnerUpdate = ScriptRunner.update
    ScriptRunner.update = function(self)
      vanillaRunnerUpdate(self)
      if pendingMewScript and not self:isRunning() then
        local rows = pendingMewScript
        pendingMewScript = nil
        self:run(rows, {})
      end
    end

    -- the tear's field use: only on CERULEAN_CAVE_B1F, only after Mewtwo
    -- is gone, only once -- and only for a player who earned it
    local ItemEffects = require("src.inventory.ItemEffects")
    local vanillaUse = ItemEffects.use
    ItemEffects.use = function(data, save, itemId, target, battle, moveIndex, ow)
      if itemId == "CRYSTAL_TEAR" then
        if battle then
          return "failed", { Strings("OAK: %s!\nThis isn't the\ntime to use that!",
                                     save.player.name) }
        end
        if Flags.get(save, "EVENT_BEAT_MEW") then
          return "failed", { Strings("It won't have\nany effect.") }
        end
        if not (ow and ow.map and ow.map.id == "CERULEAN_CAVE_B1F") then
          return "failed", { Strings("The CRYSTAL TEAR\nisn't reacting...") }
        end
        if not Flags.get(save, "EVENT_BEAT_MEWTWO") then
          return "failed", { Strings("The CRYSTAL TEAR\nquivers faintly...") }
        end
        if not CrystalTear.legacyComplete(save) then
          return "failed", { Strings("The CRYSTAL TEAR\nlies dormant...") }
        end
        -- Mew reveals itself: close the bag, then the "MEW!" cry text
        -- and the level-75 battle run as a map script
        if activeBag then activeBag:close() end
        if ow and ow.runner then
          if ow.runner:isRunning() then
            pendingMewScript = CrystalTear.mewRows()
          else
            ow.runner:run(CrystalTear.mewRows(), {})
          end
        end
        return "kept", {}
      end
      return vanillaUse(data, save, itemId, target, battle, moveIndex, ow)
    end
  end)

  mod.events:on("game.ready", function()
    local Stats = require("src.pokemon.Stats")
    local Damage = require("src.battle.Damage")

    -- The engine's own high-crit list (src/battle/Damage.lua), copied so
    -- the wrap below stays an exact mirror of the vanilla roll.
    local HIGH_CRIT = {
      KARATE_CHOP = true, RAZOR_LEAF = true, CRABHAMMER = true, SLASH = true,
    }
    local function shl(x) return math.min(255, x * 2) end

    local vanillaCritRoll = Damage.critRoll
    Damage.critRoll = function(ruleset, attacker, moveId, rng, highCrit)
      if not attacker.focusEnergy then
        return vanillaCritRoll(ruleset, attacker, moveId, rng, highCrit)
      end
      -- focus energy: exactly 2x the usual crit rate (b doubles) in every
      -- ruleset, replacing both the Gen 1 bug and the engine's 4x
      local speed
      if ruleset.critUsesBaseSpeed == false then
        speed = Stats.applyStage(attacker.curStats.speed,
          attacker.stages and attacker.stages.speed or 0)
      else
        speed = attacker.def.baseStats.speed
      end
      local b = math.floor(speed / 2)
      b = shl(shl(b))
      if highCrit == nil then highCrit = HIGH_CRIT[moveId] end
      if highCrit then
        b = shl(shl(b))
      else
        b = math.floor(b / 2)
      end
      return rng(0, 255) < b
    end

    local Status = require("src.battle.Status")
    local Strings = require("src.core.Strings")
    local vanillaResidual = Status.residual
    Status.residual = function(battler, opponent, battle)
      local seeded = battler.leechSeeded and battler.mon.hp > 0
        and opponent.mon.hp > 0
      if not seeded then return vanillaResidual(battler, opponent, battle) end
      -- let vanilla handle every other residual; the seed itself is
      -- applied here as a flat 1/8 (no toxic-counter multiplication)
      battler.leechSeeded = nil
      local msgs = vanillaResidual(battler, opponent, battle) or {}
      battler.leechSeeded = true
      local mon = battler.mon
      local dmg = math.max(1, math.floor(mon.stats.hp / 8))
      dmg = math.min(dmg, mon.hp)
      mon.hp = mon.hp - dmg
      opponent.mon.hp = math.min(opponent.mon.stats.hp, opponent.mon.hp + dmg)
      msgs[#msgs + 1] = Strings("LEECH SEED saps\n%s!", battler.name)
      return msgs
    end
  end)

  -- "Dragon physical" toggle in the MODS menu: the per-mod options
  -- auto-UI renders DRAGON PHYS from the schema below, persists the value
  -- in options.lua under options.modOptions, and fires mod.options_changed
  -- when the player flips it.  The merged type records are live tables
  -- (TypeChart.category reads the record on every call), so the switch
  -- applies instantly to damage.  Default OFF = Gen 1 faithful.
  local function setDragonPhysical(data, on)
    local types = data and data.type_chart and data.type_chart.types
    local dragon = types and types.DRAGON
    if dragon then dragon.category = on and "physical" or "special" end
    return dragon ~= nil
  end

  mod.options:define({
    { key = "dragonPhysical", type = "toggle", label = "DRAGON PHYS",
      default = false },
  })

  -- Hard Mode lives in the in-game OPTIONS menu (a HARD MODE row after
  -- BATTLE STYLE, fed through the ui.options.rows hook) and as a choice
  -- in Oak's intro on a new game.  Both doors write the same
  -- options.modOptions key the gameplay wraps read, so they agree and
  -- the toggle can flip a run at any time.  The write mirrors
  -- ManagerState:setOption's two tables (live loader view + the save's
  -- persisted options); persistence is the caller's job so the OPTIONS
  -- row lets the menu's own writeOptions do it once.
  local function writeHardModeOption(game, on)
    on = on == true
    local loader = game and game.mods
    if loader then
      loader.modOptions = loader.modOptions or {}
      loader.modOptions[mod.id] = loader.modOptions[mod.id] or {}
      loader.modOptions[mod.id].hardMode = on
    end
    local save = game and game.save
    if save and save.options then
      save.options.modOptions = save.options.modOptions or {}
      save.options.modOptions[mod.id] = save.options.modOptions[mod.id] or {}
      save.options.modOptions[mod.id].hardMode = on
    end
  end

  local function hardModeOn()
    return mod.options:get("hardMode") == true
  end

  -- the OPTIONS-menu row: ON/OFF toggle anchored after BATTLE STYLE.
  -- step() returns true so OptionsMenu persists the flip, and reads
  -- mod.options:get so the value always matches what the gameplay wraps
  -- enforce.
  local Strings = require("src.core.Strings")
  mod.hooks:wrap("ui.options.rows", function(next, game, rows)
    rows = next(game, rows)
    mod.ui.insertAfter(rows, Strings("BATTLE STYLE"), {
      id = "hardMode", label = Strings("HARD MODE"),
      value = function(g)
        return hardModeOn() and Strings("ON") or Strings("OFF")
      end,
      step = function(g)
        writeHardModeOption(g, not hardModeOn())
        return true
      end,
    })
    return rows
  end)

  mod.hooks:wrap("intro.oak_speech.build", function(next, steps, speech)
    steps = next(steps, speech)
    mod.ui.insertStepAfter(steps, "legend", {
      id = "hard_mode_choice", kind = "yesno", pic = "oak",
      saveKey = "hard_mode_choice", defaultNo = true,
      text = "Play HARD MODE?\nNo items in battle,\nSET style, and level\ncaps per gym badge.",
    })
    return steps
  end)

  mod.events:on("intro.oak_speech.answered", function(ev)
    if ev and ev.saveKey == "hard_mode_choice" then
      local game = ev.speech and ev.speech.game
      writeHardModeOption(game, ev.value)
      if game and game.writeOptions then game:writeOptions() end
    end
  end)

  -- the merged live data the DRAGON PHYS switch writes to: the type_chart
  -- registry rebuilds Data.type_chart.types from its own live records, so
  -- mutating the merged record applies instantly (TypeChart.category reads
  -- it on every call)
  local function gameData()
    local ok, Game = pcall(require, "src.core.Game")
    return ok and Game and Game.data or nil
  end

  local function applyDragonOption()
    local data = gameData()
    if data then setDragonPhysical(data, mod.options:get("dragonPhysical")) end
  end

  mod.events:on("mod.options_changed", function(ev)
    if ev and ev.mod == mod.id and ev.key == "dragonPhysical" then
      local data = gameData()
      if data then setDragonPhysical(data, ev.value == true) end
    end
  end)

  -- the live Game instance, captured on game.ready so the trainer.party
  -- hook can read the player's current rival route at battle time
  local activeGame
  mod.events:on("game.ready", function(ev)
    activeGame = ev and ev.game
    applyDragonOption()
  end)

  -- Pure variant lookup for the rival's early battles (Oak's Lab through
  -- S.S. Anne), exported so headless tests can drive it.  Returns the
  -- party for the player's route, or nil when there is no variant.
  local function rivalVariantFor(oppClass, partyIndex, starter)
    if not rivalPatchEnabled or not resolvedVariants then return nil end
    local byParty = resolvedVariants[oppClass]
    if not byParty then return nil end
    local byStarter = byParty[partyIndex]
    if not byStarter then return nil end
    return byStarter[starter] or byStarter[1]
  end

  -- Battles 1-4 use fixed party indexes in the Yellow scripts, so the
  -- Eevee slot there is swapped per route: the party follows the player's
  -- rivalStarter (1 JOLTEON / 2 FLAREON / 3 VAPOREON), which the engine
  -- already sets before the Oak's Lab fight and updates from battle 1's
  -- result.  Later battles pick their own route variants by index, so the
  -- hook only has to remap OPP_RIVAL1 and OPP_RIVAL2 party 1.
  mod.hooks:wrap("trainer.party", function(next, oppClass, partyIndex, partyDef)
    local g = activeGame
    local starter = (g and g.save and g.save.rivalStarter) or 1
    local variant = rivalVariantFor(oppClass, partyIndex or 1, starter)
    if variant then partyDef = variant end
    return next(oppClass, partyIndex, partyDef)
  end)

  -- ---- Hard Mode: level caps by gym badge ----
  -- The engine's exp.gain hook sees every gain the battle awards (EXP.ALL
  -- runs it per party member too), so the cap is enforced before exp is
  -- ever written: at the cap no gain lands at all, otherwise the gain is
  -- trimmed so a level-up can never cross the cap.  Gaining resumes the
  -- moment the next badge lifts the cap; badges are read live from the
  -- active save, so the toggle works mid-run (a run toggled ON with mons
  -- already past the cap just earns nothing until the cap catches up).
  mod.hooks:wrap("exp.gain", function(next, ctx)
    local gained = next(ctx)
    local g = activeGame
    if g and ctx and ctx.mon and mod.options:get("hardMode") == true then
      local Badges = require("src.inventory.Badges")
      local count = Badges.count(g.data, g.save)
      gained = HardMode.clampExpGain(g.data, ctx.mon, count, gained)
    end
    return gained
  end)

  mod.exports = {
    applyTables = applyTables,
    resolveTables = resolveTables,
    encounterPatchFor = encounterPatchFor,
    setDragonPhysical = setDragonPhysical,
    rivalPatchEnabled = rivalPatchEnabled,
    rivalVariantFor = rivalVariantFor,
    crystalTear = CrystalTear,
    hardMode = HardMode,
  }
end
