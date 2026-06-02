extends Node2D

const MINIGAME_CODIGO: PackedScene = preload("res://Cenas/NPC's/Mudanças_Mateus/CorrigirCodigo.tscn")
const MINIGAME_LOGICA: PackedScene = preload("res://Cenas/minigame_quiz_logica.tscn")
const MISSAO_ID := "unifor_bloco_d"
const CODIGO_SUB_ID := "bloco_d_mini1"
const LOGICA_SUB_ID := "bloco_d_mini2"

var minigame_aberto := false
var minigame_inst = null
var _logica_tween: Tween
var _codigo_tween: Tween

@onready var logica_area: Area2D = $LogicaArea
@onready var codigo_indicator: Label = $CodigoIndicator
@onready var logica_indicator: Label = $LogicaIndicator

func _ready():
	GerenciadorMissoes.set_cena("bloco_d")

	var codigo_area = get_node_or_null("TileMaps/sala de aula/Area2D")
	if codigo_area == null:
		push_error("Area2D do CorrigirCodigo não encontrado!")
	else:
		codigo_area.body_entered.connect(_on_codigo_entrou)

	logica_area.body_entered.connect(_on_logica_entrou)

	_refresh_indicators()


func _refresh_indicators() -> void:
	var has_minigame: bool = minigame_aberto
	_codigo_tween = _set_indicator(codigo_indicator, _codigo_tween, not has_minigame and not _sub_finalizada(CODIGO_SUB_ID))
	_logica_tween = _set_indicator(logica_indicator, _logica_tween, not has_minigame and not _sub_finalizada(LOGICA_SUB_ID))


func _set_indicator(lbl: Label, tween: Tween, show: bool) -> Tween:
	if tween and tween.is_valid():
		tween.kill()

	if not show:
		lbl.visible = false
		return null

	lbl.visible = true
	lbl.modulate.a = 1.0
	var t: Tween = create_tween()
	t.set_loops()
	t.tween_property(lbl, "modulate:a", 0.35, 0.55)
	t.tween_property(lbl, "modulate:a", 1.0, 0.55)
	return t


func _on_codigo_entrou(body):
	if body.name == "player" and not minigame_aberto and not _sub_finalizada(CODIGO_SUB_ID):
		_abrir_codigo()


func _on_logica_entrou(body: Node2D) -> void:
	if minigame_aberto or _sub_finalizada(LOGICA_SUB_ID):
		return
	if not body.is_in_group("player") and body.name != "player":
		return
	_abrir_logica()


func _abrir_codigo() -> void:
	minigame_aberto = true
	get_tree().get_first_node_in_group("player").movement_enabled = false
	_refresh_indicators()
	minigame_inst = MINIGAME_CODIGO.instantiate()
	add_child(minigame_inst)
	var canvas = minigame_inst.get_node("CanvasLayer")
	canvas.minigame_concluido.connect(_fechar_codigo)
	canvas.abrir()


func _fechar_codigo(sucesso, xp):
	minigame_aberto = false
	get_tree().get_first_node_in_group("player").movement_enabled = true
	if sucesso:
		GameState.add_xp(float(xp))
		GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, CODIGO_SUB_ID)
	else:
		_marcar_falhou(CODIGO_SUB_ID)
	while is_instance_valid(minigame_inst) and minigame_inst.visible:
		await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()
	_refresh_indicators()


func _abrir_logica() -> void:
	minigame_aberto = true
	get_tree().get_first_node_in_group("player").movement_enabled = false
	_refresh_indicators()
	var mg: CanvasLayer = MINIGAME_LOGICA.instantiate()
	mg.finished.connect(_fechar_logica)
	add_child(mg)
	minigame_inst = mg


func _fechar_logica(sucesso: bool) -> void:
	minigame_aberto = false
	get_tree().get_first_node_in_group("player").movement_enabled = true
	if sucesso:
		GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, LOGICA_SUB_ID)
	else:
		_marcar_falhou(LOGICA_SUB_ID)
	minigame_inst = null
	_refresh_indicators()


func _sub_finalizada(sub_id: String) -> bool:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])
	for sub in subs:
		if sub.get("id", "") == sub_id:
			return bool(sub.get("concluida", false)) or bool(sub.get("falhou", false))
	return false


func _marcar_falhou(sub_id: String) -> void:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])
	for sub in subs:
		if sub.get("id", "") == sub_id:
			sub["falhou"] = true
			GerenciadorMissoes.emit_signal("missoes_atualizadas")
			return
