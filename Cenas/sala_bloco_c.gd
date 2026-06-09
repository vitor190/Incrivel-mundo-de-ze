extends Node2D

const QUIZ_MINIGAME_SCENE: PackedScene = preload("res://Cenas/minigame_quiz_cg.tscn")
const RGB_MINIGAME_SCENE: PackedScene = preload("res://Cenas/minigame_rgb.tscn")

const MISSAO_ID := "unifor_bloco_c"
const QUIZ_SUB_ID := "bloco_c_mini1"
const RGB_SUB_ID := "bloco_c_mini2"

@onready var player: CharacterBody2D = $player
@onready var quiz_area: Area2D = $QuizArea
@onready var rgb_area: Area2D = $RgbArea

# Caminhos atualizados para os sprites de exclamação de acordo com a sua árvore
@onready var quiz_indicator: CanvasItem = $QuizArea/IndicadorQuest
@onready var rgb_indicator: CanvasItem = $RgbArea/IndicadorQuest2

var _active_minigame: CanvasLayer
var _quiz_tween: Tween
var _rgb_tween: Tween


func _ready() -> void:
	GerenciadorMissoes.set_cena("bloco_c")

	quiz_area.body_entered.connect(_on_quiz_body_entered)
	rgb_area.body_entered.connect(_on_rgb_body_entered)

	_refresh_indicators()


func _refresh_indicators() -> void:
	var has_minigame: bool = _active_minigame != null
	_quiz_tween = _set_indicator(quiz_indicator, _quiz_tween, not has_minigame and not _sub_done(QUIZ_SUB_ID))
	_rgb_tween = _set_indicator(rgb_indicator, _rgb_tween, not has_minigame and not _sub_done(RGB_SUB_ID))


func _sub_done(sub_id: String) -> bool:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])
	for sub in subs:
		if sub.get("id", "") == sub_id:
			return bool(sub.get("concluida", false))
	return false


# Tipagem alterada para CanvasItem para suportar o Sprite2D
func _set_indicator(lbl: CanvasItem, tween: Tween, show: bool) -> Tween:
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


func _on_quiz_body_entered(body: Node2D) -> void:
	if _active_minigame or _sub_done(QUIZ_SUB_ID):
		return
	if not body.is_in_group("player"):
		return
		
	# Ocultação imediata
	if quiz_indicator:
		quiz_indicator.hide()
		
	_start_minigame(QUIZ_MINIGAME_SCENE, QUIZ_SUB_ID)


func _on_rgb_body_entered(body: Node2D) -> void:
	if _active_minigame or _sub_done(RGB_SUB_ID):
		return
	if not body.is_in_group("player"):
		return
		
	# Ocultação imediata
	if rgb_indicator:
		rgb_indicator.hide()
		
	_start_minigame(RGB_MINIGAME_SCENE, RGB_SUB_ID)


func _start_minigame(scene: PackedScene, sub_id: String) -> void:
	player.movement_enabled = false

	var mg: CanvasLayer = scene.instantiate()
	mg.finished.connect(_on_minigame_finished.bind(sub_id))
	add_child(mg)
	_active_minigame = mg

	_refresh_indicators()


func _on_minigame_finished(_success: bool, sub_id: String) -> void:
	_active_minigame = null
	player.movement_enabled = true
	GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, sub_id)
	_refresh_indicators()
