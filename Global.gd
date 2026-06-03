extends Node

signal dressed_changed(value: bool)
signal xp_changed(value: float)

const MAX_XP: float = 100.0

var is_dressed: bool = false
var fome: float = 100.0
var xp: float = 0.0

var posicoes := {}


func set_dressed(value: bool) -> void:
	is_dressed = value
	dressed_changed.emit(is_dressed)


func set_xp(value: float) -> void:
	xp = clamp(value, 0.0, MAX_XP)
	xp_changed.emit(xp)


func add_xp(amount: float) -> void:
	set_xp(xp + amount)


func lose_xp(amount: float) -> void:
	set_xp(xp - amount)


func salvar_estado(cena: String, posicao: Vector2, fome_atual: float) -> void:
	fome = fome_atual
	posicoes[cena] = posicao


func pegar_posicao(cena: String) -> Vector2:
	if posicoes.has(cena):
		return posicoes[cena]

	return Vector2.ZERO
