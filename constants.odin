package main

import "core:math"

// How far can the player jump horizontally (in pixels)
JUMP_DISTANCE: f32 : 6
// How long to reach jump peak (in seconds)
TIME_TO_PEAK: f32 : 0.3
// How long to reach height we jumped from (in seconds)
TIME_TO_DESCENT: f32 : 0.28
// How many pixels high is a full jump
JUMP_HEIGHT: f32 : 3.5

run_speed := calculate_ground_speed()
jump_speed := calulate_jump_speed()
rising_gravity := calculate_rising_gravity()
falling_gravity := calculate_falling_gravity()

// Jumping
calulate_jump_speed :: proc "c" () -> f32 {
	return (-2 * JUMP_HEIGHT) / TIME_TO_PEAK
}

calculate_rising_gravity :: proc "c" () -> f32 {
	return (2 * JUMP_HEIGHT) / math.pow(TIME_TO_PEAK, 2)
}

calculate_falling_gravity :: proc "c" () -> f32 {
	return (2 * JUMP_HEIGHT) / math.pow(TIME_TO_DESCENT, 2)
}
// Lateral Movement
calculate_ground_speed :: proc "c" () -> f32 {
	return JUMP_DISTANCE / (TIME_TO_PEAK + TIME_TO_DESCENT)
}
