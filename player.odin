package main

import "core:math"
import l "core:math/linalg"
import rl "vendor:raylib"

Player :: struct {
	translation: Vec3,
	velocity:    Vec3,
	move_delta:  Vec3,
	rotation:    f32,
	forward:     Vec3,
	right:       Vec3,
}

make_player :: proc(translation: Vec3) -> (player: Player) {
	player.translation = translation
	return
}

update_player :: proc() {
	player := &world.player
	// Nested procs here don't need to be called anywhere else but i don't want to polute the scope for the LSP
	update_player_orientation :: proc(player: ^Player) {
		player.forward = {math.sin(player.rotation), 0, math.cos(player.rotation)}
		player.right = -l.cross(player.forward, Vec3{0, 1, 0})
	}

	update_player_orientation(player)
	set_player_move_delta()
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


draw_player :: proc() {
	player := &world.player
	rl.DrawSphere(player.translation, 1, rl.PINK)
	forward_point := player.translation + (player.forward * 2)
	delta_point := player.translation + (player.move_delta * 2)
	rl.DrawLine3D(player.translation, forward_point, rl.RED)
	rl.DrawLine3D(player.translation, delta_point, rl.GREEN)
}
