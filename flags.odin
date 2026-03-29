package main

Player_Flag :: enum {
	Grounded,
	DoubleJump,
	TrippleJump,
}

add_player_flag :: proc(flag: Player_Flag) {
	world.player.flags += {flag}
}

remove_player_flag :: proc(flag: Player_Flag) {
	world.player.flags -= {flag}
}
