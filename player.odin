package main

import "core:log"
import "core:math"
import l "core:math/linalg"
import rl "vendor:raylib"

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
	state:           Player_State,
	prev_state:      Player_State,
	flags:           bit_set[Player_Flag],
	flag_timers:     [Player_Flag]f32,
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
	world.camera.look_target.x = player.translation.x
	world.camera.look_target.z = player.translation.z


	// Follow the players Y position at a speed based on if the current target is above or below the player
	look_speed: f32
	if world.camera.look_target.y < player.translation.y {
		if .Grounded in player.flags {
			look_speed = 5
		} else {
			look_speed = 2
		}
	} else {
		look_speed = 8.5
	}
	world.camera.look_target.y = l.lerp(
		world.camera.look_target.y,
		player.translation.y,
		delta * look_speed,
	)
	poll_input(player)
	update_player_orientation(player, delta)
	update_player_velocity(player, delta)
	apply_player_gravity(player, delta)
	apply_player_velocity(player, delta)
	player_level_collision(player)
	player_jump(player)
	player_dive(player)
	manage_player_state(player)
	handle_player_state_transitions(player)
	manage_player_flags(player, delta)
}

update_player_orientation :: proc(player: ^Player, delta: f32) {
	player.forward = {math.sin(player.rotation), 0, math.cos(player.rotation)}
	player.right = -l.cross(player.forward, Vec3{0, 1, 0})
	player.angle_to_delta =
		player.move_delta == VEC0 ? 0 : signed_angle_between(player.forward, player.move_delta)
	if player.move_delta != VEC0 {
		if player.state == .Sliding {
			if math.abs(player.angle_to_delta) > 0.032 {
				player.rotation = l.lerp(
					player.rotation,
					player.rotation - player.angle_to_delta,
					delta * player.turnspeed / 3,
				)
			} else {
				player.rotation -= player.angle_to_delta
			}
		} else {
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
	}
	if player.rotation > PI2 * 20 {
		player.rotation -= PI2 * 20
	}
	if player.rotation < -PI2 * 20 {
		player.rotation += PI2 * 20
	}
	player.current_speed = l.dot(player.forward, Vec3{player.velocity.x, 0, player.velocity.z})
}

manage_player_flags :: proc(player: ^Player, delta: f32) {
	for v in Player_Flag {
		timer := &player.flag_timers[v]
		// Set an arbitrary max flag value of 100 seconds
		timer^ = math.clamp(timer^ - delta, 0, 100)
		if timer^ <= 0.0 {
			// Could fire an event when a flag falls off
			player.flags -= {v}
		}
	}
}

player_dive :: proc(player: ^Player) {
	if player.state in AIRBORNE_STATE_SET &&
	   is_action_buffered(.Kick) &&
	   .Jump_Propulsion not_in player.flags {
		add_player_flag(.Dive_Initiate)
		consume_action(.Kick)
	}
}

player_jump :: proc(player: ^Player) {
	if is_action_buffered(.Jump) {
		if .Grounded in player.flags {
			if .Tripple_Jump in player.flags {
				player.velocity.y = calculate_tripple_jump_speed()
			} else if .Double_Jump in player.flags {
				player.velocity.y = calculate_double_jump_speed()
			} else {
				player.velocity.y = calculate_jump_speed()
			}
			add_player_flag(.Jump_Propulsion, 0.25)
			consume_action(.Jump)
			consume_action(.Kick)
		}
	}
}

apply_player_gravity :: proc(player: ^Player, delta: f32) {
	if player.velocity.y > 0 {
		player.velocity.y -= RISING_GRAVITY * delta
	} else {
		player.velocity.y -= FALLING_GRAVITY * delta
	}
}

update_player_velocity :: proc(player: ^Player, delta: f32) {
	// Lateral
	if player.state == .Diving {
	} else if player.state == .Sliding {
		player.velocity.x *= SLIDING_DECEL
		player.velocity.z *= SLIDING_DECEL
	} else {
		if player.move_delta != VEC0 {
			forward_velo :=
				player.forward *
				((MAX_SPEED + (MAX_SPEED * 0.75 * player.slope)) *
						(1 - (player.flag_timers[.Run_Startup] / 2)))
			player.velocity.x = forward_velo.x
			player.velocity.z = forward_velo.z
		} else {
			player.velocity.x *= RUNNING_DECEL
			player.velocity.z *= RUNNING_DECEL
		}
	}
	// Vertical
	if player.state == .Rising {
		past_rising_threshold := player.flag_timers[.Jump_Propulsion] < 0.1
		if past_rising_threshold && !is_action_held(.Jump) {
			player.velocity.y = 0
			remove_player_flag(.Jump_Propulsion)
		}
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
		add_player_flag(.Grounded, 0.1)
		player.slope = l.angle_between(hit_normal, VECY)
	} else {
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
