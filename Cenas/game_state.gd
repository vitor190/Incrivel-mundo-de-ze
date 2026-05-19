extends Node

const MAX_XP: float = 100.0

var xp: float = 35.0
# Padrão "já vestido" para que cenas sem minigame (ex.: campus) mostrem o Zé
# completo. Quarto explicitamente seta false em _ready.
var is_dressed: bool = true

signal xp_changed(value: float)
signal dressed_changed(value: bool)

func lose_xp(amount: float) -> void:
	xp = max(0.0, xp - amount)
	xp_changed.emit(xp)

func set_dressed(value: bool) -> void:
	if is_dressed == value:
		return
	is_dressed = value
	dressed_changed.emit(value)

func reset() -> void:
	xp = 35.0
	xp_changed.emit(xp)
	is_dressed = true
	dressed_changed.emit(true)
