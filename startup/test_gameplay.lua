package.path = "engine/?.lua"
require "bootstrap"

import_package "vaststars.prototype"

local gameplay = import_package "vaststars.gameplay"

local test = gameplay.system "test"

function test.update(world)
    for v in world.ecs:select "generator capacitance:out" do
        v.capacitance.shortage = 0
    end
end

local world = gameplay.createWorld()

assert(loadfile "test_map.lua")(world)

--world:backup  "../../startup/.log/sav"
--world:restore "../../startup/.log/sav"

world:build()

local function dump_item()
    print "=================="
    local ecs = world.ecs
    for v in ecs:select "chest:in" do
        for i = 1, 10 do
            local c, n = world:container_get(v.chest.container, i)
            if c then
                print(gameplay.query(c).name, n)
            else
                break
            end
        end
    end
end

local function dump_fluid()
    local ecs = world.ecs
    local function display(fluid, id, fluidbox)
        if fluid ~= 0 and id ~= 0 then
            local r = world:fluidflow_query(fluid, id)
            if r then
                print(gameplay.query(fluid).name, ("%0.2f/%d\t%0.2f"):format(r.volume / r.multiple, fluidbox.capacity, r.flow / r.multiple))
            end
        end
    end
    for v in ecs:select "fluidbox:in entity:in" do
        local pt = gameplay.query(v.entity.prototype)
        display(v.fluidbox.fluid, v.fluidbox.id, pt.fluidbox)
    end
    for v in ecs:select "fluidboxes:in entity:in" do
        local pt = gameplay.query(v.entity.prototype)
        for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
            local fluid = v.fluidboxes[classify.."_fluid"]
            local id = v.fluidboxes[classify.."_id"]
            local what, i = classify:match "(%a*)(%d)"
            display(fluid, id, pt.fluidboxes[what.."put"][tonumber(i)])
        end
    end
    print "===================="
end

local function dump()
    --dump_item()
    dump_fluid()
end

world:wait(2*50, dump)
world:wait(10*50, dump)
world:wait(20*50, dump)
world:wait(30*50, dump)

--world:loop(1, function ()
--    world:fluidflow_dump(0x3c01)
--end)

world:wait(10*60*50, function ()
    world.quit = true
end)

while not world.quit do
    world:update()
end

print "ok"
