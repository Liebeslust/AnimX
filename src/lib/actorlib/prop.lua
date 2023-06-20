-------------------------------------
-- PROP
-------------------------------------
---@class Prop
Prop = {
    reference = 0,
    componentId = -1,
    drawableId = 0,
    textureId = 0
}
Prop.__index = Prop

local trans<const> = {
    Type = LOC.wardrobe.type,
    Texture = LOC.wardrobe.texture
}

---@param parent integer
---@param name string
---@param ped Ped
---@param componentId integer
---@param onChange fun(drawableId: integer, textureId: integer)
function Prop.new(parent, name, ped, componentId, onChange)
    local self = setmetatable({}, Prop)
    self.reference = menu.list(parent, name, {}, "")
    self.componentId = componentId

    local numDrawables = PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(ped, componentId)
    self.drawableId = PED.GET_PED_PROP_INDEX(ped, componentId)
    local textureSlider

    menu.slider(self.reference, trans.Type, {}, "", -1, numDrawables - 1, self.drawableId, 1,
        function(drawableId, prev, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then return end
            self.drawableId = drawableId
            local numTextures = PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(ped, componentId, drawableId)
            menu.set_max_value(textureSlider, numTextures - 1)
            self.textureId = 0
            menu.set_value(textureSlider, self.textureId)
            onChange(self.drawableId, self.textureId)
        end)

    self.textureId = PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(ped, componentId, self.drawableId)
    local currentNumTextures = PED.GET_PED_PROP_TEXTURE_INDEX(ped, componentId)

    textureSlider = menu.slider(self.reference, trans.Texture, {}, "", 0, currentNumTextures - 1, self.textureId, 1,
        function(value, prev, click)
            if (click & CLICK_FLAG_AUTO) ~= 0 then return end
            self.textureId = value
            onChange(self.drawableId, self.textureId)
        end)

    return self
end

