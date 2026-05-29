extends Node2D

const MINIGAME = preload("res://Cenas/NPC's/Mudanças_Mateus/CorrigirCodigo.tscn")
var minigame_aberto := false
var minigame_inst = null

func _ready():
	GerenciadorMissoes.set_cena("bloco_d")
	var area = get_node_or_null("TileMaps/sala de aula/Area2D")
	if area == null:
		push_error("Area2D não encontrado!")
		return
	area.body_entered.connect(_jogador_entrou)

func _jogador_entrou(body):
	if body.name == "player" and not minigame_aberto:
		_abrir_minigame()

func _abrir_minigame():
	minigame_aberto = true
	get_tree().get_first_node_in_group("player").movement_enabled = false
	minigame_inst = MINIGAME.instantiate()
	add_child(minigame_inst)
	var canvas = minigame_inst.get_node("CanvasLayer")
	canvas.minigame_concluido.connect(_fechar_minigame)
	canvas.abrir()

func _fechar_minigame(sucesso, xp):
	minigame_aberto = false
	get_tree().get_first_node_in_group("player").movement_enabled = true
	if sucesso:
		print("Ganhou %d XP!" % xp)
	while is_instance_valid(minigame_inst) and minigame_inst.visible:
		await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()
