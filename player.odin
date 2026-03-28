package main

import "core:math"
import l "core:math/linalg"
import rl "vendor:raylib"

P_SPEED: f32 : 3
P_DECEL: f32 : 0.8

Player :: struct {
	translation:    Vec3,
	velocity:       Vec3,
	turnspeed:      f32,
	move_delta:     Vec3,
	angle_to_delta: f32,
	rotation:       f32,
	forward:        Vec3,
	right:          Vec3,
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
		player.rotation = l.lerp(
			player.rotation,
			player.rotation - player.angle_to_delta,
			delta * player.turnspeed,
		)
	}
	world.camera.look_target = player.translation
	set_player_move_delta()
	update_player_orientation(player, delta)
	set_player_velocity(player)
	apply_player_velocity(player, delta)
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

set_player_velocity :: proc(player: ^Player) {
	if player.move_delta != VEC0 {
		player.velocity = player.forward * P_SPEED
	} else {
		player.velocity.x *= P_DECEL
		player.velocity.z *= P_DECEL
	}
}

apply_player_velocity :: proc(player: ^Player, delta: f32) {
	player.translation += player.velocity * delta
}


draw_player :: proc() {
	player := &world.player
	rl.DrawSphere(player.translation, 0.5, rl.PINK)
	forward_point := player.translation + (player.forward * 2)
	delta_point := player.translation + (player.move_delta * 2)
	rl.DrawLine3D(player.translation, forward_point, rl.RED)
	rl.DrawLine3D(player.translation, delta_point, rl.GREEN)
}
