package main

import "core:math"
import l "core:math/linalg"

Vec3 :: [3]f32
VEC0: Vec3 : {0, 0, 0}

signed_angle_between :: proc(a, b: Vec3) -> f32 {
	return math.atan2(a.x * b.z - a.z * b.x, l.dot(a, b))
}
