local moduleExports = {}

function moduleExports.templateReplace(template, ...)
    local args = {...}
    local result = template:gsub("{arg(%d+)}", function(n) return args[tonumber(n)] end)
    return result
end

function moduleExports.toast(template, ...)
    local args = {...}
    local result = template:gsub("{arg(%d+)}", function(n) return args[tonumber(n)] end)
    util.toast(result, TOAST_ALL)
end

function moduleExports.debugLog(message)
    if Config.debugMode then
        local formattedMessage = string.format("[%s] %s", SCRIPT_NAME, message)
        util.toast(formattedMessage)
        util.log(formattedMessage)
    end
end

---@param modelName string
function moduleExports.requestModelLoad(modelName)
    local requestTime = os.time()
    local hash = util.joaat(modelName)
    if not STREAMING.IS_MODEL_VALID(hash) then return end
    STREAMING.REQUEST_MODEL(hash)

    moduleExports.debugLog("Requesting model " .. modelName)

    while not STREAMING.HAS_MODEL_LOADED(hash) do
        if os.time() - requestTime >= 10 then break end
        util.yield()
    end
end

function moduleExports.getModelSize(hash)
    local minptr = memory.alloc(24)
    local maxptr = memory.alloc(24)
    local min = {}
    local max = {}
    MISC.GET_MODEL_DIMENSIONS(hash, minptr, maxptr)
    min.x, min.y, min.z = v3.get(minptr)
    max.x, max.y, max.z = v3.get(maxptr)
    local size = {}
    size.x = max.x - min.x
    size.y = max.y - min.y
    size.z = max.z - min.z
    size['max'] = math.max(size.x, size.y, size.z)
    return size
end

---@return number
---@param offx number
---@param offy number
---@param offz number
---@param ped number
---@param angx number
---@param angy number
---@param angz number
---@param modelName string
---@param bone number
---@param isnpc boolean
---@param isveh boolean
function moduleExports.createEntityAndAttachTo(offx, offy, offz, ped, angx, angy, angz, modelName, bone, isnpc, isveh)
    local bone = PED.GET_PED_BONE_INDEX(ped, bone)
    local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local hash = util.joaat(modelName)
    if not STREAMING.IS_MODEL_VALID(hash) then return end
    local obj
    if isnpc then
        obj = entities.create_ped(1, hash, coords, 90.0)
    elseif isveh then
        obj = entities.create_vehicle(hash, coords, 90.0)
    else
        obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, coords['x'], coords['y'], coords['z'], true, false, false)
    end
    ENTITY.SET_ENTITY_INVINCIBLE(obj, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, bone, offx, offy, offz, angx, angy, angz, false, false, true, false, 0,
        true)
    ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(obj, false, true)

    return obj
end

return moduleExports
