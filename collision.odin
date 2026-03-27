package main

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
