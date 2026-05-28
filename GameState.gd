extends Node

signal dressed_changed(value: bool)

var is_dressed: bool = false

var fome_atual: float = 100.0
var xp_atual: int = 0

var posicoes_cenas := {}

func set_dressed(value: bool) -> void:
	is_dressed = value
	dressed_changed.emit(value)

func salvar_player(scene_path: String, posicao: Vector2, fome: float) -> void:
	fome_atual = fome
	posicoes_cenas[scene_path] = posicao

func carregar_posicao(scene_path: String) -> Vector2:
	if posicoes_cenas.has(scene_path):
		return posicoes_cenas[scene_path]

	return Vector2.ZERO
