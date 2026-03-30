package main

import "core:log"
import "core:math"
import l "core:math/linalg"
import rl "vendor:raylib"

P_SPEED := calculate_ground_speed()
P_DECEL: f32 : 0.997
PI2: f32 : math.PI * 2
cast_point: Vec3

Player :: struct {
	translation:     Vec3,
	current_speed:   f32,
	velocity:        Vec3,
	turnspeed:       f32,
	move_delta:      Vec3,
	rotation:        f32,
	forward:         Vec3,
	angle_to_delta:  f32,
	right:           Vec3,
	slope:           f32,
	flags:           bit_set[Player_Flag],
	shadow_position: Vec3,
	shadow_distance: f32,
}

make_player :: proc(translation: Vec3) -> (player: Player) {
	player.translation = translation
	player.turnspeed = 3
	return
}

update_player :: proc() {
	delta := rl.GetFrameTime()
	player := &world.player
	// Nested procs here don't need to be called anywhere else but i don't want to polute the scope for the LSP
	update_player_orientation :: proc(player: ^Player, delta: f32) {
		player.forward = {math.sin(player.rotation), 0, math.cos(player.rotation)}
		player.right = -l.cross(player.forward, Vec3{0, 1, 0})
		player.angle_to_delta =
			player.move_delta == VEC0 ? 0 : signed_angle_between(player.forward, player.move_delta)
		if player.move_delta != VEC0 {
			if math.abs(player.angle_to_delta) > 0.087 {
				player.rotation = l.lerp(
					player.rotation,
					player.rotation - player.angle_to_delta,
					delta * player.turnspeed,
				)
			} else {
				player.rotation -= player.angle_to_delta
			}
		}
		if player.rotation > PI2 * 20 {
			player.rotation -= PI2 * 20
		}
		if player.rotation < -PI2 * 20 {
			player.rotation += PI2 * 20
		}
		player.current_speed = l.dot(player.forward, Vec3{player.velocity.x, 0, player.velocity.z})
	}
	world.camera.look_target.x = player.translation.x
	world.camera.look_target.z = player.translation.z


	// Follow the players Y position at a speed based on if the current target is above or below the player
	look_speed: f32
	if world.camera.look_target.y < player.translation.y {
		look_speed = 5
	} else {
		look_speed = 8.5
	}
	world.camera.look_target.y = l.lerp(
		world.camera.look_target.y,
		player.translation.y,
		delta * look_speed,
	)
	set_player_move_delta()
	update_player_orientation(player, delta)
	set_player_velocity(player)
	apply_player_gravity(player, delta)
	apply_player_velocity(player, delta)
	player_level_collision(player)
	player_jump(player)
}

player_jump :: proc(player: ^Player) {
	if rl.IsKeyPressed(.SPACE) {
		if .Grounded in player.flags {
			player.velocity.y = calculate_jump_speed()
		}
	}
}

set_player_move_delta :: proc() {
	raw_delta: Vec3

	if rl.IsKeyDown(.W) {
		raw_delta.z += 1
	}
	if rl.IsKeyDown(.S) {
		raw_delta.z -= 1
	}
	if rl.IsKeyDown(.A) {
		raw_delta.x -= 1
	}
	if rl.IsKeyDown(.D) {
		raw_delta.x += 1
	}
	world.player.move_delta = interpolate_vector(l.normalize0(raw_delta))
}

apply_player_gravity :: proc(player: ^Player, delta: f32) {
	if player.velocity.y > 0 {
		player.velocity.y -= rising_gravity * delta
	} else {
		player.velocity.y -= falling_gravity * delta
	}
}

set_player_velocity :: proc(player: ^Player) {
	if player.move_delta != VEC0 {
		forward_velo := player.forward * P_SPEED + (P_SPEED * 0.75 * player.slope * player.forward)
		player.velocity.x = forward_velo.x
		player.velocity.z = forward_velo.z
	} else {
		player.velocity.x *= P_DECEL
		player.velocity.z *= P_DECEL
	}
}

apply_player_velocity :: proc(player: ^Player, delta: f32) {
	player.translation += player.velocity * delta
}

player_level_collision :: proc(player: ^Player) {
	ground_ray := rl.Ray {
		position  = player.translation,
		direction = -VECY,
	}
	on_ground: bool
	hit_normal := VECY

	for collision_data in world.level_collision {
		collides, collision := sphere_level_collision_test(
			{center = world.player.translation, radius = 0.5},
			collision_data,
		)
		if collides {
			resolve_player_level_collision(player, collision)
		}

		// Ground cast
		ground_ray_collision := rl.GetRayCollisionMesh(
			ground_ray,
			assets.gym.meshes[collision_data.mesh_idx],
			rl.Matrix(1),
		)
		if ground_ray_collision.hit {
			if ground_ray_collision.distance < 1 {
				on_ground = true
				hit_normal = ground_ray_collision.normal
				cast_point = ground_ray_collision.point
			}
			player.shadow_position = ground_ray_collision.point
			player.shadow_distance = ground_ray_collision.distance
		}
	}
	if on_ground {
		add_player_flag(.Grounded)
		player.slope = l.angle_between(hit_normal, VECY)
	} else {
		remove_player_flag(.Grounded)
		player.slope = 0
	}
}

resolve_player_level_collision :: proc(player: ^Player, collision: Collision) {
	lateral_collision := math.abs(l.dot(collision.normal, VECY)) < 0.25

	// SAT collision
	if lateral_collision {
		lateral_velo := Vec3{player.velocity.x, 0, player.velocity.z}
		lateral_normal := l.normalize0(Vec3{collision.normal.x, 0, collision.normal.z})
		velo_along_axis := l.dot(lateral_normal, lateral_velo)
		new_velo := player.velocity - velo_along_axis * lateral_normal
		player.velocity = new_velo
		// if l.dot(collision.normal, VECX) > 0.5 {
		// }
		// Bonk Check here, if our forward speed is above a threshold and we're not grounded
	} else {
		player.velocity.y = 0
	}
	player.translation += collision.depth * collision.normal
}


draw_player :: proc() {
	player := &world.player
	rl.DrawSphere(player.translation, 0.5, rl.PINK)

	forward_point := player.translation + (player.forward * 2)
	rl.DrawLine3D(player.translation, forward_point, rl.RED)

	shadow_scale_factor := 2 / player.shadow_distance
	shadow_scale := clamp(shadow_scale_factor, 0.25, 1)
	rl.DrawModel(
		assets.flat_quad,
		player.shadow_position + Vec3{0, 0.1, 0},
		shadow_scale,
		rl.WHITE,
	)
	// delta_point := player.translation + (player.move_delta * 2)
	// rl.DrawLine3D(player.translation, delta_point, rl.GREEN)
}
