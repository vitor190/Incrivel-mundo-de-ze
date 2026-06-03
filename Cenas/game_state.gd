extends Node

signal xp_changed(value: float)
signal dressed_changed(value: bool)

const MAX_XP: float = 100.0


var xp: float:
	get:
		return Global.xp
	set(value):
		Global.set_xp(value)


var is_dressed: bool:
	get:
		return Global.is_dressed
	set(value):
		Global.set_dressed(value)


func _ready() -> void:
	if not Global.xp_changed.is_connected(_on_global_xp_changed):
		Global.xp_changed.connect(_on_global_xp_changed)

	if not Global.dressed_changed.is_connected(_on_global_dressed_changed):
		Global.dressed_changed.connect(_on_global_dressed_changed)


func _on_global_xp_changed(value: float) -> void:
	xp_changed.emit(value)


func _on_global_dressed_changed(value: bool) -> void:
	dressed_changed.emit(value)


func set_xp(value: float) -> void:
	Global.set_xp(value)


func add_xp(amount: float) -> void:
	Global.add_xp(amount)


func lose_xp(amount: float) -> void:
	Global.lose_xp(amount)


func set_dressed(value: bool) -> void:
	Global.set_dressed(value)


func reset() -> void:
	Global.set_xp(0.0)
	Global.set_dressed(false)
