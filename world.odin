package main

import "core:log"

//#GLOBAL
world: World

World :: struct {
	camera:          Camera,
	level_collision: [dynamic]Mesh_Collision_Attr,
}

init_world :: proc() {
	world.camera = make_camera()
	world.level_collision = parse_collision_data(&assets.gym)
	log.infof("Generated collision for %v meshes", len(world.level_collision))

}
