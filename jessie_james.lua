-- Jessie & James Mt Moon B2F ambush for Red/Blue (wired in main.lua).
--
-- The engine ships this event only on a Yellow boot: data/scripts/
-- yellow_jessie_james.lua registers the M.MT_MOON_B2F block behind
-- GameVersion.isYellow() (data/scripts/init.lua).  On Red/Blue the map
-- has neither the duo's objects (MTMOONB2F_JESSIE / MTMOONB2F_JAMES) nor
-- their _MtMoonJessieJamesText* constants, so this file wires the same
-- event onto the shared MT_MOON_B2F table when the running game is not
-- Yellow (a Yellow cache already carries the text, and the engine's own
-- event would double-fire there).
--
-- Red adaptations vs the engine's Yellow rows (yellow_jessie_james.lua):
--   * "Music_MeetJessieJames" does not exist on Red; the Rocket
--     stand-in "Music_MeetEvilTrainer" plays instead -- both the
--     approach sting and the parting sting after the battle.
--   * the engine's walk_npc 2 / walk_npc 6 reference the duo's object
--     indexes in the Yellow data; on Red the two objects are appended
--     at maxIndex+1 / maxIndex+2 and the rows are built with those
--     indexes (ow:npcByIndex matches on def.index).
--
-- Pure builders live here so the headless tests can drive every branch
-- without a live game; the onStep hook chains story2's Super Nerd /
-- fossil gate exactly like the engine's Yellow file does.

local M = {}

-- the Rocket theme that stands in for Music_MeetJessieJames on Red/Blue
M.MUSIC = "Music_MeetEvilTrainer"

-- the four text constants the event shows (Text1 "Stop right there!",
-- Text2 the fossil demand, Text3/Text4 the parting lines).  Registering
-- these is guarded by main.lua's not-Yellow check: content.text:register
-- errors on an existing id, and a Yellow cache already has them.
M.TEXTS = {
  _MtMoonJessieJamesText1 = "Stop right there!",
  _MtMoonJessieJamesText2 =
    "That fossil is\nTEAM ROCKET's!\n\nSurrender now, or\nprepare to fight!",
  _MtMoonJessieJamesText3 = "A brat beat us?",
  _MtMoonJessieJamesText4 = "TEAM ROCKET, blast\noff at the speed\nof light!",
}

-- The two hidden overworld objects appended to MT_MOON_B2F, mirroring
-- the nurse_joy_battle approach: the base object list is carried forward
-- because maps:patch replaces lists wholesale.  The duo carry their own
-- Yellow sprite ids (SPRITE_JESSIE / SPRITE_JAMES -- shipped by this mod
-- and registered in main.lua when the game is not Yellow, which already
-- has them).  Returns the new object list and the duo's assigned indexes
-- (maxIndex+1 / maxIndex+2).
function M.mapObjects(baseObjects)
  local objects = {}
  local maxIndex = 0
  if type(baseObjects) == "table" then
    for _, obj in ipairs(baseObjects) do
      objects[#objects + 1] = obj
      if obj.index and obj.index > maxIndex then maxIndex = obj.index end
    end
  end
  local jessie = maxIndex + 1
  local james = maxIndex + 2
  objects[#objects + 1] = {
    index = jessie,
    name = "MTMOONB2F_JESSIE",
    x = 9, y = 3,
    sprite = "SPRITE_JESSIE",
    movement = "STAY",
    range = "ANY_DIR",
    text = "TEXT_MTMOONB2F_JESSIE",
    hidden = true,
  }
  objects[#objects + 1] = {
    index = james,
    name = "MTMOONB2F_JAMES",
    x = 9, y = 4,
    sprite = "SPRITE_JAMES",
    movement = "STAY",
    range = "ANY_DIR",
    text = "TEXT_MTMOONB2F_JAMES",
    hidden = true,
  }
  return objects, jessie, james
end

-- The onStep rows, a faithful port of the engine's M.MT_MOON_B2F block
-- (yellow_jessie_james.lua lines 45-78) with the two Red adaptations:
-- Music_MeetEvilTrainer for the theme, and the duo's actual object
-- indexes (the appended maxIndex+1 / maxIndex+2) for walk_npc /
-- face_object.  Every other row -- including the fossil gate flags and
-- the battle (trainer OPP_ROCKET, party 42, which this mod's trainers.lua
-- already maps to EKANS 15 / MEOWTH 16 / KOFFING 15) -- matches verbatim.
function M.rows(jessieIndex, jamesIndex)
  return {
    { "stop_music" },
    { "play_music", M.MUSIC },
    { "show_object", "MT_MOON_B2F", "MTMOONB2F_JESSIE" },
    { "show_object", "MT_MOON_B2F", "MTMOONB2F_JAMES" },
    { "show_text", "_MtMoonJessieJamesText1" },
    { "face_player_dir", "up" },
    { "emote", "player", "shock", 30 },
    { "walk_npc", "player", { "up" } },
    { "walk_npc", jessieIndex,
      { "left", "left", "left", "left", "left", "left" } },
    { "face_object", jessieIndex, "down" },
    { "walk_npc", jamesIndex, { "left", "left", "left", "left", "left" } },
    { "face_object", jamesIndex, "left" },
    { "show_text", "_MtMoonJessieJamesText2" },
    { "start_battle", "trainer", "OPP_ROCKET", 42 },
    { "check_battle_result", "win" },
    { "jump_if_false", "end" },
    { "show_text", "_MtMoonJessieJamesText3" },
    { "show_text", "_MtMoonJessieJamesText4" },
    { "stop_music" },
    { "play_music", M.MUSIC },
    { "fade", "out" },
    { "hide_object", "MT_MOON_B2F", "MTMOONB2F_JESSIE" },
    { "hide_object", "MT_MOON_B2F", "MTMOONB2F_JAMES" },
    { "fade", "in" },
    { "play_default_music" },
    { "set_flag", "EVENT_BEAT_MT_MOON_3_JESSIE_JAMES" },
  }
end

-- The onStep hook, closing over the duo's indexes.  Chains story2's
-- MT_MOON_B2F onStep first (the Super Nerd / fossil gate), exactly as the
-- engine's Yellow file does, then fires the ambush when the player steps
-- onto (3,5) with a fossil in hand and the duo unbeaten.  The map_scripts
-- registry composes onStep hooks with "first truthy return consumes", so
-- returning true here stops the chain (base already ran, never twice on a
-- firing tile); a falsy return lets the chain fall through to base, whose
-- own check is a pure coordinate read.
function M.makeOnStep(jessieIndex, jamesIndex)
  return function(game, ow, x, y)
    local story2 = require("data.scripts.story2")
    local base = story2 and story2.MT_MOON_B2F and story2.MT_MOON_B2F.onStep
    if base and base(game, ow, x, y) then return true end
    local f = game and game.save and game.save.flags
    if not f then return false end
    if x ~= 3 or y ~= 5 then return false end
    if f.EVENT_BEAT_MT_MOON_3_JESSIE_JAMES then return false end
    if not (f.EVENT_GOT_DOME_FOSSIL or f.EVENT_GOT_HELIX_FOSSIL) then
      return false
    end
    ow.runner:run(M.rows(jessieIndex, jamesIndex), {})
    return true
  end
end

return M
