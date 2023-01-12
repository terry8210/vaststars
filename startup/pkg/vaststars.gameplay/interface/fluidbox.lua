local prototype = require "prototype"

local function fluidId(name)
    local what = prototype.queryByName("fluid", name)
    if what then
        return what.id
    end
    return 0
end

local function update_fluidboxes(e, pt, fluids)
    assert(e.fluidboxes ~= nil)
    assert(pt.fluidboxes)
    assert(#pt.fluidboxes.input <= 4)
    assert(#pt.fluidboxes.output <= 3)
    local fluidboxes = e.fluidboxes
    local function getfluidId(classify)
        local what, i = classify:match "(%a*)(%d)"
        what = what.."put"
        i = tonumber(i)
        if fluids and fluids[what] and fluids[what][i] then
            local v = fluids[what][i]
            return fluidId(v)
        end
        return 0
    end
    for _, classify in ipairs {"in1","in2","in3","in4","out1","out2","out3"} do
        local id = getfluidId(classify)
        if id ~= fluidboxes[classify.."_fluid"] then
            fluidboxes[classify.."_fluid"] = id
            fluidboxes[classify.."_id"] = 0
            e.fluidbox_changed = true
        end
    end
end


local function update_fluidbox(e, fluid)
    assert(e.fluidbox ~= nil)
    if e.fluidbox.fluid ~= fluid then
        e.fluidbox.fluid = fluid
        e.fluidbox.id = 0
        e.fluidbox_changed = true
    end
end

return {
    update_fluidboxes = update_fluidboxes,
    update_fluidbox = update_fluidbox,
}