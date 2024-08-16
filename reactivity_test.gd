extends Control

var fields: Array:
	set(value):
		print("fields changed: value=", value)


func _ready():
	var state = Reactivity.state({"key": 1})
	state.subscribe("key", _on_key_changed)
	state.subscribe("ui.form.inputs.name", _on_name_changed)

	state.bind("forms.fields", self, "fields")

	state.set_value("key", 42)
	print_debug(state.get_value("key"))
	state.set_value("ui.form.inputs.name", "Fred")
	print_debug(state.get_value("ui.form.inputs.name"))
	
	state.set_value("forms.fields[10].value", "Toto")
	state.subscribe("forms.fields", _on_form_changed)
	print("deep value with array 7=", state.get_value("forms.fields[7].value"))
	print("deep value with array 10=", state.get_value("forms.fields[10].value"))
	state.set_value("forms.fields[7].value", "Nike")

	state.subscribe("forms.fields", _on_form_changed)
	state.set_value("forms.fields[10].value", "Titi")


	var comp = Reactivity.computed(func(): return "The key is %s" % state.get_value("key"))
	print(comp.value)


func _on_key_changed(value: Variant):
	prints("Key changed=", value)


func _on_name_changed(value: Variant):
	prints("Name changed=", value)


func _on_form_changed(value: Variant):
	print("Form changed=", value)
