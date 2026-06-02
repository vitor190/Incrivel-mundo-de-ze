extends Node2D

const MINIGAME = preload("res://Cenas/NPC's/Mudanças_Mateus/CorrigirCodigo.tscn")

var minigame_aberto := false
var jogador_na_area := false
var minigame_inst = null

func _ready():
	var area = get_node_or_null("TileMaps/sala de aula/ComputadorInterativo")
	if area == null:
		area = get_node_or_null("sala de aula/ComputadorInterativo")
	if area == null:
		push_error("ComputadorInterativo não encontrado!")
		return
	area.body_entered.connect(_jogador_entrou)
	area.body_exited.connect(_jogador_saiu)

func _input(event):
	if jogador_na_area and not minigame_aberto:
		if event.is_action_pressed("ui_accept"):
			_abrir_minigame()

func _jogador_entrou(body):
	if body.name == "player":
		jogador_na_area = true

func _jogador_saiu(body):
	if body.name == "player":
		jogador_na_area = false

func _abrir_minigame():
	minigame_aberto = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.movement_enabled = false
	minigame_inst = MINIGAME.instantiate()
	add_child(minigame_inst)
	var canvas = minigame_inst
	canvas.minigame_concluido.connect(_fechar_minigame)
	canvas.abrir()

func _fechar_minigame(sucesso, xp):
	minigame_aberto = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.movement_enabled = true
	if sucesso:
		print("Ganhou %d XP!" % xp)
	while is_instance_valid(minigame_inst) and minigame_inst.visible:
		await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()
