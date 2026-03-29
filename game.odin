package main

import rl "vendor:raylib"

init :: proc() {
	rl.InitWindow(PHYSICAL_WIDTH, PHYSICAL_HEIGHT, "Negataive 0+")
	init_assets()
	init_world()
}

should_close :: proc() -> bool {
	return rl.WindowShouldClose()
}

update :: proc() {
	gameplay_loop()
	render()
	free_all(context.temp_allocator)
}

exit :: proc() {
	delete_assets()
	rl.CloseWindow()
}

gameplay_loop :: proc() {
	update_camera_position()
	update_player()
	process_events()
}
