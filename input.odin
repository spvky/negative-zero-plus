package main

import l "core:math/linalg"
import rl "vendor:raylib"

GAMEPAS_AXIS_DEADZONE: f32 : 0.2
BUFFER_WINDOW: f32 : 0.1

input_buffer: Input_Buffer

Input_Buffer :: struct {
	buffered: [Input_Action]Buffered_Input,
	held:     bit_set[Input_Action;u8],
}

Buffered_Input :: union {
	f32,
}

Input_Action :: enum {
	Jump,
}

check_pads_down :: proc(count: i32, button: rl.GamepadButton) -> bool {
	for i in 0 ..< count {
		if rl.IsGamepadButtonDown(i, button) {
			return true
		}
	}
	return false
}
check_pads_pressed :: proc(count: i32, button: rl.GamepadButton) -> bool {
	for i in 0 ..< count {
		if rl.IsGamepadButtonPressed(i, button) {
			return true
		}
	}
	return false
}
check_pads_released :: proc(count: i32, button: rl.GamepadButton) -> bool {
	for i in 0 ..< count {
		if rl.IsGamepadButtonReleased(i, button) {
			return true
		}
	}
	return false
}
check_pads_axis :: proc(count: i32, axis: rl.GamepadAxis) -> (value: f32) {
	for i in 0 ..< count {
		value = rl.GetGamepadAxisMovement(i, axis)
		if value != 0 do return
	}
	return
}

update_buffer :: proc() {
	frametime := rl.GetFrameTime()

	for &buffered in input_buffer.buffered {
		switch &v in buffered {
		case f32:
			v -= frametime
			if v <= 0 {
				buffered = nil
			}
		}
	}
}

buffer_action :: proc(action: Input_Action) {
	switch &v in input_buffer.buffered[action] {
	case f32:
		v = BUFFER_WINDOW
	case:
		input_buffer.buffered[action] = BUFFER_WINDOW
	}
	input_buffer.held += {action}
}

release_action :: proc(action: Input_Action) {
	input_buffer.held -= {action}
}

consume_action :: proc(action: Input_Action) {
	input_buffer.buffered[action] = nil
}

is_action_buffered :: proc(action: Input_Action) -> bool {
	_, action_pressed := input_buffer.buffered[action].(f32)
	return action_pressed
}

is_action_held :: proc(action: Input_Action) -> bool {
	return action in input_buffer.held
}

poll_input :: proc(player: ^Player) {
	raw_delta: Vec3

	if rl.IsKeyDown(.W) || check_pads_axis(3, .LEFT_Y) < -GAMEPAS_AXIS_DEADZONE {
		raw_delta.z += 1
	}
	if rl.IsKeyDown(.S) || check_pads_axis(3, .LEFT_Y) > GAMEPAS_AXIS_DEADZONE {
		raw_delta.z -= 1
	}
	if rl.IsKeyDown(.D) || check_pads_axis(3, .LEFT_X) > GAMEPAS_AXIS_DEADZONE {
		raw_delta.x += 1
	}
	if rl.IsKeyDown(.A) || check_pads_axis(3, .LEFT_X) < -GAMEPAS_AXIS_DEADZONE {
		raw_delta.x -= 1
	}
	player.move_delta = interpolate_vector(l.normalize0(raw_delta))

	update_buffer()
	// Buffer pressed inputs
	if rl.IsKeyPressed(.SPACE) || check_pads_pressed(3, .RIGHT_FACE_DOWN) do buffer_action(.Jump)
	if rl.IsKeyReleased(.SPACE) || check_pads_released(3, .RIGHT_FACE_DOWN) do release_action(.Jump)
}
