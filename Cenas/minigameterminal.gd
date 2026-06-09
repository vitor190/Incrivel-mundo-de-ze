extends Area2D

const MINIGAME_LOG : PackedScene = preload("res://LogMinigame.tscn")

var minigame_aberto := false
var minigame_inst : Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if minigame_aberto:
		return
	if not body.is_in_group("player") and body.name != "player":
		return
	_abrir_minigame()

func _abrir_minigame() -> void:
	minigame_aberto = true
	_set_player_movement(false)
	minigame_inst = MINIGAME_LOG.instantiate()
	add_child(minigame_inst)
	if minigame_inst.has_signal("minigame_concluido"):
		minigame_inst.minigame_concluido.connect(_fechar_minigame)
	if minigame_inst.has_method("abrir"):
		minigame_inst.abrir()

func _fechar_minigame(sucesso: bool, xp: int) -> void:
	minigame_aberto = false
	_set_player_movement(true)
	if sucesso:
		GameState.add_xp(float(xp))
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()
	minigame_inst = null

func _set_player_movement(enabled: bool) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and "movement_enabled" in player:
		player.movement_enabled = enabled
