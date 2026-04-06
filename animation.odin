package main

import "core:log"
import rl "vendor:raylib"

FRAME_LENGTH: f32 : 1.0 / 60.0

// Need to advance an animation timer by delta, and once it passes framelength, reset to 0 and update the animation frame

Animation_Meta :: struct {
	index:        int,
	frame_length: f32,
}

update_player_animations :: proc(player: ^Player, delta: f32) {
	animation := assets.player_animations[player.animation_index]
	player.animation_timer += delta

	set_player_anim_index(player)
	if player.animation_timer > FRAME_LENGTH / 1.5 {
		player.animation_timer = 0
		new_index := player.animation_frame + 1
		if new_index > animation.frameCount {
			new_index = 0
		}
		player.animation_frame = new_index
	}
	rl.UpdateModelAnimation(assets.player, animation, i32(player.animation_frame))
}

set_player_anim_index :: proc(player: ^Player) {
	switch player.state {
	case .Idle:
		player.animation_index = 0
	case .Running:
		player.animation_index = 1
	case .Rising:
	case .Falling:
	case .DJ_Rising:
	case .DJ_Falling:
	case .TJ_Rising:
	case .TJ_Falling:
	case .Diving:
	case .Sliding:
	}
}
