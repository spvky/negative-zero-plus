package main

import "core:log"
import l "core:math/linalg"
import rl "vendor:raylib"

FRAME_LENGTH: f32 : 1.0 / 60.0

// Transitions

animations: [Player_Animation]Animation_Meta

Player_Animation :: enum {
	Idle,
	Rise,
	Run,
}

Animation_Meta :: struct {
	index:        int,
	frame_length: f32,
	next:         Player_Animation,
}

// update_animation_blend :: proc(
// 	model: rl.Model,
// 	anim_a: rl.ModelAnimation,
// 	frame_a: f32,
// 	anim_b: rl.ModelAnimation,
// 	frame_b: f32,
// 	blend: f32,
// ) {
// 	// Check Bone matrices
//
// 	if anim_a.frameCount > 0 &&
// 	   anim_a.framePoses != nil &&
// 	   anim_b.frameCount > 0 &&
// 	   anim_b.framePoses != nill &&
// 	   blend >= 0 &&
// 	   blend <= 1 {
//
// 		current_frame_a := int(frame_a % anim_a.frameCount)
// 		next_frame_a := current_frame_a + 1
// 		blend_a := frame_a - f32(current_frame_a)
// 		//Wrap frame a
// 		if current_frame_a > anim_a.frameCount do current_frame_a = current_frame_a % anim_a.frameCount
// 		if next_frame_a > anim_a.frameCount do next_frame_a = next_frame_a % anim_a.frameCount
//
//
// 		current_frame_b := int(frame_b % anim_b.frameCount)
// 		next_frame_b := current_frame_b + 1
// 		blend_b := frame_b - f32(current_frame_b)
// 		//Wrap frame b
// 		if current_frame_b > anim_b.frameCount do current_frame_b = current_frame_b % anim_b.frameCount
// 		if next_frame_b > anim_b.frameCount do next_frame_b = next_frame_b % anim_b.frameCount
//
// 		bind_pose_matrix: rl.Matrix
// 		current_pose_matrix: rl.Matrix
//
// 		for i in 0 ..< model.meshes[0].boneCount {
// 			frame_a_translation := l.lerp(
// 				anim_a.framePoses[current_frame_a][i].translation,
// 				anim_a.framePoses[next_frame_a][i].translation,
// 				blend_a,
// 			)
//
// 			frame_a_rotation := l.quaternion_slerp(
// 				anim_a.framePoses[current_frame_a][i].rotation,
// 				anim_a.framePoses[next_frame_a][i].rotation,
// 				blend_a,
// 			)
//
// 			frame_a_scale := l.lerp(
// 				anim_a.framePoses[current_frame_a][i].scale,
// 				anim_a.framePoses[next_frame_a][i].scale,
// 				blend_a,
// 			)
//
// 		}
//
// 	}
// }

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
		player.animation_index = 1
	case .Running:
		player.animation_index = 3
	case .Rising:
		player.animation_index = 2
	case .Falling:
		player.animation_index = 0
	case .DJ_Rising:
		player.animation_index = 2
	case .DJ_Falling:
		player.animation_index = 0
	case .TJ_Rising:
		player.animation_index = 2
	case .TJ_Falling:
		player.animation_index = 0
	case .Diving:
	case .Sliding:
	}
}
