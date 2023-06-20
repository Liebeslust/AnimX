-----------------------------------
-- WEAPONS LIST
-----------------------------------
local Weapons<const> = {
    -- Shotguns
    VAULT_WMENUI_2 = {
        WT_SG_PMP = "weapon_pumpshotgun",
        WT_SG_PMP2 = "weapon_pumpshotgun_mk2",
        WT_SG_SOF = "weapon_sawnoffshotgun",
        WT_SG_BLP = "weapon_bullpupshotgun",
        WT_SG_ASL = "weapon_assaultshotgun",
        WT_MUSKET = "weapon_musket",
        WT_HVYSHOT = "weapon_heavyshotgun",
        WT_DBSHGN = "weapon_dbshotgun",
        WT_AUTOSHGN = "weapon_autoshotgun",
        WT_CMBSHGN = "weapon_combatshotgun"
    },
    -- Machine guns
    VAULT_WMENUI_3 = {
        WT_SMG_MCR = "weapon_microsmg",
        WT_MCHPIST = "weapon_machinepistol",
        WT_MINISMG = "weapon_minismg",
        WT_SMG = "weapon_smg",
        WT_SMG2 = "weapon_smg_mk2",
        WT_SMG_ASL = "weapon_assaultsmg",
        WT_COMBATPDW = "weapon_combatpdw",
        WT_MG = "weapon_mg",
        WT_MG_CBT = "weapon_combatmg",
        WT_MG_CBT2 = "weapon_combatmg_mk2",
        WT_GUSENBERG = "weapon_gusenberg",
        WT_RAYCARBINE = "weapon_raycarbine"
    },
    -- Rifles
    VAULT_WMENUI_4 = {
        WT_RIFLE_ASL = "weapon_assaultrifle",
        WT_RIFLE_ASL2 = "weapon_assaultrifle_mk2",
        WT_RIFLE_CBN = "weapon_carbinerifle",
        WT_RIFLE_CBN2 = "weapon_carbinerifle_mk2",
        WT_RIFLE_ADV = "weapon_advancedrifle",
        WT_RIFLE_SCBN = "weapon_specialcarbine",
        WT_SPCARBINE2 = "weapon_specialcarbine_mk2",
        WT_BULLRIFLE = "weapon_bullpuprifle",
        WT_BULLRIFLE2 = "weapon_bullpuprifle_mk2",
        WT_CMPRIFLE = "weapon_compactrifle",
        WT_MLTRYRFL = "weapon_militaryrifle",
        WT_HEAVYRIFLE = "WEAPON_HEAVYRIFLE",
        WT_TACRIFLE = "WEAPON_TACTICALRIFLE"
    },
    -- Sniper rifles
    VAULT_WMENUI_5 = {
        WT_SNIP_RIF = "weapon_sniperrifle",
        WT_SNIP_HVY = "weapon_heavysniper",
        WT_SNIP_HVY2 = "weapon_heavysniper_mk2",
        WT_MKRIFLE = "weapon_marksmanrifle",
        WT_MKRIFLE2 = "weapon_marksmanrifle_mk2",
        WT_PRCSRIFLE = "WEAPON_PRECISIONRIFLE"
    },
    -- Heavy weapons
    VAULT_WMENUI_6 = {
        WT_GL = "weapon_grenadelauncher",
        WT_RPG = "weapon_rpg",
        WT_MINIGUN = "weapon_minigun",
        WT_FWRKLNCHR = "weapon_firework",
        WT_RAILGUN = "weapon_railgun",
        WT_HOMLNCH = "weapon_hominglauncher",
        WT_CMPGL = "weapon_compactlauncher",
        WT_RAYMINIGUN = "weapon_rayminigun"
    },
    -- Melee weapons
    VAULT_WMENUI_8 = {
        WT_UNARMED = "weapon_unarmed",
        WT_KNIFE = "weapon_knife",
        WT_NGTSTK = "weapon_nightstick",
        WT_HAMMER = "weapon_hammer",
        WT_BAT = "weapon_bat",
        WT_CROWBAR = "weapon_crowbar",
        WT_GOLFCLUB = "weapon_golfclub",
        WT_BOTTLE = "weapon_bottle",
        WT_DAGGER = "weapon_dagger",
        WT_SHATCHET = "weapon_stone_hatchet",
        WT_KNUCKLE = "weapon_knuckle",
        WT_MACHETE = "weapon_machete",
        WT_FLASHLIGHT = "weapon_flashlight",
        WT_SWTCHBLDE = "weapon_switchblade",
        WT_BATTLEAXE = "weapon_battleaxe",
        WT_POOLCUE = "weapon_poolcue",
        WT_WRENCH = "weapon_wrench",
        WT_HATCHET = "weapon_hatchet"
    },
    -- Pistols
    VAULT_WMENUI_9 = {
        WT_PIST = "weapon_pistol",
        WT_PIST2 = "weapon_pistol_mk2",
        WT_PIST_CBT = "weapon_combatpistol",
        WT_PIST_50 = "weapon_pistol50",
        WT_SNSPISTOL = "weapon_snspistol",
        WT_SNSPISTOL2 = "weapon_snspistol_mk2",
        WT_HEAVYPSTL = "weapon_heavypistol",
        WT_VPISTOL = "weapon_vintagepistol",
        WT_CERPST = "weapon_ceramicpistol",
        WT_MKPISTOL = "weapon_marksmanpistol",
        WT_REVOLVER = "weapon_revolver",
        WT_REVOLVER2 = "weapon_revolver_mk2",
        WT_REV_DA = "weapon_doubleaction",
        WT_REV_NV = "weapon_navyrevolver",
        WT_GDGTPST = "weapon_gadgetpistol",
        WT_STUN = "weapon_stungun",
        WT_FLAREGUN = "weapon_flaregun",
        WT_RAYPISTOL = "weapon_raypistol",
        WT_PIST_AP = "weapon_appistol"
    }
}

---@class WeaponList
WeaponList = {
    reference = 0,
    ---@type string?
    name = "",
    ---@type string?
    command = "",
    ---@type fun(caption: string, model: string)?
    onClick = nil,
    changeName = false,
    selected = nil
}
WeaponList.__index = WeaponList

---@param parent integer
---@param name string
---@param command? string
---@param helpText? string
---@param onClick? fun(caption: string, model: string)
---@param changeName boolean
---@return WeaponList
function WeaponList.new(parent, name, command, helpText, onClick, changeName)
    local self = setmetatable({}, WeaponList)
    self.name = name
    self.command = command
    self.changeName = changeName
    self.onClick = onClick
    self.reference = menu.list(parent, name, {self.command}, helpText or "")

    for section, tbl in pairs_by_keys(Weapons) do self:addSection(section, tbl) end

    return self
end

---@param parent integer
---@param label string
---@param model string
function WeaponList:addOpt(parent, label, model)
    local name = util.get_label_text(label)
    local command = self.command ~= "" and self.command .. name or ""
    menu.action(parent, name, {command}, "", function(click)
        if self.changeName then
            local newName = string.format("%s: %s", self.name, name)
            menu.set_menu_name(self.reference, newName)
        end
        self.selected = model
        if click == CLICK_MENU then menu.focus(self.reference) end
        if self.onClick then self.onClick(name, model) end
    end)
end

---@param section string
---@param weapons table<string, string>
function WeaponList:addSection(section, weapons)
    local list = menu.list(self.reference, util.get_label_text(section), {}, "")
    for label, model in pairs_by_keys(weapons) do self:addOpt(list, label, model) end
end
