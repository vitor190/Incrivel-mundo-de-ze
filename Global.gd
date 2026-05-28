extends Node

signal dressed_changed(value: bool)

var is_dressed: bool = false

var fome: float = 100.0
var xp: int = 0

var posicoes := {}

func set_dressed(value: bool) -> void:
	is_dressed = value
	dressed_changed.emit(value)


func salvar_estado(cena: String, posicao: Vector2, fome_atual: float, xp_atual: int = 0) -> void:
	fome = fome_atual
	xp = xp_atual
	posicoes[cena] = posicao


func pegar_posicao(cena: String) -> Vector2:
	if posicoes.has(cena):
		return posicoes[cena]

	return Vector2.ZERO
