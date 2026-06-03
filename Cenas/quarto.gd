## quarto.gd
extends Node2D

const WAKE_MINIGAME_SCENE: PackedScene = preload("res://Cenas/minigame_acordar.tscn")
const DRESS_MINIGAME_SCENE: PackedScene = preload("res://Cenas/minigame_vestir.tscn")

const PLAYER_SCENE: PackedScene = preload("res://Cenas/player.tscn")
const PLAYER2_SCENE: PackedScene = preload("res://Cenas/player_2.tscn")

const BED_POSITION := Vector2(30, 56)
const WAKE_POSITION := Vector2(60, 95)

@onready var player: CharacterBody2D = $player
@onready var camera: Camera2D = $player/Camera
@onready var wardrobe_area: Area2D = $WardrobeInteractArea
@onready var wardrobe_indicator: Label = $WardrobeIndicator

var _dress_minigame_active: bool = false
var _indicator_tween: Tween


func _ready() -> void:
	# Começa usando o player2 (cueca)
	_trocar_player_inicial_para_player2()

	player.position = BED_POSITION
	player.movement_enabled = false

	GameState.set_dressed(false)

	wardrobe_indicator.visible = false
	wardrobe_area.body_entered.connect(_on_wardrobe_body_entered)

	GerenciadorMissoes.set_cena("quarto")

	var wake_mg: CanvasLayer = WAKE_MINIGAME_SCENE.instantiate()
	wake_mg.finished.connect(_on_wake_minigame_finished)

	add_child(wake_mg)


func _on_wake_minigame_finished(_woke_on_time: bool) -> void:
	player.position = WAKE_POSITION
	player.movement_enabled = true

	_show_wardrobe_indicator()

	GerenciadorMissoes.concluir_sub_missao(
		"quarto_acorde",
		"quarto_mini1"
	)


func _on_wardrobe_body_entered(body: Node2D) -> void:
	if _dress_minigame_active:
		return

	if not body.is_in_group("player"):
		return

	if GameState.is_dressed:
		return

	_dress_minigame_active = true

	player.movement_enabled = false

	_hide_wardrobe_indicator()

	var dress_mg: CanvasLayer = DRESS_MINIGAME_SCENE.instantiate()

	dress_mg.finished.connect(_on_dress_minigame_finished)

	add_child(dress_mg)


func _on_dress_minigame_finished(success: bool) -> void:
	_dress_minigame_active = false

	if success:
		GameState.set_dressed(true)

		# Troca do player2 para o player vestido
		_trocar_para_player_vestido()

		GerenciadorMissoes.concluir_sub_missao(
			"quarto_acorde",
			"quarto_mini2"
		)
	else:
		player.movement_enabled = true
		_show_wardrobe_indicator()


func _trocar_player_inicial_para_player2() -> void:
	var posicao_inicial: Vector2 = BED_POSITION

	# Remove a câmera do player antigo
	if camera and camera.get_parent():
		camera.get_parent().remove_child(camera)

	# Remove player antigo
	if player:
		player.remove_from_group("player")
		remove_child(player)
		player.queue_free()

	# Cria player2
	var novo_player := PLAYER2_SCENE.instantiate() as CharacterBody2D

	novo_player.name = "player"
	novo_player.position = posicao_inicial
	novo_player.movement_enabled = false

	# MUITO IMPORTANTE
	novo_player.add_to_group("player")

	add_child(novo_player)

	player = novo_player

	# Recoloca câmera
	player.add_child(camera)

	_configurar_camera()


func _trocar_para_player_vestido() -> void:
	var posicao_atual: Vector2 = player.global_position

	# Remove câmera do player2
	if camera and camera.get_parent():
		camera.get_parent().remove_child(camera)

	# Remove player2
	if player:
		player.remove_from_group("player")
		remove_child(player)
		player.queue_free()

	# Cria player vestido
	var novo_player := PLAYER_SCENE.instantiate() as CharacterBody2D

	novo_player.name = "player"
	novo_player.global_position = posicao_atual
	novo_player.movement_enabled = true

	# MUITO IMPORTANTE
	novo_player.add_to_group("player")

	add_child(novo_player)

	player = novo_player

	# Recoloca câmera
	player.add_child(camera)

	_configurar_camera()


func _configurar_camera() -> void:
	camera.position = Vector2.ZERO

	camera.enabled = true
	camera.make_current()

	camera.ignore_rotation = true

	# Configuração do print
	camera.zoom = Vector2(4.2, 4.2)


func _show_wardrobe_indicator() -> void:
	if GameState.is_dressed:
		return

	wardrobe_indicator.visible = true
	wardrobe_indicator.modulate.a = 1.0

	if _indicator_tween and _indicator_tween.is_valid():
		_indicator_tween.kill()

	_indicator_tween = create_tween().set_loops()

	_indicator_tween.tween_property(
		wardrobe_indicator,
		"modulate:a",
		0.35,
		0.55
	)

	_indicator_tween.tween_property(
		wardrobe_indicator,
		"modulate:a",
		1.0,
		0.55
	)


func _hide_wardrobe_indicator() -> void:
	if _indicator_tween and _indicator_tween.is_valid():
		_indicator_tween.kill()

	wardrobe_indicator.visible = false
