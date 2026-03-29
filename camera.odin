package main

import "core:math"
import l "core:math/linalg"
import rl "vendor:raylib"

Camera :: struct {
	using raw:     rl.Camera3D,
	target_offset: Vec3,
	target_angle:  f32,
	angle:         f32,
	look_target:   Vec3,
	smoothing:     f32,
	forward:       Vec3,
	right:         Vec3,
	mode:          Camera_Mode,
}

Camera_Mode :: enum {
	Octal,
	Free,
}

ROT_SEGMENT :: f32(math.PI / 4)

make_camera :: proc() -> Camera {
	return Camera {
		fovy = 90,
		position = {0, 0, 0},
		up = {0, 1, 0},
		target_offset = {0, 7, 5},
		smoothing = 10,
	}
}

update_camera_position :: proc() {
	delta := rl.GetFrameTime()
	shift: f32
	switch world.camera.mode {
	case .Octal:
		if rl.IsKeyPressed(.LEFT) {
			world.camera.target_angle -= ROT_SEGMENT
		}
		if rl.IsKeyPressed(.RIGHT) {
			world.camera.target_angle += ROT_SEGMENT
		}
	case .Free:
		if rl.IsKeyDown(.LEFT) {
			shift -= 1
		}

		if rl.IsKeyDown(.RIGHT) {
			shift += 1
		}
		world.camera.target_angle += delta * shift * 1
	}

	world.camera.angle = math.lerp(
		world.camera.angle,
		world.camera.target_angle,
		delta * world.camera.smoothing,
	)

	// camera.angle +=
	offset := Vec3 {
		math.cos(world.camera.angle) * world.camera.target_offset.z,
		world.camera.target_offset.y,
		math.sin(world.camera.angle) * world.camera.target_offset.z,
	}


	new_position := world.camera.look_target + offset
	world.camera.position = l.lerp(
		world.camera.position,
		new_position,
		delta * world.camera.smoothing,
	)
	world.camera.target = world.camera.look_target
	world.camera.forward = l.normalize0(world.camera.position - world.camera.look_target)
	world.camera.right = l.normalize0(l.cross(world.camera.forward, Vec3{0, 1, 0}))
}

interpolate_vector :: proc(vector: Vec3) -> Vec3 {
	true_vec := (world.camera.forward * -vector.z) + (world.camera.right * -vector.x)
	true_vec.y = 0
	return l.normalize0(true_vec)
}
