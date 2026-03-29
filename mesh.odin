package main

import "core:math"
import l "core:math/linalg"
import "core:slice"
import rl "vendor:raylib"

Mesh_Collision_Data :: struct {
	mesh_idx:       int,
	vertices:       [dynamic]Vec3,
	axes:           [dynamic]Vec3,
	axis_intervals: [dynamic]Interval,
	center:         Vec3,
}

parse_collision_data :: proc(
	model: ^rl.Model,
	allocator := context.allocator,
) -> (
	collision_data: [dynamic]Mesh_Collision_Data,
) {
	project_vertices_onto_axis :: #force_inline proc(
		axis: Vec3,
		vertices: []Vec3,
	) -> (
		interval: Interval,
	) {
		interval.min = math.F32_MAX
		interval.max = -math.F32_MAX
		for v in vertices {
			dot := l.dot(v, axis)
			if dot < interval.min {
				interval.min = dot
			}
			if dot > interval.max {
				interval.max = dot
			}
		}
		return
	}

	collision_data = make([dynamic]Mesh_Collision_Data, 0, model.meshCount, allocator = allocator)
	model_loop: for i in 0 ..< model.meshCount {
		m := model.meshes[i]

		// Extract Vertices +++++++++++++++++++++++
		vertices_slice := (cast([^]Vec3)m.vertices)[:m.vertexCount]
		vertices := slice.clone_to_dynamic(vertices_slice, allocator = allocator)
		//-----------------------------------------

		// Extract Center +++++++++++++++++++++++++
		center: Vec3
		for v in vertices {
			center += v
		}
		center /= f32(len(vertices))
		// ----------------------------------------

		// Extract Axes +++++++++++++++++++++++++++
		mesh_axes := make([dynamic]Vec3, 0, m.triangleCount, allocator = allocator)
		triangle_slice := (cast([^][3]i16)m.indices)[:m.triangleCount]
		axis_loop: for idx, i in triangle_slice {
			a_ptr: rawptr = &vertices_slice[idx[0]]
			b_ptr: rawptr = &vertices_slice[idx[1]]
			c_ptr: rawptr = &vertices_slice[idx[2]]

			a: Vec3 = (cast(^Vec3)a_ptr)^
			b: Vec3 = (cast(^Vec3)b_ptr)^
			c: Vec3 = (cast(^Vec3)c_ptr)^

			// Normalize and Prune normals
			axis := l.normalize0(l.cross(b - a, c - a))
			for i in 0 ..< 3 {
				if math.abs(axis[i]) < 0.001 {
					axis[i] = 0
				} else {
					axis[i] = math.trunc(axis[i] * 100) / 100
				}
			}
			for a in mesh_axes {
				if a == axis {
					continue axis_loop
				}
			}
			append(&mesh_axes, axis)
		}
		shrink(&mesh_axes)
		// --------------------------------------

		// Extract Intervals ++++++++++++++++++++
		axis_intervals := make([dynamic]Interval, 0, len(mesh_axes))
		for a in mesh_axes {
			append(&axis_intervals, project_vertices_onto_axis(a, vertices[:]))
		}
		// --------------------------------------

		mesh_data := Mesh_Collision_Data {
			mesh_idx       = int(i),
			vertices       = vertices,
			axes           = mesh_axes,
			axis_intervals = axis_intervals,
			center         = center,
		}
		append(&collision_data, mesh_data)
	}
	return
}
