package main

import rl "vendor:raylib"

PHYSICAL_WIDTH :: 1920
PHYSICAL_HEIGHT :: 1080
VIEW_WIDTH :: 640
VIEW_HEIGT :: 360

render :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLUE)
	render_gameplay_scene()
	debug_ui()
	rl.EndDrawing()
}

render_gameplay_scene :: proc() {
	rl.BeginMode3D(world.camera.raw)
	rl.DrawModel(assets.gym, {0, 0, 0}, 1, rl.ORANGE)
	draw_player()
	rl.EndMode3D()
}
