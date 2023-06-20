-------------------------------------
-- MUST NOT INCLUDE
-------------------------------------

---@class CommandRef
local CommandRef = {}

---@type boolean
CommandRef.visible = nil

---@type any
CommandRef.value = nil

---@type number
CommandRef.min_value = nil

---@type number
CommandRef.max_value = nil

---@type number
CommandRef.step_size = nil

---@type number
CommandRef.precision = nil

---@type string
CommandRef.indicator_type = nil

---@type any
CommandRef.target = nil

---@return boolean
function CommandRef:isValid() end

---@return CommandRef
function CommandRef:refByRelPath() end

function CommandRef:delete() end

function CommandRef:detach() end

function CommandRef:attach(...) end

function CommandRef:attachAfter(...) end

function CommandRef:attachBefore(...) end

function CommandRef:focus() end

---@return boolean
function CommandRef:isFocused() end

---@return table
function CommandRef:getApplicablePlayers() end

---@return any
function CommandRef:getParent() end

---@return string
function CommandRef:getType() end

---@return table
function CommandRef:getChildren() end

function CommandRef:trigger() end

function CommandRef:onTickInViewport(...) end

function CommandRef:onFocus(...) end

function CommandRef:onBlur(...) end

function CommandRef:removeHandler(...) end

---@return any
function CommandRef:getState() end

---@return any
function CommandRef:getDefaultState() end

function CommandRef:applyDefaultState() end

function CommandRef:setListActionOptions(...) end

function CommandRef:setTextsliderOptions(...) end

function CommandRef:addValueReplacement(...) end

function CommandRef:setTemporary() end

function CommandRef:list(...) end

function CommandRef:action(...) end

function CommandRef:toggle(...) end

function CommandRef:toggle_loop(...) end

function CommandRef:slider(...) end

function CommandRef:slider_float(...) end

function CommandRef:click_slider(...) end

function CommandRef:click_slider_float(...) end

function CommandRef:list_select(...) end

function CommandRef:list_action(...) end

function CommandRef:text_input(...) end

function CommandRef:colour(...) end

function CommandRef:rainbow(...) end

function CommandRef:divider(...) end

function CommandRef:readonly(...) end

function CommandRef:hyperlink(...) end

function CommandRef:textslider(...) end

function CommandRef:textslider_stateful(...) end

function CommandRef:link(...) end

---@class CommandUniqPtr
local CommandUniqPtr = {}

function CommandUniqPtr:ref() end

return CommandRef
