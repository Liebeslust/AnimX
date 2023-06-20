AnimFlag = {
    ANIM_FLAG_NORMAL = 0,
    ANIM_FLAG_REPEAT = 1,
    ANIM_FLAG_STOP_LAST_FRAME = 2,
    ANIM_FLAG_UPPERBODY = 16,
    ANIM_FLAG_ENABLE_PLAYER_CONTROL = 32,
    ANIM_FLAG_CANCELABLE = 120
}

AnimStatus = {
    playing = 0,
    stopped = 1,
    paused = 2,
    -- Always 1 or 2 frames before ENTITY.IS_ENTITY_PLAYING_ANIM returns true
    beforePlay = 3,
    stopping = 4
}

---@class AnimPlayback
AnimPlayback = {
    ped = 0,
    dict = "",
    animation = "",
    startTime = 0,
    elapsedTime = 0,
    playbackRate = 1,
    status = AnimStatus.stopped,
    ---@type fun(elapsedTime : number)?
    onStopped = nil,
    ---@type fun()?
    onFailed = nil
}
AnimPlayback.__index = AnimPlayback

---@param ped integer
---@param dict string
---@param animation string
---@param playbackRate number
---@param onStopped? fun(elapsedTime : number)
---@param onFailed? fun()
---@return AnimPlayback
function AnimPlayback.new(ped, dict, animation, playbackRate, onStopped, onFailed)
    local self = setmetatable({}, AnimPlayback)
    self.ped = ped
    self.dict = dict
    self.animation = animation
    self.playbackRate = playbackRate or 1
    self.onStopped = onStopped
    self.onFailed = onFailed
    return self
end

function AnimPlayback:start()
    if self.status == AnimStatus.playing then
        AnimXUtils.debugLog(string.format("Animation override. New animation: %s:%s", self.dict, self.animation))
    end
    self.startTime = os.clock()
    self:playAnim(self.ped, self.dict, self.animation, -1)
    self.status = AnimStatus.beforePlay
    AnimXUtils.debugLog(string.format("Animation start: %s:%s", self.dict, self.animation))
    self:monitorStatus()
end

function AnimPlayback:stop()
    if self.status == AnimStatus.playing then
        self:stopAnim(self.ped)
        self.status = AnimStatus.stopping
    end
end

function AnimPlayback:monitorStatus()
    util.create_tick_handler(function()
        local currentTime = os.clock()
        self.elapsedTime = currentTime - self.startTime

        if self.status == AnimStatus.beforePlay then
            if ENTITY.IS_ENTITY_PLAYING_ANIM(self.ped, self.dict, self.animation, 3) then
                self.status = AnimStatus.playing
            elseif self.elapsedTime >= 1.5 then
                AnimXUtils.debugLog(string.format("Failed to play animation: %s:%s", self.dict, self.animation))
                self:stop()
                return false
            end
        elseif self.status == AnimStatus.playing then
            if not ENTITY.IS_ENTITY_PLAYING_ANIM(self.ped, self.dict, self.animation, 3) then
                self.status = AnimStatus.stopped
                if self.onStopped then self.onStopped(self.elapsedTime) end
                return false
            end
        elseif self.status == AnimStatus.stopping then
            if not ENTITY.IS_ENTITY_PLAYING_ANIM(self.ped, self.dict, self.animation, 3) then
                self.status = AnimStatus.stopped
                if self.onStopped then self.onStopped(self.elapsedTime) end
                return false
            elseif self.elapsedTime >= 1.0 then
                AnimXUtils.debugLog("Failed to stop animation")
                self.status = AnimStatus.stopped
                return false
            end
        else
            return false
        end

        return true
    end)
end

---@param ped integer
---@param dict string
---@param animation string
---@param duration integer
function AnimPlayback:playAnim(ped, dict, animation, duration)
    STREAMING.REQUEST_ANIM_DICT(dict)
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) do util.yield(100) end
    if PED.IS_PED_A_PLAYER(ped) and ped ~= players.user_ped() then
        return -- Don't play animation on other players
    end
    TASK.TASK_PLAY_ANIM(ped, dict, animation, 2.0, 2.0, duration, AnimFlag.ANIM_FLAG_REPEAT, 0.0, false, false, false)
    STREAMING.REMOVE_ANIM_DICT(dict)
end

---@return boolean
---@param ped integer
function AnimPlayback:stopAnim(ped)
    if not ENTITY.DOES_ENTITY_EXIST(ped) then return false end

    if ped == players.user_ped() then
        TASK.CLEAR_PED_TASKS(ped)
        return true
    end

    if ped ~= players.user_ped() and request_control(ped, 1000) then
        TASK.CLEAR_PED_TASKS(ped)
        return true
    else
        return false
    end
end
