package main

import "core:math"
import l "core:math/linalg"

Vec3 :: [3]f32
// Vec Constants
VEC0: Vec3 : {0, 0, 0}
VEC1: Vec3 : {1, 1, 1}
VECX: Vec3 : {1, 0, 0}
VECY: Vec3 : {0, 1, 0}
VECZ: Vec3 : {0, 0, 1}

angle_from_vec :: proc(v: Vec3) -> f32 {
	return math.atan2(v.z, v.x)
}

signed_angle_between :: proc(a, b: Vec3) -> f32 {
	return math.atan2(a.x * b.z - a.z * b.x, l.dot(a, b))
}
