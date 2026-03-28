package main

import "core:log"

//#GLOBAL
world: World

World :: struct {
	player:          Player,
	camera:          Camera,
	level_collision: [dynamic]Mesh_Collision_Data,
}

init_world :: proc() {
	world.player = make_player({0, 1, 0})
	world.camera = make_camera()
	world.level_collision = parse_collision_data(&assets.gym)
	log.infof("Generated collision for %v meshes", len(world.level_collision))
}
