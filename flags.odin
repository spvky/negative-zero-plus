package main

Player_Flag :: enum {
	Grounded,
	Double_Jump,
	Tripple_Jump,
	Diving,
	Jump_Propulsion,
	Run_Startup,
}

// Adds a flag to the player, by default flag will have a duration of 0.05 (about 3 frames at 60fps)
add_player_flag :: proc(flag: Player_Flag, duration: f32 = 0.05) {
	world.player.flags += {flag}
	world.player.flag_timers[flag] = duration
}

remove_player_flag :: proc(flag: Player_Flag) {
	world.player.flags -= {flag}
	world.player.flag_timers[flag] = 0
}
