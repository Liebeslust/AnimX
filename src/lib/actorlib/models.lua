-----------------------------------
-- PEDS LIST
-----------------------------------
---@class ModelList
ModelList = {
    reference = 0,
    default = nil,
    name = "",
    command = "",
    ---@type fun(caption: string, model: string)?
    onClick = nil,
    changeName = false,
    ---@type table
    options = {},
    foundOpts = {}
}
ModelList.__index = ModelList

---@param parent integer
---@param name string
---@param command string
---@param helpText string
---@param tbl table
---@param onClick? fun(caption: string, model: string)
---@param changeName boolean #If the list's name will change to show the selected model.
---@param searchOpt boolean
---@return ModelList
function ModelList.new(parent, name, command, helpText, tbl, onClick, changeName, searchOpt)
    local self = setmetatable({}, ModelList)
    self.name = name
    self.command = command
    self.onClick = onClick
    self.changeName = changeName
    self.foundOpts = {}
    self.options = tbl
    self.reference = menu.list(parent, name, {self.command}, helpText or "")

    if searchOpt then self:createSearchList(self.reference, LOC.misc.search) end

    for caption, value in pairs_by_keys(self.options) do
        if type(value) == "string" then
            self:addOpt(self.reference, caption, value)

        elseif type(value) == "table" then
            local section = menu.list(self.reference, caption, {}, "")
            self:addSection(section, value)
        end
    end

    return self
end

---@param parent integer
---@param caption string
---@param model string
function ModelList:addOpt(parent, caption, model)
    local command = self.command ~= "" and self.command .. caption or ""

    return menu.action(parent, caption, {command}, "", function(click)
        if self.changeName then
            local newName = string.format("%s: %s", self.name, caption)
            menu.set_menu_name(self.reference, newName)
        end
        if (click & CLICK_FLAG_AUTO) == 0 then menu.focus(self.reference) end
        if self.onClick then self.onClick(caption, model) end
    end)
end

---@param parent integer
---@param tbl table<string, string>
---@param outReferences integer[]?
function ModelList:addSection(parent, tbl, outReferences)
    for caption, name in pairs_by_keys(tbl) do
        local reference = self:addOpt(parent, caption, name)
        if outReferences then table.insert(outReferences, reference) end
    end
end

---@param parent integer
---@param menu_name string
function ModelList:createSearchList(parent, menu_name)
    local reference = menu.list(parent, menu_name, {}, "")

    menu.action(reference, menu_name, {}, "", function(click)
        if (CLICK_FLAG_AUTO & click) ~= 0 then return end

        for _, reference in ipairs(self.foundOpts) do
            menu.delete(reference)
            self.foundOpts = {}
        end

        local text = get_input_from_screen_keyboard(CustomLabels.Search, 20, "")
        if text == "" then
            return
        else
            text = string.lower(text)
        end

        for caption, value in pairs(self.options) do
            if type(value) == "string" then
                if string.lower(caption):find(text) or value:find(text) then
                    local opt = self:addOpt(reference, caption, value)
                    table.insert(self.foundOpts, opt)
                end

            elseif type(value) == "table" then
                local tbl = value
                local matches = self.getSectionMatches(caption, text, tbl)
                self:addSection(reference, matches, self.foundOpts)
            end
        end
    end)
end

---@param section string
---@param find string
---@param tbl table<string, string>
---@return table
function ModelList.getSectionMatches(section, find, tbl)
    local matches = {}
    find = string.lower(find)

    for caption, model in pairs(tbl) do
        if string.lower(caption):find(find) or model:find(find) then matches[section .. " > " .. caption] = model end
    end
    return matches
end
