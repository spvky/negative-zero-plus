package main

import rl "vendor:raylib"

//#GLOBAL
assets: Assets

Assets :: struct {
	gameplay_texture: rl.RenderTexture,
	gym:              rl.Model,
}

init_assets :: proc() {
	assets.gameplay_texture = rl.LoadRenderTexture(PHYSICAL_WIDTH, PHYSICAL_HEIGHT)
	assets.gym = rl.LoadModel("assets/gym.glb")
}

delete_assets :: proc() {
	rl.UnloadRenderTexture(assets.gameplay_texture)
}
