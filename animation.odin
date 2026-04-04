package main

import rl "vendor:raylib"

// Need to advance an animation timer by delta, and once it passes framelength, reset to 0 and update the animation frame

update_player_animations :: proc() {
	player := &world.player
	animation := assets.player_animations[player.animation_index]
	player.animation_frame
	rl.UpdateModelAnimation(assets.player, animation, player.animation_frame)
}
