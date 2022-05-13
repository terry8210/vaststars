local ecs = ...
local world = ecs.world

local irmlui = ecs.import.interface "ant.rmlui|irmlui"
local json = import_package "ant.json"
local json_encode = json.encode
local json_decode = json.decode
local syncobj = require "utility.syncobj"
local ltask = require "ltask"
local ltask_now = ltask.now
local table_unpack = table.unpack

local rmlui_message_mb = world:sub {"rmlui_message"}
local rmlui_message_close_mb = world:sub {"rmlui_message_close"}
local ui_message_mb = world:sub {"ui_message"}
local create_template = ecs.require "ui_datamodel.init"
local window_bindings = {} -- = {[url] = { w = xx, datamodel = xx, }, ...}
local datamodel_changed = {}
local datamodel_tick = {}
local stage_ui_update = {}
local stage_camera_usage = {}

local function create_ui_mailbox(url)
    local ui_mailbox = {}
    function ui_mailbox:sub(message)
        return world:sub {"rmlui_message_send", url, table.unpack(message)}
    end
    return ui_mailbox
end

local function open(url, ...)
    assert(type(url) == "string")

    local binding = window_bindings[url]
    if binding then
        datamodel_changed[url] = true
        return
    end

    binding = {}
    binding.last_timestamp = 0
    binding.window = irmlui.open(url)
    binding.window.addEventListener("message", function(event)
        if not event.data then
            console.log("event data is null")
            return
        end

        local res, err = json_decode(event.data)
        if not res then
            error(("%s"):format(err))
            return
        end

        if res.event == "__CLOSE" then
            world:pub {"rmlui_message_close", url}
        elseif res.event == "__OPEN" then
            world:pub {"rmlui_message", res.event, table.unpack(res.ud)}
        elseif res.event == "__SEND" then
            world:pub {"rmlui_message_send", url, table.unpack(res.ud)}
        else
            world:pub {"rmlui_message", res.event, res.ud}
        end
    end)

    local func = create_template(url)
    if not func then
        return
    end

    binding.template = func(ecs, create_ui_mailbox(url))
    if not binding.template then
        return
    end

    function binding.template:flush()
        local ud = {}
        ud.event = "__DATAMODEL"
        ud.ud = binding.source:diff(binding.datamodel)
        binding.window.postMessage(json_encode(ud))

        datamodel_changed[url] = nil
    end

    binding.param = {...}
    binding.source = syncobj.source()
    binding.datamodel = binding.source:new(binding.template:create(...))

    binding.template:flush()
    window_bindings[url] = binding

    if binding.template.tick then
        datamodel_tick[url] = true
    end

    if binding.template.stage_ui_update then
        stage_ui_update[url] = true
    end

    if binding.template.state_camera_usage then
        stage_camera_usage[url] = true
    end
end

local function pub(msg)
    world:pub(msg)
end

local function close(url)
    local w = window_bindings[url]
    if not w then
        return
    end
    w:close()
    window_bindings[url] = nil
    datamodel_changed[url] = nil
    datamodel_tick[url] = nil
    stage_ui_update[url] = nil
    stage_camera_usage[url] = nil
end

local ui_events = {
    __OPEN = open,
    __PUB = pub,
    -- __CLOSE = close,
}

local function gettime()
    local _, t = ltask_now() --10ms
    return t * 10
end

local ui_system = ecs.system "ui_system"
function ui_system.ui_update()
    local event, func

    for _, url in rmlui_message_close_mb:unpack() do
        local binding = window_bindings[url]
        if not binding then
            log.warn(("can not found window `%s`"):format(url))
        else
            binding.window:close()
            window_bindings[url] = nil
            datamodel_changed[url] = nil
            datamodel_tick[url] = nil
            stage_ui_update[url] = nil
            stage_camera_usage[url] = nil
        end
    end

    -- rmlui to world
    for msg in rmlui_message_mb:each() do
        event = msg[2]
        func = assert(ui_events[event], ("Can not found event `%s`"):format(event))
        func(table.unpack(msg, 3, #msg))
    end

    -- world to rmlui
    for msg in ui_message_mb:each() do
        for _, binding in pairs(window_bindings) do
            local ud = {}
            ud.event = msg[2]
            ud.ud = {table.unpack(msg, 3, #msg)}
            binding.window.postMessage(json_encode(ud))
        end
    end

    for url in pairs(datamodel_tick) do
        local binding = window_bindings[url]
        binding.template:tick(binding.datamodel, table_unpack(binding.param))
        if binding.source:changed(binding.datamodel) then
            datamodel_changed[url] = true
        end
    end

    for url in pairs(stage_ui_update) do
        local binding = window_bindings[url]
        binding.template:stage_ui_update(binding.datamodel)
        if binding.source:changed(binding.datamodel) then
            datamodel_changed[url] = true
        end
    end

    for url in pairs(stage_camera_usage) do
        local binding = window_bindings[url]
        binding.template:stage_camera_usage(binding.datamodel)
        if binding.source:changed(binding.datamodel) then
            datamodel_changed[url] = true
        end
    end

    local current = gettime()
    for url in pairs(datamodel_changed) do
        local binding = window_bindings[url]
        if binding then
            if current - binding.last_timestamp < 1000 then
                goto continue
            end
            binding.last_timestamp = current

            local datamodel = binding.datamodel
            local source = binding.source
            local window = binding.window

            local ud = {}
            ud.event = "__DATAMODEL"
            ud.ud = source:diff(datamodel)
            window.postMessage(json_encode(ud))
            datamodel_changed[url] = nil
        end
        ::continue::
    end
end

function ui_system.camera_usage()
    for url in pairs(stage_camera_usage) do
        local binding = window_bindings[url]
        binding.template:stage_camera_usage(binding.datamodel)
    end
end

local iui = ecs.interface "iui"
function iui.open(url, ...)
    world:pub {"rmlui_message", "__OPEN", url, ...}
end

function iui.close(url)
    world:pub {"rmlui_message", "__CLOSE", url}
end

function iui.update(url, event, ...)
    local binding = window_bindings[url]
    if not binding then
        return
    end

    local func = binding.template[event]
    if not func then
        log.error(("can not found event `%s`"):format(event))
        return
    end

    func(binding.template, binding.datamodel, ...)
    if binding.source:changed(binding.datamodel) then
        datamodel_changed[url] = true
    end
end

