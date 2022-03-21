local gameplay = import_package "vaststars.gameplay"
local world = gameplay.createWorld()

local m = {}

function m.select(...)
    return world.ecs:select(...)
end

function m.build(...)
    return world:build()
end

function m.update()
    return world:update()
end

local create_entity_cache = {}
local function create(world, prototype, entity)
    if not create_entity_cache[prototype] then
        create_entity_cache[prototype] = world:create_entity(prototype)
        if not create_entity_cache[prototype] then
            log.error(("failed to create entity `%s`"):format(prototype))
            return
        end
    end
    create_entity_cache[prototype](entity)
end

local function isFluidId(id)
    return id & 0x0C00 == 0x0C00
end

local function get_fluid_list(fluidboxes, classify, s)
    local lst = fluidboxes[classify]
    assert(lst)

    local r = {}
    for idx = 1, #s//4 do
        local id = string.unpack("<I2I2", s, 4*idx-3)
        if isFluidId(id) then
            local pt = gameplay.query(id)
            r[#r + 1] = {pt.name, 0}
        end
    end
    return r
end

local init_func = {}
init_func["assembling"] = function(pt, template)
    if not pt.recipe then
        log.error(("can not found recipe `%s`"):format(pt.name))
        return
    end
    local r = gameplay.queryByName("recipe", pt.recipe)

    local output = get_fluid_list(pt.fluidboxes, "output", r.results)
    if #output > 0 then
        template.fluids = {
            output = output
        }
    end

    return template
end

function m.create_entity(game_object)
    local gameplay_entity = game_object.gameplay_entity
    local func
    local template = {
        x = gameplay_entity.x,
        y = gameplay_entity.y,
        dir = gameplay_entity.dir,
        fluid = gameplay_entity.fluid,
    }

    local pt = gameplay.queryByName("entity", gameplay_entity.prototype_name)
    for _, entity_type in ipairs(pt.type) do
        func = init_func[entity_type]
        if func then
            template = func(pt, template)
        end
    end

    print(gameplay_entity.prototype_name, template.x, template.y)
    create(world, gameplay_entity.prototype_name, template)
    return template.id
end

do
    local DIRECTION <const> = {
        [0] = 'N',
        [1] = 'E',
        [2] = 'S',
        [3] = 'W',
    }

    local function get_prototype_name(prototype)
        local pt = gameplay.query(prototype)
        if not pt then
            log.error(("can not found prototype(%s)"):format(prototype))
            return
        end
        return pt.name
    end

    function m.entity(x, y)
        for e in world.ecs:select "entity:in" do
            local entity = e.entity
            if entity.x == x and entity.y == y then
                return {
                    dir = DIRECTION[entity.direction],
                    prototype_name = get_prototype_name(entity.prototype),
                    x = entity.x,
                    y = entity.y,
                }
            end
        end
    end
end

return m