extends Node2D

const WAKE_MINIGAME_SCENE: PackedScene = preload("res://Cenas/minigame_acordar.tscn")
const DRESS_MINIGAME_SCENE: PackedScene = preload("res://Cenas/minigame_vestir.tscn")

const BED_POSITION := Vector2(30, 56)
const WAKE_POSITION := Vector2(60, 95)

@onready var player: CharacterBody2D = $player
@onready var wardrobe_area: Area2D = $WardrobeInteractArea
@onready var wardrobe_indicator: Label = $WardrobeIndicator

var _dress_minigame_active: bool = false
var _indicator_tween: Tween

func _ready() -> void:
	player.position = BED_POSITION
	player.movement_enabled = false
	GameState.set_dressed(false)
	wardrobe_indicator.visible = false
	wardrobe_area.body_entered.connect(_on_wardrobe_body_entered)
	var wake_mg: CanvasLayer = WAKE_MINIGAME_SCENE.instantiate()
	wake_mg.finished.connect(_on_wake_minigame_finished)
	add_child(wake_mg)

func _on_wake_minigame_finished(_woke_on_time: bool) -> void:
	player.position = WAKE_POSITION
	player.movement_enabled = true
	_show_wardrobe_indicator()

func _show_wardrobe_indicator() -> void:
	if GameState.is_dressed:
		return
	wardrobe_indicator.visible = true
	wardrobe_indicator.modulate.a = 1.0
	if _indicator_tween and _indicator_tween.is_valid():
		_indicator_tween.kill()
	_indicator_tween = create_tween().set_loops()
	_indicator_tween.tween_property(wardrobe_indicator, "modulate:a", 0.35, 0.55)
	_indicator_tween.tween_property(wardrobe_indicator, "modulate:a", 1.0, 0.55)

func _hide_wardrobe_indicator() -> void:
	if _indicator_tween and _indicator_tween.is_valid():
		_indicator_tween.kill()
	wardrobe_indicator.visible = false

func _on_wardrobe_body_entered(body: Node2D) -> void:
	if _dress_minigame_active or GameState.is_dressed:
		return
	if not body.is_in_group("player"):
		return
	_dress_minigame_active = true
	player.movement_enabled = false
	_hide_wardrobe_indicator()
	var dress_mg: CanvasLayer = DRESS_MINIGAME_SCENE.instantiate()
	dress_mg.finished.connect(_on_dress_minigame_finished)
	add_child(dress_mg)

func _on_dress_minigame_finished(success: bool) -> void:
	_dress_minigame_active = false
	player.movement_enabled = true
	if success:
		GameState.set_dressed(true)
	else:
		_show_wardrobe_indicator()
