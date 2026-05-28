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
	dressed_changed.emit(value)

func add_xp(amount: float) -> void:
	xp = clamp(xp + amount, 0.0, MAX_XP)
	xp_changed.emit(xp)

func lose_xp(amount: float) -> void:
	xp = clamp(xp - amount, 0.0, MAX_XP)
	xp_changed.emit(xp)

func salvar_estado(cena: String, posicao: Vector2, fome_atual: float, xp_atual: float = -1.0) -> void:
	fome = fome_atual

	if xp_atual >= 0.0:
		xp = clamp(xp_atual, 0.0, MAX_XP)
		xp_changed.emit(xp)

	posicoes[cena] = posicao

func pegar_posicao(cena: String) -> Vector2:
	if posicoes.has(cena):
		return posicoes[cena]

	return Vector2.ZERO
