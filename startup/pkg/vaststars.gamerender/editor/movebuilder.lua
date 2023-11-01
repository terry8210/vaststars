local ecs = ...
local world = ecs.world

local CONSTANT <const> = require "gameplay.interface.constant"
local MAP_WIDTH <const> = CONSTANT.MAP_WIDTH
local MAP_HEIGHT <const> = CONSTANT.MAP_HEIGHT
local TILE_SIZE <const> = CONSTANT.TILE_SIZE
local ROTATORS <const> = CONSTANT.ROTATORS
local ROAD_SIZE <const> = CONSTANT.ROAD_SIZE
local ALL_DIR <const> = CONSTANT.ALL_DIR
local CHANGED_FLAG_BUILDING <const> = CONSTANT.CHANGED_FLAG_BUILDING
local SPRITE_COLOR <const> = ecs.require "vaststars.prototype|sprite_color"

local math3d = require "math3d"
local GRID_POSITION_OFFSET <const> = math3d.constant("v4", {0, 0.2, 0, 0.0})

local iprototype = require "gameplay.interface.prototype"
local icamera_controller = ecs.require "engine.system.camera_controller"
local create_builder = ecs.require "editor.builder"
local ieditor = ecs.require "editor.editor"
local objects = require "objects"
local iobject = ecs.require "object"
local imining = require "gameplay.interface.mining"
local igrid_entity = ecs.require "engine.grid_entity"
local mc = import_package "ant.math".constant
local create_road_entrance = ecs.require "editor.road_entrance"
local global = require "global"
local create_sprite = ecs.require "sprite"
local create_pickup_icon = ecs.require "pickup_icon".create
local create_fluid_indicators = ecs.require "fluid_indicators".create
local icoord = require "coord"
local gameplay_core = require "gameplay.core"
local ibuilding = ecs.require "render_updates.building"
local create_pickup_selected_box = ecs.require "editor.common.pickup_selected_box"
local create_selected_boxes = ecs.require "selected_boxes"
local vsobject_manager = ecs.require "vsobject_manager"
local igameplay = ecs.require "gameplay_system"
local srt = require "utility.srt"
local imineral = ecs.require "mineral"

