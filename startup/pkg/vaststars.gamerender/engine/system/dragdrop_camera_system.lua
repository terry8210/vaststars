local ecs = ...
local world = ecs.world
local w = world.w

local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local math3d = require "math3d"
local camera = ecs.require "engine.camera"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}
local dragdrop_camera_sys = ecs.system "dragdrop_camera_system"
local single_touch_mb = world:sub {"single_touch"}
local mouse_wheel_mb    = world:sub {"mouse_wheel"}
local ui_message_move_camera_mb = world:sub {"ui_message", "move_camera"}

local cam_target = math3d.ref()
local cam_dir = math3d.ref()
local cam_pos = math3d.ref()
local cam_dist = 0
local max_dist = 220
local min_dist = 100
local zoom_speed = 2

local function ray_hit_plane(ray, plane_info)
    if not plane_info then
        plane_info = {dir = math3d.vector{0, 1, 0}, pos = math3d.vector{0, 0, 0}}
    end
	local plane = {n = plane_info.dir, d = -math3d.dot(plane_info.dir, plane_info.pos)}

	local rayOriginVec = ray.origin
	local rayDirVec = ray.dir
	local planeDirVec = plane.n

	local d = math3d.dot(planeDirVec, rayDirVec)
	if math.abs(d) > 0.00001 then
		local t = -(math3d.dot(planeDirVec, rayOriginVec) + plane.d) / d
		if t >= 0.0 then
			return math3d.add(ray.origin, math3d.mul(t, ray.dir))
		end	
	end
	return nil
end

local function zoom(ce, delta)
    cam_dist = cam_dist - delta * zoom_speed
    if cam_dist > max_dist then
        cam_dist = max_dist
    elseif cam_dist < min_dist then
        cam_dist = min_dist
    end
    cam_pos.v = math3d.add(cam_target, math3d.mul(cam_dir, -cam_dist))
    iom.set_position(ce, cam_pos)
end
local function dist_sqr(x1,y1, x2,y2)
    local dx = (x2 - x1)
    local dy = (y2 - y1)
    return math.sqrt(dx * dx + dy * dy)
end

local begin_pos
local touch_id1, touch_id2
local down_cam_dist
local last_move_x, last_move_y
local last_move_x2, last_move_y2
local zoom_mode = false
local function update_camera_position(delta)
    cam_pos.v = math3d.add(cam_pos, delta)
    cam_target.v = math3d.add(cam_target, delta)
end
function dragdrop_camera_sys:camera_usage()
    local mq = w:first("main_queue camera_ref:in")
    local ce <close> = w:entity(mq.camera_ref)
    local delta_dist
    for _, state, data in single_touch_mb:unpack() do
        if state == "START" then
            if not touch_id1 then
                touch_id1 = data.id
                begin_pos = math3d.ref(camera.screen_to_world(data.x, data.y, PLANES)[1])
                last_move_x, last_move_y = data.x, data.y
            elseif not touch_id2 then
                touch_id2 = data.id
                last_move_x2, last_move_y2 = data.x, data.y
                down_cam_dist = dist_sqr(last_move_x, last_move_y, last_move_x2, last_move_y2)
                if not zoom_mode then
                    zoom_mode = true
                end
            end
        elseif state == "MOVE" then
            if touch_id1 and touch_id1 == data.id then
                last_move_x, last_move_y = data.x, data.y
            elseif touch_id2 and touch_id2 == data.id then
                last_move_x2, last_move_y2 = data.x, data.y
            end
            if touch_id1 and touch_id2 then
                local current_dist = dist_sqr(last_move_x, last_move_y, last_move_x2, last_move_y2)
                delta_dist = (current_dist - down_cam_dist) * 0.25
                down_cam_dist = current_dist
            end
        elseif state == "CANCEL" or state == "END" then
            if touch_id1 == data.id then
                begin_pos = nil
                touch_id1 = nil
            end
            if touch_id2 == data.id then
                touch_id2 = nil
                delta_dist = nil
            end
            if zoom_mode and not touch_id1 and not touch_id2 then
                zoom_mode = false
            end
        end
    end

    if not cam_pos.v then
        cam_pos.v = iom.get_position(ce)
        local rot = iom.get_rotation(ce)
        cam_dir.v = math3d.normalize(math3d.transform(rot, math3d.vector(0.0, 0.0, 1.0), 0))
        cam_target.v = ray_hit_plane({origin = cam_pos, dir = cam_dir})
        cam_dist = math3d.length(math3d.sub(cam_target, cam_pos))
    end
    if not zoom_mode then
        if begin_pos and last_move_x and last_move_y then
            local pos = camera.screen_to_world(last_move_x, last_move_y, PLANES)[1]
            local delta = math3d.sub(begin_pos, pos)
            iom.move_delta(ce, delta)
            update_camera_position(delta)
            world:pub {"dragdrop_camera", math3d.ref(delta)}
        end
    elseif delta_dist then
        zoom(ce, delta_dist)
    end

    --zoom in/out
    for _, delta in mouse_wheel_mb:unpack() do
        zoom(ce, delta)
    end

    for _, _, left, top, position in ui_message_move_camera_mb:unpack() do
        local mq = w:first("main_queue render_target:in")
        local vr = mq.render_target.view_rect
        local vmin = math.min(vr.w / vr.ratio, vr.h / vr.ratio)
        local ui_position = camera.screen_to_world(left / 100 * vmin, top / 100 * vmin, PLANES)[1]

        local delta = math3d.set_index(math3d.sub(position, ui_position), 2, 0) -- the camera is always moving in the x/z axis and the y axis is always 0
        iom.move_delta(ce, delta)
    end
end