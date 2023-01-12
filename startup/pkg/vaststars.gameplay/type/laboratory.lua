local type = require "register.type"
local prototype = require "prototype"
local iendpoint = require "interface.endpoint"

local c = type "laboratory"
    .inputs "itemtypes"
    .speed "percentage"

local STATUS_IDLE <const> = 0
local STATUS_DONE <const> = 1

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function createChest(world, s, endpoint)
    local container_in = {}
    for idx = 2, #s//2 do
        local id = string.unpack("<I2", s, 2*idx-1)
        assert(not isFluidId(id))
        container_in[#container_in+1] = world:chest_slot {
            type = "blue",
            unit = "array",
            item = id,
            limit = 2,
        }
    end
    local asize = #container_in
    return world:container_create(endpoint, table.concat(container_in), asize), asize
end

function c:ctor(init, pt)
    local world = self
    local endpoint = iendpoint.create(world, init, pt, "laboratory")
    local index, asize = createChest(world, pt.inputs, endpoint)
    local e = {
        chest = {
            endpoint = endpoint,
            index = index,
            asize = asize,
            fluidbox_in = 0,
            fluidbox_out = 0,
        },
        laboratory = {
            tech = 0,
            speed = math.floor(pt.speed * 100),
            status = STATUS_IDLE,
            progress = 0,
        }
    }
    return e
end