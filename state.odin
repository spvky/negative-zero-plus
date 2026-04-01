package main

Player_State :: enum {
	Idle,
	Running,
	Rising,
	Falling,
	DJ_Rising,
	DJ_Falling,
	TJ_Rising,
	TJ_Falling,
	Diving,
}

GROUNDED_STATE_SET: bit_set[Player_State] : {.Idle, .Running}

AIRBORNE_STATE_SET: bit_set[Player_State] : {
	.Rising,
	.Falling,
	.DJ_Rising,
	.DJ_Falling,
	.TJ_Rising,
	.TJ_Falling,
	.Diving,
}

TRIPPLE_JUMP_SET: bit_set[Player_State] : {.TJ_Rising, .TJ_Falling}
DOUBLE_JUMP_SET: bit_set[Player_State] : {.DJ_Rising, .DJ_Falling}

manage_player_state :: proc(player: ^Player) {
	player.prev_state = player.state
	state: Player_State = player.state
	switch player.state {
	case .Idle:
		if player.move_delta != VEC0 {
			state = .Running
		}
		transition_to_airborne(player, &state)
	case .Running:
		if player.move_delta == VEC0 {
			state = .Idle
		}
		transition_to_airborne(player, &state)
	case .Rising:
		if player.velocity.y <= 0 {
			state = .Falling
		}
		transition_to_grounded(player, &state)
	case .Falling:
		if player.velocity.y > 0 {
			state = .Rising
		}
		transition_to_grounded(player, &state)
	case .DJ_Rising:
		if player.velocity.y <= 0 {
			state = .DJ_Falling
		}
		transition_to_grounded(player, &state)
	case .DJ_Falling:
		if player.velocity.y > 0 {
			state = .DJ_Rising
		}
		transition_to_grounded(player, &state)
	case .TJ_Rising:
		if player.velocity.y <= 0 {
			state = .TJ_Falling
		}
		transition_to_grounded(player, &state)
	case .TJ_Falling:
		if player.velocity.y > 0 {
			state = .TJ_Rising
		}
		transition_to_grounded(player, &state)
	case .Diving:
		transition_to_grounded(player, &state)
	}
	player.state = state
}

handle_player_state_transitions :: proc(player: ^Player) {
	if player.prev_state in AIRBORNE_STATE_SET && player.state in GROUNDED_STATE_SET {
		if player.prev_state in TRIPPLE_JUMP_SET {
			// Nuthin yet
		} else if player.prev_state in DOUBLE_JUMP_SET {
			add_player_flag(.Tripple_Jump, 0.2)
		} else {
			add_player_flag(.Double_Jump, 0.2)
		}
	}

	if player.prev_state == .Idle && player.state == .Running {
		add_player_flag(.Run_Startup, 1)
	}
}

transition_to_airborne :: #force_inline proc(player: ^Player, state: ^Player_State) {
	if .Grounded not_in player.flags {
		if player.velocity.y > 0 {
			if .Tripple_Jump in player.flags {
				state^ = .TJ_Rising
			} else if .Double_Jump in player.flags {
				state^ = .DJ_Rising
			} else {
				state^ = .Rising
			}
		} else {
			if .Tripple_Jump in player.flags {
				state^ = .TJ_Falling
			} else if .Double_Jump in player.flags {
				state^ = .DJ_Falling
			} else {
				state^ = .Falling
			}
		}
	}
}

transition_to_grounded :: #force_inline proc(player: ^Player, state: ^Player_State) {
	if .Grounded in player.flags {
		if player.move_delta == VEC0 {
			state^ = .Idle
		} else {
			state^ = .Running
		}
	}
}
