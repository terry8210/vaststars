local ecs, mailbox = ...
local world = ecs.world
local w = world.w

local iui = ecs.require "engine.system.ui_system"

local quit_mb = mailbox:sub {"quit"}
local build_mb = mailbox:sub {"build"}
local rotate_mb = mailbox:sub {"rotate"}
local show_confirm_mb = mailbox:sub {"show_confirm"}
local iprototype = require "gameplay.interface.prototype"

---------------
local M = {}

function M.create(prototype_name)
    local typeobject = iprototype.queryByName(prototype_name)

    return {
        show_confirm = true,
        show_rotate = (typeobject.rotate_on_build == true),
    }
end

function M.update(datamodel)
    for _ in quit_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "quit")
    end

    for _ in build_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "build")
    end

    for _ in rotate_mb:unpack() do
        iui.redirect("/pkg/vaststars.resources/ui/construct.html", "rotate")
    end

    for _, _, _, b in show_confirm_mb:unpack() do
        datamodel.show_confirm = b
    end
end

return M