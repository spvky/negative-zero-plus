package main

Player_State :: enum {
	Idle,
	Rising,
	Falling,
	DJ_Rising,
	DJ_Falling,
	TJ_Rising,
	TJ_Falling,
	Running,
	Skidding,
}

manage_player_state :: proc(player: ^Player) {
	player.prev_state = player.state
	switch player.state {
	case .Idle:
	case .Rising:
	case .Falling:
	case .DJ_Rising:
	case .DJ_Falling:
	case .TJ_Rising:
	case .TJ_Falling:
	case .Running:
	case .Skidding:
	}

}
