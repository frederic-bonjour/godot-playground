extends Node
class_name Reactivity


class State:
	signal state_changed_at(state: Dictionary, path: String)

	var _state: Dictionary
	var _subscriptions: Dictionary


	func _init(initial_state: Dictionary):
		_state = initial_state.duplicate()


	func _get_create_prop(base: Dictionary, prop: String, intermediate: bool) -> Variant:
		var obp = prop.find("[", 1)
		if obp > 0:
			obp += 1
			var cbp = prop.find("]", obp + 1)
			if cbp > obp:
				var idx = int(prop.substr(obp, cbp - obp))
				prop = prop.substr(0, obp - 1)
				if not base.has(prop):
					base[prop] = []
				while idx >= base[prop].size():
					base[prop].append({} if intermediate else null)
				return base[prop][idx]
		
		if not base.has(prop):
			base[prop] = {} if intermediate else null
		return base[prop]


	func set_value(path: String, value: Variant) -> void:
		var d = _state
		var parts = Array(path.split("."))
		var prop = parts.pop_back()
		for p in parts:
			d = _get_create_prop(d, p, true)

		if not d.has(prop) or d[prop] != value:
			d[prop] = value
			state_changed_at.emit(_state, path)
			for sub_path in _subscriptions.keys():
				if path.begins_with(sub_path):
					var v = get_value(sub_path)
					for sub in _subscriptions[sub_path]:
						sub.call(v)


	func get_value(path: String) -> Variant:
		var d = _state
		var parts = Array(path.split("."))
		var prop = parts.pop_back()
		for p in parts:
			d = _get_create_prop(d, p, true)
		return _get_create_prop(d, prop, false)


	func subscribe(path: String, callback: Callable) -> void:
		if not _subscriptions.has(path):
			_subscriptions[path] = []
		_subscriptions[path].append(callback)


	func bind(path: String, obj: Node, property_name: String):
		subscribe(path, func(value):
			obj[property_name] = value
		)


class ComputedProperty:
	var _compute_func
	
	var value:
		get: return _compute_func.call()

	func _init(callback: Callable):
		_compute_func = callback


static func computed(callback: Callable) -> ComputedProperty:
	return ComputedProperty.new(callback)


static func state(initial_state: Dictionary) -> State:
	return State.new(initial_state)
