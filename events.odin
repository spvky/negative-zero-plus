package main

import "core:container/queue"
import "core:log"
import "core:reflect"

Event_System :: struct {
	event_queue:     queue.Queue(Event),
	event_listeners: map[Event_Type][dynamic]Event_Callback,
}

Event :: struct {
	type:    Event_Type,
	payload: Event_Payload,
}

Event_Type :: enum {
	Player_Collision,
}

Event_Payload :: union {
	EP_Player_Collision,
}

EP_Player_Collision :: struct {
	collision: Collision,
}

Event_Callback :: proc(event: Event)

// Create an event system with the given initial queue capacity and event listener capacity
make_event_system :: proc(queue_capacity: int) -> (event_system: Event_System) {
	queue.reserve(&event_system.event_queue, queue_capacity)
	event_types := reflect.enum_field_names(Event_Type)
	event_system.event_listeners = make(map[Event_Type][dynamic]Event_Callback, len(event_types))
	return
}

delete_event_system :: proc(event_system: ^Event_System) {
	for v in Event_Type {
		delete(event_system.event_listeners[v])
	}
	delete(event_system.event_listeners)
	queue.destroy(&event_system.event_queue)
}

//GLOBAL CONTEXT
publish_event :: proc(type: Event_Type, payload: Event_Payload) {
	queue.enqueue(&world.event_system.event_queue, Event{type = type, payload = payload})
}

subscribe_event :: proc(type: Event_Type, callback: Event_Callback) {
	if type not_in world.event_system.event_listeners {
		// Allocate enough space for 2 callbacks
		world.event_system.event_listeners[type] = make([dynamic]Event_Callback, 0, 2)
	}
	append(&world.event_system.event_listeners[type], callback)
}


process_events :: proc() {
	for queue.len(world.event_system.event_queue) > 0 {
		event := queue.dequeue(&world.event_system.event_queue)
		log.debugf("Popped Event Off the Queue: %v", event)
		if listeners, ok := world.event_system.event_listeners[event.type]; ok {
			for callback in listeners {
				callback(event)
			}
		}
	}
}
