package main

import "core:math"
import l "core:math/linalg"
import rl "vendor:raylib"

Camera :: struct {
	using raw:        rl.Camera3D,
	target_angle:     f32,
	angle:            f32,
	look_target:      Vec3,
	smoothing:        f32,
	forward:          Vec3,
	right:            Vec3,
	mode:             Camera_Mode,
	min_z_offset:     f32,
	current_z_offset: f32,
	max_z_offset:     f32,
	min_y_offset:     f32,
	current_y_offset: f32,
	max_y_offset:     f32,
}

Camera_Mode :: enum {
	Octal,
	Dynamic,
	FreeRotate,
}

ROT_SEGMENT :: f32(math.PI / 4)

make_camera :: proc() -> Camera {
	return Camera {
		fovy = 90,
		position = {0, 0, 0},
		up = {0, 1, 0},
		min_z_offset = 3,
		current_z_offset = 3,
		min_y_offset = 2.5,
		current_y_offset = 2.5,
		smoothing = 10,
		mode = .Dynamic,
	}
}

update_camera_position :: proc() {
	delta := rl.GetFrameTime()
	shift: f32
	camera := &world.camera
	player := world.player

	switch camera.mode {
	case .Octal:
		if rl.IsKeyPressed(.LEFT) {
			camera.target_angle -= ROT_SEGMENT
		}
		if rl.IsKeyPressed(.RIGHT) {
			camera.target_angle += ROT_SEGMENT
		}
	case .Dynamic:
		camera.target_angle = -player.rotation - (2 * ROT_SEGMENT)
	case .FreeRotate:
		if rl.IsKeyDown(.LEFT) {
			shift -= 1
		}

		if rl.IsKeyDown(.RIGHT) {
			shift += 1
		}
		camera.target_angle += delta * shift * 1
	}

	if camera.target_angle > PI2 * 20 {
		camera.target_angle -= PI2 * 20
	}
	if camera.target_angle < -PI2 * 20 {
		camera.target_angle += PI2 * 20
	}
	if camera.angle > PI2 * 20 {
		camera.angle -= PI2 * 20
	}
	if camera.angle < -PI2 * 20 {
		camera.angle += PI2 * 20
	}

	if math.abs(camera.angle - camera.target_angle) > 0.087 {
		camera.angle = math.lerp(camera.angle, camera.target_angle, delta * camera.smoothing)
	} else {
		camera.angle = camera.target_angle
	}

	// Update camera z offset based on comparitve y axis and player lateral speed
	camera.current_z_offset = l.lerp(
		camera.current_z_offset,
		camera.min_z_offset + (player.current_speed / 4),
		delta,
	)
	camera.current_y_offset = l.lerp(
		camera.current_y_offset,
		camera.min_y_offset - (player.current_speed / 4),
		delta,
	)

	offset := Vec3 {
		math.cos(camera.angle) * camera.current_z_offset,
		camera.current_y_offset,
		math.sin(camera.angle) * camera.current_z_offset,
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
