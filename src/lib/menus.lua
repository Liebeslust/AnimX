local updater = require "src.lib.misc.updater"
local animXAudio = require "src.lib.audio"

if not async_http.have_access() then
    AnimXUtils.toast(LOC.noInternetAccess)
    util.stop_script()
end

updater.runUpdater(0)

animxConfig = {
    debugMode = false
}

local resourcesDir = filesystem.resources_dir() .. string.format("/%s/", SCRIPT_NAME)
if not filesystem.is_dir(resourcesDir) then
    util.toast("ALERT: resources dir is missing! Please make sure you installed AnimX properly.")
end

local logo = directx.create_texture(resourcesDir .. 'AnimXLogo.png')

if SCRIPT_MANUAL_START then
    AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Pre_Screen_Stinger", players.user_ped(), "DLC_HEISTS_FINALE_SCREEN_SOUNDS", true,
        20)
    local logoAlpha = 0
    local logoAlphaDelta = 0.01
    util.create_thread(function(thr)
        local starttime = os.clock()
        while true do
            logoAlpha = logoAlpha + logoAlphaDelta
            directx.draw_texture(logo, 0.14, 0.14, 0.5, 0.5, 0.5, 0.5, 0, 1, 1, 1, logoAlpha)

            if os.clock() - starttime > 3 then logoAlphaDelta = -0.01 end

            if logoAlpha > 0.5 then
                logoAlpha = 0.5
            elseif logoAlpha < 0 then
                logoAlpha = 0
                break
            end

            util.yield()
        end
    end)
end

local attireRoot = menu.my_root():list(LOC.attire, {"animxattire"}, "")
local locationsRoot = menu.my_root():list(LOC.specialLocations, {"animxlocations"}, "")
---@type CommandRef
local moansRoot = menu.my_root():list(LOC.moans, {"animxmoans"}, "")

local voices = {
    [1] = {
        name = "Female moan",
        voice = "S_F_Y_HOOKER_01_WHITE_FULL_01",
        speech = "SEX_GENERIC_FEM"
    },
    [2] = {
        name = "Male moan",
        voice = "MICHAEL_NORMAL",
        speech = "SEX_GENERIC"
    },
    [3] = {
        name = "Female blowjob",
        voice = "S_F_Y_HOOKER_01_WHITE_FULL_01",
        speech = "SEX_ORAL_FEM"
    },
    [4] = {
        name = "Male climax",
        voice = "MICHAEL_NORMAL",
        speech = "SEX_CLIMAX"
    }
}
local voiceOptions = {}
for _, v in ipairs(voices) do table.insert(voiceOptions, v.name) end

moansRoot:list_action(LOC.moans, {"moans"}, "", voiceOptions, function(index, value, click_type)
    local targetPed = PLAYER.PLAYER_PED_ID()
    local voice
    local speech
    local z_off = 0
    if PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
        z_off = AnimXUtils.getModelSize(ENTITY.GET_ENTITY_MODEL(PED.GET_VEHICLE_PED_IS_IN(targetPed, false))).z
    end

    local case = voices[index]

    if case then
        voice = case.voice
        speech = case.speech
    end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(targetPed, 0.0, -1.0, 0.0 + z_off)
    -- AUDIO.PLAY_AMBIENT_SPEECH_FROM_POSITION_NATIVE(speech, voice, coords.x, coords.y, coords.z, "SPEECH_PARAMS_FORCE_SHOUTED")
    AnimXUtils.requestModelLoad("s_f_m_shop_high")
    local voicePed = entities.create_ped(28, util.joaat("s_f_m_shop_high"), coords, 0)
    AnimXUtils.debugLog("voicePed: " .. tostring(voicePed))
    ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(voicePed, true, false)
    ENTITY.SET_ENTITY_VISIBLE(voicePed, false, 0)
    ENTITY.FREEZE_ENTITY_POSITION(voicePed, true)
    ENTITY.SET_ENTITY_INVINCIBLE(voicePed, true)
    AUDIO.PLAY_PED_AMBIENT_SPEECH_WITH_VOICE_NATIVE(voicePed, speech, voice, "SPEECH_PARAMS_FORCE", 0)
    while AUDIO.IS_AMBIENT_SPEECH_PLAYING(voicePed) do util.yield(100) end
    AnimXUtils.debugLog("Deleting voicePed")
    entities.delete(voicePed)
end)

attireRoot:action("Topless female", {"sextoplessf"}, "", function(on_click) menu.trigger_commands("toplessfemale") end)

attireRoot:action("Attach dildo", {"sexstrapon"}, "", function(on_click)
    AnimXUtils.requestModelLoad("prop_cs_dildo_01")
    AnimXUtils.createEntityAndAttachTo(0.15, 0.15, 0.0, players.user_ped(), -90.0, 0.0, 0.0, "prop_cs_dildo_01",
        BoneIds.SKEL_Pelvis, false, false)
end)

