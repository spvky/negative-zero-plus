package main

import rl "vendor:raylib"

//#GLOBAL
assets: Assets

Assets :: struct {
	gameplay_texture:       rl.RenderTexture,
	player:                 rl.Model,
	player_animations:      [^]rl.ModelAnimation,
	player_animation_count: i32,
	gym:                    rl.Model,
	flat_quad:              rl.Model,
	shadow_texture:         rl.Texture2D,
}

init_assets :: proc() {
	assets.gameplay_texture = rl.LoadRenderTexture(PHYSICAL_WIDTH, PHYSICAL_HEIGHT)
	assets.player = rl.LoadModel("assets/janitor.glb")
	assets.player_animations = rl.LoadModelAnimations(
		"assets/janitor.glb",
		&assets.player_animation_count,
	)
	assets.gym = rl.LoadModel("assets/gym.glb")
	assets.flat_quad = rl.LoadModelFromMesh(rl.GenMeshPlane(1, 1, 1, 1))
	assets.shadow_texture = rl.LoadTexture("assets/shadow.png")
	assets.flat_quad.materials[0].maps[0].texture = assets.shadow_texture
}

delete_assets :: proc() {
	rl.UnloadRenderTexture(assets.gameplay_texture)
	rl.UnloadModel(assets.gym)
	rl.UnloadModel(assets.flat_quad)
	rl.UnloadTexture(assets.shadow_texture)
}
