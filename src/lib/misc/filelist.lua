-------------------------------------
-- FILE LIST
-------------------------------------
---@class FileList
FileList = {
    dir = "",
    ext = "json",
    open = false,
    reference = 0,
    options = {},
    fileOpts = {},
    onClick = nil
}
FileList.__index = FileList

---@param parent integer
---@param name string
---@param options table
---@param dir string
---@param ext string
---@param onClick fun(opt: integer, fileName: string, path: string)
---@return FileList
function FileList.new(parent, name, options, dir, ext, onClick)
    local self = setmetatable({
        dir = dir,
        ext = ext,
        options = options
    }, FileList)
    self.fileOpts = {}
    self.onClick = onClick

    self.reference = menu.list(parent, name, {}, "", function()
        self.open = true
        self:load()
    end, function()
        self.open = false
        self:clear()
    end)

    return self
end

function FileList:load()
    if not self.dir or not filesystem.exists(self.dir) then return end

    for _, path in ipairs(filesystem.list_files(self.dir)) do
        local name, ext = string.match(path, '^.+\\(.+)%.(.+)$')
        if not self.ext or self.ext == ext then self:createOpt(name, path) end
    end
end

---@param fileName string
---@param path string
function FileList:createOpt(fileName, path)
    local list = menu.list(self.reference, fileName, {}, "")

    for i, opt in ipairs(self.options) do
        menu.action(list, opt, {}, "", function() self.onClick(i, fileName, path) end)
    end

    self.fileOpts[#self.fileOpts + 1] = list
end

function FileList:clear()
    if #self.fileOpts == 0 then return end

    for i, ref in ipairs(self.fileOpts) do
        menu.delete(ref);
        self.fileOpts[i] = nil
    end
end

---@param file string #Must include file extension.
---@param content string
function FileList:add(file, content)
    assert(self.dir ~= "", "tried to add a file to a null directory")
    if not filesystem.exists(self.dir) then filesystem.mkdir(self.dir) end

    local name, ext = string.match(file, '^(.+)%.(.+)$')
    local count = 1

    while filesystem.exists(self.dir .. file) do
        count = count + 1
        file = string.format("%s (%s).%s", name, count, ext)
    end

    local file<close> = assert(io.open(self.dir .. file, "w"))
    file:write(content)
end

function FileList:reload()
    self:clear()
    self:load()
end