attireRoot:action("Clear attached entities", {"clearattach"}, "", function(on_click)
    -- local attachmentHandle = ENTITY.GET_ENTITY_ATTACHED_TO(PLAYER.PLAYER_PED_ID())
    -- if attachmentHandle ~= 0 then
    --     AnimXUtils.debugLog("Deleting attachmentHandle: " .. attachmentHandle)
    --     GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(attachmentHandle)
    --     entities.delete(attachmentHandle)
    -- end
    ENTITY.DETACH_ENTITY(PLAYER.PLAYER_PED_ID(), true, false)
end)

-- CommandRef|CommandUniqPtr menu.list(CommandRef parent, Label menu_name, table<any, string> command_names = {}, Label help_text = "", ?function on_click = nil, ?function on_back = nil, ?function on_active_list_update = nil)
---@type CommandRef
local autoCleanCharacterRef = attireRoot:list(LOC.autoCleanCharacter, {"autocleancharacter"}, LOC.autoCleanCharacterD)

local autoCleanCharacterBloodRef
local autoCleanCharacterWetnessRef
local autoCleanCharacterDirtRef

autoCleanCharacterRef:action(LOC.enableCleanAll, {"enablecleanall"}, LOC.enableCleanAllD, function(on_click)
    menu.set_value(autoCleanCharacterBloodRef, true)
    menu.set_value(autoCleanCharacterWetnessRef, true)
    menu.set_value(autoCleanCharacterDirtRef, true)
end)

autoCleanCharacterRef:action(LOC.disableCleanAll, {"disablecleanall"}, LOC.disableCleanAllD, function(on_click)
    menu.set_value(autoCleanCharacterBloodRef, false)
    menu.set_value(autoCleanCharacterWetnessRef, false)
    menu.set_value(autoCleanCharacterDirtRef, false)
end)

autoCleanCharacterBloodRef = autoCleanCharacterRef:toggle_loop(LOC.blood, {"cleanblood"}, "", function()
    PED.CLEAR_PED_BLOOD_DAMAGE(PLAYER.PLAYER_PED_ID())
end)

autoCleanCharacterWetnessRef = autoCleanCharacterRef:toggle_loop(LOC.wetness, {"cleanwetness"}, "", function()
    PED.CLEAR_PED_WETNESS(PLAYER.PLAYER_PED_ID())
end)

autoCleanCharacterDirtRef = autoCleanCharacterRef:toggle_loop(LOC.dirt, {"cleandirt"}, "", function()
    PED.CLEAR_PED_ENV_DIRT(PLAYER.PLAYER_PED_ID())
end)

menu.action(locationsRoot, "Motel room", {"sexinmotel"}, "", function(on_click) menu.trigger_commands("tpmotelroom") end)

menu.action(locationsRoot, "Bahama mamas", {"sexinbahamasmamas"}, "",
    function(on_click) menu.trigger_commands("tpbahamamamas") end)

menu.action(locationsRoot, "Torture room", {"sexintortureroom"}, "",
    function(on_click) menu.trigger_commands("tptortureroom") end)

menu.action(locationsRoot, "Floyd\'s house", {"sexinfloydhouse"}, "",
    function(on_click) menu.trigger_commands("tpfloyd") end)

local actorMenu<const> = ActorMenu.new(menu.my_root(), LOC.actorMenu.actorsMenu, {"animxactorsmenu"})

local animMenu<const> = AnimMenu.new(menu.my_root(), LOC.animMenu.animMenu, "animxanimmenu", LOC.animMenu.animMenuD,
    true, players.user(), function(dict, animation)
        -- anim.playAnimOnSelf(dict, animation, -1) deprecated
    end, false, true)

menu.on_focus(animMenu.reference, function() animMenu:refreshPed(players.user()) end)

-- void util.create_tick_handler(function func)
-- Registers the parameter-function to be called every tick until it returns false.
util.create_tick_handler(function() actorMenu:onTick() end)

local miscRoot = menu.my_root():list(LOC.miscmiscellaneous, {}, "")

miscRoot:toggle_loop(LOC.spectateWarning, {}, LOC.spectateWarningD, function()
    for _, player in ipairs(players.list(false)) do
        local target = players.get_spectate_target(player)
        if target ~= -1 then
            util.draw_debug_text(string.format("%s spectating %s", players.get_name(player), players.get_name(target)))
        end
    end
end)

-- CommandRef|CommandUniqPtr menu.toggle(CommandRef parent, Label menu_name, table<any, string> command_names, Label help_text, function on_change, bool default_on = false)
menu.my_root():toggle("Debug Mode", {}, "", function(on) animxConfig.debugMode = on end, false)

---@param pId integer
local networkPlayerMenuPopulate = function(pId)
    menu.divider(menu.player_root(pId), SCRIPT_NAME)

    AnimMenu.new(menu.player_root(pId), LOC.animMenu.animMenu, "animxanimmenu", LOC.animMenu.animMenuD, true, pId,
        function(dict, animation)
            -- anim.playAnimOnSelf(dict, animation, -1)
        end, false, true)
end
players.on_join(networkPlayerMenuPopulate)
players.dispatch_on_join()
