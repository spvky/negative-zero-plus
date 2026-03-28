package main

import "core:fmt"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

debug_ui :: proc() {
	rl.DrawFPS(10, 10)
	player_debug_text()
}

player_debug_text :: proc() {
	player := world.player
	player_string := fmt.tprintf(
		"Player:\n\tAngle To Delta: %2.f\n\tTranslation:[%.2f,%.2f,%.2f]\n\tVelocity:[%.2f,%.2f,%.2f]\n\tForward:[%.2f,%.2f,%.2f]\n\tRight:[%.2f,%.2f,%.2f]",
		math.to_degrees(player.angle_to_delta),
		player.translation.x,
		player.translation.y,
		player.translation.z,
		player.velocity.x,
		player.velocity.y,
		player.velocity.z,
		player.forward.x,
		player.forward.y,
		player.forward.z,
		player.right.x,
		player.right.y,
		player.right.z,
	)

	rl.DrawText(
		strings.clone_to_cstring(player_string, allocator = context.temp_allocator),
		10,
		30,
		16,
		rl.BLACK,
	)
}
