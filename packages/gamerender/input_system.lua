local ecs = ...
local world = ecs.world
local w = world.w

local irq		= ecs.import.interface "ant.render|irenderqueue"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local mc = import_package "ant.math".constant
local math3d = require "math3d"

local iinput = ecs.interface "iinput"

function iinput.ray_hit_plane(ray, plane_info)
	local plane = {n = plane_info.dir, d = -math3d.dot(math3d.vector(plane_info.dir), math3d.vector(plane_info.pos))}

	local rayOriginVec = ray.origin
	local rayDirVec = ray.dir
	local planeDirVec = math3d.vector(plane.n[1], plane.n[2], plane.n[3])

	local d = math3d.dot(planeDirVec, rayDirVec)
	if math.abs(d) > 0.00001 then
		local t = -(math3d.dot(planeDirVec, rayOriginVec) + plane.d) / d
		if t >= 0.0 then
			return math3d.add(ray.origin, math3d.mul(t, ray.dir))
		end
	end
end

-- call in 'camera_usage' stage
function iinput.screen_to_world(x, y)
    local main_camera = world:entity(irq.main_camera())
    local position = iinput.ray_hit_plane(iom.ray(main_camera.camera.viewprojmat, {x, y}), {dir = mc.YAXIS, pos = mc.ZERO_PT})
    if not position then
        return
    end
    return math3d.tovalue(position)
end
