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
		"Player:\n\tCurrent Speed: %2.f\n\tRotation: %.2f\n\tCamera Rotation: %.2f\n\tCamera Target Rotation: %.2f\n\tAngle To Delta: %.2f\n\tTranslation:[%.2f,%.2f,%.2f]\n\tVelocity:[%.2f,%.2f,%.2f]\n\tForward:[%.2f,%.2f,%.2f]\n\tRight:[%.2f,%.2f,%.2f]\n\tState: %v\n\tFlags: %v\n\tSlope: %.2f\n\tFrame: %v",
		player.current_speed,
		player.rotation,
		world.camera.angle,
		world.camera.target_angle,
		player.angle_to_delta,
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
		player.state,
		player.flags,
		player.slope,
		player.animation_frame,
	)

	rl.DrawText(
		strings.clone_to_cstring(player_string, allocator = context.temp_allocator),
		10,
		30,
		20,
		rl.BLACK,
	)
}
