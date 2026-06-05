## quarto_noite.gd — versão noturna do quarto.
## Ao chegar na cama, dispara a tarefa de dormir (contar carneirinhos).
## Reaproveita a base do quarto (HUD, XP, painel de missões, transição).
extends Node2D

const MINIGAME_DORMIR: PackedScene = preload("res://Cenas/minigame_carneirinhos.tscn")
const CENA_FINAL := "res://Cenas/cena_final.tscn"

const MISSAO_ID := "quarto_dormir"
const SUB_ID := "quarto_dormir_mini1"

var minigame_aberto := false
var minigame_inst: Node = null
var dormiu := false
var _indicator_tween: Tween

@onready var player: CharacterBody2D = $player
@onready var cama_area: Area2D = $CamaArea
@onready var cama_indicator: Label = $CamaIndicator


func _ready() -> void:
	GerenciadorMissoes.set_cena("quarto_noite")

	# O Zé chega em casa vestido, à noite, com movimento liberado.
	GameState.set_dressed(true)
	_set_player_movement(true)

	# À noite não há ônibus nem troca de roupa.
	_desativar_area("PortaVolta")
	_desativar_area("WardrobeInteractArea")
	var guarda_ind := get_node_or_null("WardrobeIndicator")
	if guarda_ind:
		guarda_ind.visible = false

	cama_area.body_entered.connect(_on_cama_entrou)
	_show_indicator(true)


func _desativar_area(nome: String) -> void:
	var n := get_node_or_null(nome)
	if n and n is Area2D:
		n.set_deferred("monitoring", false)


func _on_cama_entrou(body: Node2D) -> void:
	if minigame_aberto or dormiu:
		return
	if not body.is_in_group("player"):
		return
	_abrir_dormir()


func _set_player_movement(enabled: bool) -> void:
	if player and "movement_enabled" in player:
		player.movement_enabled = enabled


func _abrir_dormir() -> void:
	minigame_aberto = true
	_set_player_movement(false)
	_show_indicator(false)

	minigame_inst = MINIGAME_DORMIR.instantiate()
	add_child(minigame_inst)

	if minigame_inst.has_signal("finished"):
		minigame_inst.finished.connect(_on_dormir_finished)
	else:
		push_error("minigame_carneirinhos não possui o signal finished!")


func _on_dormir_finished(success: bool) -> void:
	minigame_aberto = false

	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()
	minigame_inst = null

	if not success:
		# Desistiu: pode tentar de novo ao voltar para a cama.
		_set_player_movement(true)
		_show_indicator(true)
		return

	dormiu = true
	GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, SUB_ID)

	# Encerra o dia indo para a cena final (a ser desenvolvida por outro dev),
	# reaproveitando a transição de fade já existente.
	var trans := get_tree().get_first_node_in_group("transicao")
	if trans and trans.has_method("ir_para_cena"):
		trans.ir_para_cena(CENA_FINAL)
	else:
		get_tree().change_scene_to_file(CENA_FINAL)


func _show_indicator(show: bool) -> void:
	if cama_indicator == null:
		return

	if _indicator_tween and _indicator_tween.is_valid():
		_indicator_tween.kill()

	if not show:
		cama_indicator.visible = false
		return

	cama_indicator.visible = true
	cama_indicator.modulate.a = 1.0

	_indicator_tween = create_tween().set_loops()
	_indicator_tween.tween_property(cama_indicator, "modulate:a", 0.4, 0.6)
	_indicator_tween.tween_property(cama_indicator, "modulate:a", 1.0, 0.6)