-- TODO: duplicate from roadbuilder.lua
local function _get_connections(prototype_name, x, y, dir)
    local typeobject = iprototype.queryByName(prototype_name)
    local r = {}
    if not typeobject.crossing then
        return r
    end

    for _, conn in ipairs(typeobject.crossing.connections) do
        local dx, dy, ddir = iprototype.rotate_connection(conn.position, dir, typeobject.area)
        r[#r+1] = {x = x + dx, y = y + dy, dir = ddir}
    end
    return r
end

local function _get_road_entrance_position(typeobject, x, y, dir)
    if not typeobject.crossing then
        return
    end
    local connections = _get_connections(typeobject.name, x, y, dir)
    local conn = connections[1]
    local succ, neighbor_x, neighbor_y = icoord.move(conn.x, conn.y, conn.dir, 1)
    if not succ then
        return
    end
    return math3d.vector(icoord.position(neighbor_x, neighbor_y, 1, 1)), neighbor_x, neighbor_y, conn.dir
end

local function __create_self_sprite(typeobject, x, y, dir, sprite_color)
    local sprite
    local offset_x, offset_y = 0, 0
    if typeobject.supply_area then
        local aw, ah = iprototype.rotate_area(typeobject.supply_area, dir)
        local w, h = iprototype.rotate_area(typeobject.area, dir)
        offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        sprite = create_sprite(x + offset_x, y + offset_y, aw, ah, dir, sprite_color)
    end
    return sprite
end

local function __get_nearby_buldings(exclude_id, x, y, w, h)
    local r = {}
    local begin_x, begin_y = icoord.bound(x - ((10 - w) // 2), y - ((10 - h) // 2))
    local end_x, end_y = icoord.bound(x + ((10 - w) // 2) + w, y + ((10 - h) // 2) + h)
    for x = begin_x, end_x do
        for y = begin_y, end_y do
            local object = objects:coord(x, y)
            if object and object.id ~= exclude_id then
                r[object.id] = object
            end
        end
    end
    return r
end

local function __is_building_intersect(x1, y1, w1, h1, x2, y2, w2, h2)
    local x1_1, y1_1 = x1, y1
    local x1_2, y1_2 = x1 + w1 - 1, y1
    local x1_3, y1_3 = x1, y1 + h1 - 1
    local x1_4, y1_4 = x1 + w1 - 1, y1 + h1 - 1

    if (x1_1 >= x2 and x1_1 <= x2 + w2 - 1 and y1_1 >= y2 and y1_1 <= y2 + h2 - 1) or
        (x1_2 >= x2 and x1_2 <= x2 + w2 - 1 and y1_2 >= y2 and y1_2 <= y2 + h2 - 1) or
        (x1_3 >= x2 and x1_3 <= x2 + w2 - 1 and y1_3 >= y2 and y1_3 <= y2 + h2 - 1) or
        (x1_4 >= x2 and x1_4 <= x2 + w2 - 1 and y1_4 >= y2 and y1_4 <= y2 + h2 - 1) then
        return true
    end

    local x2_1, y2_1 = x2, y2
    local x2_2, y2_2 = x2 + w2 - 1, y2
    local x2_3, y2_3 = x2, y2 + h2 - 1
    local x2_4, y2_4 = x2 + w2 - 1, y2 + h2 - 1

    if (x2_1 >= x1 and x2_1 <= x1 + w1 - 1 and y2_1 >= y1 and y2_1 <= y1 + h1 - 1) or
        (x2_2 >= x1 and x2_2 <= x1 + w1 - 1 and y2_2 >= y1 and y2_2 <= y1 + h1 - 1) or
        (x2_3 >= x1 and x2_3 <= x1 + w1 - 1 and y2_3 >= y1 and y2_3 <= y1 + h1 - 1) or
        (x2_4 >= x1 and x2_4 <= x1 + w1 - 1 and y2_4 >= y1 and y2_4 <= y1 + h1 - 1) then
        return true
    end

    return false
end

local function __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)
    local nearby_buldings = __get_nearby_buldings(self.move_object_id, x, y, iprototype.rotate_area(typeobject.area, dir))
    local w, h = iprototype.rotate_area(typeobject.area, dir)

    local redraw = {}
    for object_id, object in pairs(nearby_buldings) do
        redraw[object_id] = object
    end

    for object_id, o in pairs(self.selected_boxes) do
        o:remove()
        self.selected_boxes[object_id] = nil
    end

    for object_id, object in pairs(redraw) do
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if __is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if __is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(otypeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                        if __is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                        else
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                        end
                    else
                        color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                    end
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            end
        end

        self.selected_boxes[object_id] = create_selected_boxes(
            {
                "/pkg/vaststars.resources/glbs/selected-box-no-animation.glb|mesh.prefab",
                "/pkg/vaststars.resources/glbs/selected-box-no-animation-line.glb|mesh.prefab",
            },
            object.srt.t, color, iprototype.rotate_area(otypeobject.area, object.dir)
        )
    end

    for object_id, o in pairs(self.selected_boxes) do
        local object = assert(objects:get(object_id))
        local otypeobject = iprototype.queryByName(object.prototype_name)
        local ow, oh = iprototype.rotate_area(otypeobject.area, object.dir)

        local color
        if __is_building_intersect(x, y, w, h, object.x, object.y, ow, oh) then
            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_FARAWAY_BUILDINGS_INTERSECTION
        else
            if typeobject.supply_area then
                local aw, ah = iprototype.rotate_area(typeobject.area, object.dir)
                local sw, sh = iprototype.rotate_area(typeobject.supply_area, object.dir)
                if __is_building_intersect(x - (sw - aw) // 2, y - (sh - ah) // 2, sw, sh, object.x, object.y, ow, oh) then
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            else
                if iprototype.has_types(typeobject.type, "station") then
                    if otypeobject.supply_area then
                        local aw, ah = iprototype.rotate_area(otypeobject.area, object.dir)
                        local sw, sh = iprototype.rotate_area(otypeobject.supply_area, object.dir)
                        if __is_building_intersect(x, y, ow, oh, object.x  - (sw - aw) // 2, object.y - (sh - ah) // 2, sw, sh) then
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS_DRONE_DEPOT_SUPPLY_AREA
                        else
                            color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                        end
                    else
                        color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                    end
                else
                    color = SPRITE_COLOR.CONSTRUCT_OUTLINE_NEARBY_BUILDINGS
                end
            end
        end
        o:set_color_transition(color, 400)
    end
end

local function __new_entity(self, datamodel, typeobject)
    local object = assert(objects:get(self.move_object_id))

    iobject.remove(self.pickup_object)
    local dir = object.dir
    local x, y = iobject.central_coord(typeobject.name, dir)
    if not x or not y then
        return
    end
    local building_positon = icoord.position(x, y, iprototype.rotate_area(typeobject.area, dir))

    local sprite_color
    if not self:check_construct_detector(typeobject.name, x, y, dir) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        end
        datamodel.show_confirm = false
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        end
        datamodel.show_confirm = true
    end
    datamodel.show_rotate = (typeobject.rotate_on_build == true)

    local object = assert(objects:get(self.move_object_id))
    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "translucent", color = SPRITE_COLOR.MOVE_SELF, emissive_color = SPRITE_COLOR.MOVE_SELF}

    local e = assert(gameplay_core.get_entity(object.gameplay_eid))

    self.pickup_object = iobject.new {
        prototype_name = typeobject.name,
        dir = dir,
        x = x,
        y = y,
        srt = srt.new {
            t = math3d.vector(building_positon),
            r = ROTATORS[dir],
        },
        group_id = 0,
    }

    if e.assembling and e.assembling.recipe ~= 0 then
        self.pickup_components.pickup_icon = create_pickup_icon(typeobject, dir, object.gameplay_eid, self.pickup_object.srt)
    end
    if e.chimney then
        self.pickup_components.fluid_indicators = create_fluid_indicators(dir, self.pickup_object.srt, typeobject)
    end
    self.pickup_components.self_selected_box = create_pickup_selected_box(self.pickup_object.srt.t, typeobject.area, dir, datamodel.show_confirm and true or false)
    __show_nearby_buildings_selected_boxes(self, x, y, dir, typeobject)

    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = __create_self_sprite(typeobject, x, y, dir, sprite_color)

    local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, x, y, dir)
    if road_entrance_position then
        local srt = {t = road_entrance_position, r = ROTATORS[road_entrance_dir]}
        if datamodel.show_confirm then
            self.road_entrance = create_road_entrance(srt.t, "valid")
        else
            self.road_entrance = create_road_entrance(srt.t, "invalid")
        end
    end
end

local function __calc_grid_position(self, typeobject, dir)
    local _, originPosition = icoord.align(math3d.vector {0, 0, 0}, iprototype.rotate_area(typeobject.area, dir))
    local buildingPosition = icoord.position(self.pickup_object.x, self.pickup_object.y, iprototype.rotate_area(typeobject.area, dir))
    return math3d.add(math3d.sub(buildingPosition, originPosition), GRID_POSITION_OFFSET)
end

local function new_entity(self, datamodel, typeobject)
    __new_entity(self, datamodel, typeobject)
    self.pickup_object.APPEAR = true

    if not self.grid_entity then
        if iprototype.has_types(typeobject.type, "station") then
            self.grid_entity = igrid_entity.create(MAP_WIDTH // ROAD_SIZE, MAP_HEIGHT // ROAD_SIZE, TILE_SIZE * ROAD_SIZE, {t = __calc_grid_position(self, typeobject, self.pickup_object.dir)})
        else
            self.grid_entity = igrid_entity.create(MAP_WIDTH, MAP_HEIGHT, TILE_SIZE, {t = __calc_grid_position(self, typeobject, self.pickup_object.dir)})
        end
    end

    self.typeobject = typeobject
end

-- TODO: duplicate from builder.lua
local function _get_mineral_recipe(prototype_name, x, y, w, h)
    local typeobject = iprototype.queryByName(prototype_name)
    if not iprototype.has_type(typeobject.type, "mining") then
        return
    end
    local succ, mineral = imineral.can_place(x, y, w, h)
    if not succ then
        return
    end
    return imining.get_mineral_recipe(prototype_name, mineral)
end

local function __align(object)
    assert(object)
    local typeobject = iprototype.queryByName(object.prototype_name)
    local coord, position = icoord.align(icamera_controller.get_central_position(), iprototype.rotate_area(typeobject.area, object.dir))
    if not coord then
        return object
    end

    if iprototype.has_types(typeobject.type, "station") then
        coord[1], coord[2] = coord[1] - (coord[1] % ROAD_SIZE), coord[2] - (coord[2] % ROAD_SIZE)
        position = math3d.vector(icoord.position(coord[1], coord[2], iprototype.rotate_area(typeobject.area, object.dir)))
    end

    object.srt.t = math3d.vector(position)
    return object, coord[1], coord[2]
end

local function touch_move(self, datamodel, delta_vec)
    if not self.pickup_object then
        return
    end
    local pickup_object = self.pickup_object
    iobject.move_delta(pickup_object, delta_vec)

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    local lx, ly = x, y
    if not lx then
        datamodel.show_confirm = false
        return
    end
    pickup_object.x, pickup_object.y = lx, ly

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)

    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.pickup_object.srt, self.pickup_object.dir)
    end

    if self.road_entrance then
        local road_entrance_position, _, _, road_entrance_dir = _get_road_entrance_position(typeobject, lx, ly, pickup_object.dir)
        self.road_entrance:set_srt(mc.ONE, ROTATORS[road_entrance_dir], road_entrance_position)

        local t = {}
        for _, dir in ipairs(ALL_DIR) do
            local _, dx, dy = _get_road_entrance_position(typeobject, lx, ly, dir)
            if dx and dy then
                if ibuilding.get(dx, dy) then
                    t[#t+1] = dir
                end
            end
        end
        if #t == 1 and t[1] ~= pickup_object.dir then
            self:rotate(datamodel, t[1], delta_vec)
        end
    end

    if self.grid_entity then
        self.grid_entity:set_position(__calc_grid_position(self, typeobject, pickup_object.dir))
    end

    local sprite_color
    local offset_x, offset_y = 0, 0
    local w, h = iprototype.rotate_area(typeobject.area, pickup_object.dir)
    if not self:check_construct_detector(pickup_object.prototype_name, lx, ly, pickup_object.dir) then -- TODO
        datamodel.show_confirm = false

        if self.road_entrance then
            self.road_entrance:set_state("invalid")
        end
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
            local aw, ah = iprototype.rotate_area(typeobject.supply_area, pickup_object.dir)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        end
        if self.sprite then
            self.sprite:move(pickup_object.x + offset_x, pickup_object.y + offset_y, sprite_color)
        end
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(datamodel.show_confirm)
        end
        __show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)
        return
    else
        datamodel.show_confirm = true

        if self.road_entrance then
            self.road_entrance:set_state("valid")
        end
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
            local aw, ah = iprototype.rotate_area(typeobject.supply_area, pickup_object.dir)
            offset_x, offset_y = -((aw - w)//2), -((ah - h)//2)
        end
        if self.sprite then
            self.sprite:move(pickup_object.x + offset_x, pickup_object.y + offset_y, sprite_color)
        end
        for _, c in pairs(self.pickup_components) do
            c:on_status_change(datamodel.show_confirm)
        end
        __show_nearby_buildings_selected_boxes(self, x, y, pickup_object.dir, typeobject)
    end

    pickup_object.recipe = _get_mineral_recipe(pickup_object.prototype_name, x, y, w, h)
end

local function touch_end(self, datamodel)
    ieditor:revert_changes({"TEMPORARY"})

    touch_move(self, datamodel, {0, 0, 0})
end

local function confirm(self, datamodel)
    ---
    local object = assert(objects:get(self.move_object_id))
    local e = gameplay_core.get_entity(object.gameplay_eid)
    e.building_changed = true
    igameplay.move(object.gameplay_eid, self.pickup_object.x, self.pickup_object.y)
    igameplay.rotate(object.gameplay_eid, self.pickup_object.dir)
    gameplay_core.set_changed(CHANGED_FLAG_BUILDING)

    iobject.coord(object, self.pickup_object.x, self.pickup_object.y)
    object.dir = self.pickup_object.dir
    object.srt.r = ROTATORS[object.dir]
    objects:set(object, "CONSTRUCTED")
    objects:coord_update(object)

    local building = global.buildings[object.id]
    if building then
        for _, v in pairs(building) do
            v:on_position_change(object.srt, object.dir)
        end
    end

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end
    iobject.remove(self.pickup_object)
    self.pickup_object = nil

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false
    datamodel.show_cancel = false
end

local function check_construct_detector(self, prototype_name, x, y, dir)
    local succ = self.super:check_construct_detector(prototype_name, x, y, dir, self.move_object_id)
    if not succ then
        return false
    end

    local typeobject = iprototype.queryByName(prototype_name)
    if typeobject.crossing then
        local valid = false
        for _, conn in ipairs(_get_connections(prototype_name, x, y, dir)) do
            local succ, dx, dy = icoord.move(conn.x, conn.y, conn.dir, 1)
            if not succ then
                goto continue
            end

            if ibuilding.get(dx, dy) then
                valid = true
                break
            end
            ::continue::
        end

        if not valid then
            return false
        end
    end

    return true
end

local function rotate(self, datamodel, dir, delta_vec)
    local pickup_object = assert(self.pickup_object)

    ieditor:revert_changes({"TEMPORARY"})
    dir = dir or iprototype.rotate_dir_times(pickup_object.dir, -1)
    pickup_object.dir = iprototype.dir_tostring(dir)
    pickup_object.srt.r = ROTATORS[pickup_object.dir]

    local x, y
    self.pickup_object, x, y = __align(self.pickup_object)
    local lx, ly = x, y
    if not lx then
        datamodel.show_confirm = false
        return
    end
    pickup_object.x, pickup_object.y = lx, ly

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    for _, c in pairs(self.pickup_components) do
        c:on_position_change(self.pickup_object.srt, self.pickup_object.dir)
    end
    local coord = icoord.align(icamera_controller.get_central_position(), iprototype.rotate_area(typeobject.area, dir))
    if not coord then
        return
    end

    local typeobject = iprototype.queryByName(pickup_object.prototype_name)
    local sprite_color
    if not self:check_construct_detector(typeobject.name, pickup_object.x, pickup_object.y, pickup_object.dir) then
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_INVALID
        end
        datamodel.show_confirm = false
    else
        if typeobject.supply_area then
            sprite_color = SPRITE_COLOR.CONSTRUCT_DRONE_DEPOT_SUPPLY_AREA_SELF_VALID
        end
        datamodel.show_confirm = true
    end

    if self.sprite then
        self.sprite:remove()
    end
    self.sprite = __create_self_sprite(typeobject, x, y, pickup_object.dir, sprite_color)

    local road_entrance_position, dx, dy, ddir = _get_road_entrance_position(typeobject, x, y, pickup_object.dir)
    if road_entrance_position then
        self.road_entrance:set_srt(mc.ONE, ROTATORS[ddir], road_entrance_position)
    end
end

local function clean(self, datamodel)
    if self.grid_entity then
        self.grid_entity:remove()
        self.grid_entity = nil
    end

    ieditor:revert_changes({"TEMPORARY"})
    datamodel.show_confirm = false
    datamodel.show_rotate = false

    for _, o in pairs(self.selected_boxes) do
        o:remove()
    end
    self.selected_boxes = {}

    for _, c in pairs(self.pickup_components) do
        c:remove()
    end

    self.super.clean(self, datamodel)

    if self.road_entrance then
        self.road_entrance:remove()
        self.road_entrance = nil
    end
    if self.sprite then
        self.sprite:remove()
        self.sprite = nil
    end

    local vsobject = assert(vsobject_manager:get(self.move_object_id))
    vsobject:update {state = "opaque", color = "null", emissive_color = "null"}
end

local function create(move_object_id)
    local builder = create_builder()

    local M = setmetatable({super = builder}, {__index = builder})
    M.new_entity = new_entity
    M.touch_move = touch_move
    M.touch_end = touch_end
    M.confirm = confirm
    M.rotate = rotate
    M.clean = clean
    M.check_construct_detector = check_construct_detector
    M.move_object_id = move_object_id
    M.pickup_components = {}
    M.selected_boxes = {}
    M.typeobject = nil
    M.continue_construct = false

    return M
end
return create