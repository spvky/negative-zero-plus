package main

import "core:math"
import l "core:math/linalg"

Sphere :: struct {
	center: Vec3,
	radius: f32,
}

Collision :: struct {
	normal: Vec3,
	depth:  f32,
}

Interval :: struct {
	min: f32,
	max: f32,
}

interval_overlap :: proc(a, b: Interval) -> (overlaps: bool, amount: f32) {
	overlaps = a.min <= b.max && b.min <= a.max
	if !overlaps {
		return
	}
	amount = min(a.max, b.max) - max(a.min, b.min)
	return
}


project_sphere_vertices :: proc(s: Sphere, d: Vec3) -> (interval: Interval) {
	interval.min = l.dot(s.center + (-d * s.radius), d)
	interval.max = l.dot(s.center + (d * s.radius), d)
	return
}

sphere_level_collision_test :: proc(
	s: Sphere,
	m: Mesh_Collision_Data,
) -> (
	is_colliding: bool,
	collision: Collision,
) {
	collision.depth = f32(math.F32_MAX)
	direction_to_mesh := l.normalize0(m.center - s.center)

	for i in 0 ..< len(m.axes) {
		mesh_range := m.axis_intervals[i]
		axis := m.axes[i]

		sphere_range := project_sphere_vertices(s, axis)
		overlap, amount := interval_overlap(mesh_range, sphere_range)
		if !overlap {
			return
		}
		if amount < collision.depth && l.dot(direction_to_mesh, axis) < 0 {
			collision.depth = amount
			collision.normal = axis
		}
	}
	is_colliding = true
	return
}
