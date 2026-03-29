package main

import "core:log"

//#GLOBAL
world: World

World :: struct {
	player:          Player,
	camera:          Camera,
	level_collision: [dynamic]Mesh_Collision_Data,
	event_system:    Event_System,
}

init_world :: proc() {
	world.player = make_player({0, 1, 0})
	world.camera = make_camera()
	world.level_collision = parse_collision_data(&assets.gym)
	world.event_system = make_event_system(16)
	log.infof("Generated collision for %v meshes", len(world.level_collision))
	// for m in world.level_collision {
	// 	log.infof("Collision Data: %v", m)
	// }
}
