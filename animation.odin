package main

import rl "vendor:raylib"

// Need to advance an animation timer by delta, and once it passes framelength, reset to 0 and update the animation frame

update_player_animations :: proc() {
	player := &world.player
	animation := assets.player_animations[player.animation_index]
	rl.UpdateModelAnimation(assets.player, animation, i32(player.animation_frame))
}
