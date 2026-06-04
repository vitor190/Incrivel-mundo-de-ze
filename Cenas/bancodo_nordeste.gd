## banco.gd
extends Node2D

const MINIGAME_CPF: PackedScene = preload("res://Cenas/minigame_cpf.tscn")

const MISSAO_ID := "banco_task1"
const SUB_IDS := ["banco_mini1", "banco_mini2"]
const FALA_CHEFE := "VOLTE AO TRABALHO!!! PRECISAMOS FAZER MAIS DINHEIRO, MAS ANTES, ME TRAGA UM CAFÉ..."

var minigame_aberto := false
var minigame_inst: Node = null
var player_perto := false
var dialogo_ativo := false
var _indicator_tween: Tween = null

@onready var chefe_area: Area2D = $ChefeArea
@onready var chefe_indicator: Label = $ChefeIndicator
@onready var dialogo: CanvasLayer = $DialogoChefe
@onready var dialogo_fala: Label = $DialogoChefe/Painel/Margin/VBox/Fala


func _ready() -> void:
	GerenciadorMissoes.set_cena("banco")

	if chefe_area:
		chefe_area.body_entered.connect(_on_chefe_entrou)
		chefe_area.body_exited.connect(_on_chefe_saiu)
	else:
		push_error("ChefeArea não encontrada na cena do banco!")

	dialogo.visible = false
	dialogo_fala.text = FALA_CHEFE
	_refresh_indicator()


func _unhandled_input(event: InputEvent) -> void:
	if minigame_aberto or not player_perto:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		get_viewport().set_input_as_handled()
		_interagir()


func _interagir() -> void:
	if not dialogo_ativo:
		# Primeiro E: o chefe fala (sempre).
		dialogo_ativo = true
		dialogo.visible = true
		_refresh_indicator()
	else:
		# E de novo: fecha a fala e, se a tarefa estiver pendente, abre o minigame.
		dialogo_ativo = false
		dialogo.visible = false
		_refresh_indicator()
		if not _tarefa_finalizada():
			_abrir_cpf()


func _refresh_indicator() -> void:
	var mostrar := player_perto and not minigame_aberto and not dialogo_ativo
	_indicator_tween = _set_indicator(chefe_indicator, _indicator_tween, mostrar)


func _set_indicator(lbl: Label, tween: Tween, show: bool) -> Tween:
	if lbl == null:
		return null

	if tween and tween.is_valid():
		tween.kill()

	if not show:
		lbl.visible = false
		return null

	lbl.visible = true
	lbl.modulate.a = 1.0

	var t := create_tween()
	t.set_loops()
	t.tween_property(lbl, "modulate:a", 0.35, 0.55)
	t.tween_property(lbl, "modulate:a", 1.0, 0.55)

	return t


func _on_chefe_entrou(body: Node2D) -> void:
	if not body.is_in_group("player") and body.name != "player":
		return

	player_perto = true
	_refresh_indicator()


func _on_chefe_saiu(body: Node2D) -> void:
	if not body.is_in_group("player") and body.name != "player":
		return

	player_perto = false
	dialogo_ativo = false
	dialogo.visible = false
	_refresh_indicator()


func _get_player() -> Node:
	var tree := get_tree()

	if tree == null:
		return null

	return tree.get_first_node_in_group("player")


func _set_player_movement(enabled: bool) -> void:
	var player := _get_player()

	if player and "movement_enabled" in player:
		player.movement_enabled = enabled


func _abrir_cpf() -> void:
	minigame_aberto = true
	_set_player_movement(false)
	_refresh_indicator()

	minigame_inst = MINIGAME_CPF.instantiate()
	add_child(minigame_inst)

	if minigame_inst.has_signal("finished"):
		minigame_inst.finished.connect(_fechar_cpf)
	else:
		push_error("O minigame de CPF não possui o signal finished!")


func _fechar_cpf(sucesso: bool) -> void:
	minigame_aberto = false
	_set_player_movement(true)

	for sub_id in SUB_IDS:
		if sucesso:
			GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, sub_id)
		else:
			GerenciadorMissoes.falhar_sub_missao(MISSAO_ID, sub_id)

	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()

	minigame_inst = null
	_refresh_indicator()


func _tarefa_finalizada() -> bool:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])

	for sub in subs:
		if not (bool(sub.get("concluida", false)) or bool(sub.get("falhou", false))):
			return false

	return subs.size() > 0
