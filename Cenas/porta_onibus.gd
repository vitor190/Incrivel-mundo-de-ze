## porta_onibus.gd
extends Area2D

@export var destino: String = "res://quarto.tscn"
@export var requer_vestido: bool = false
@export var requer_unifor_concluida: bool = false
@export var mensagem_bloqueio: String = "Vista-se antes de pegar o ônibus."
@export var mensagem_bloqueio_unifor: String = "Conclua todas as tasks antes de ir ao trabalho."

var viajando := false
var player_ref: Node = null

@onready var viagem_onibus = $"../ViagemOnibus"

func _ready():
	body_entered.connect(_quando_entrou)

func _quando_entrou(body):
	if body.name != "player" or viajando:
		return
	player_ref = body

	if requer_vestido and not GameState.is_dressed:
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.mostrar_notificacao(mensagem_bloqueio)
		return

	if requer_unifor_concluida and not GerenciadorMissoes.pode_ir_trabalho():
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.mostrar_notificacao(mensagem_bloqueio_unifor)
		return

	viajar()

func viajar():
	viajando = true
	GerenciadorMissoes.concluir_missao("quarto_sair")
	if player_ref:
		player_ref.set_process(false)
		player_ref.set_physics_process(false)
		player_ref.visible = false
	ResourceLoader.load_threaded_request(destino)
	await viagem_onibus.tocar_animacao_viagem()
	await _aguardar_cena(destino)

func _aguardar_cena(caminho: String):
	while true:
		var status = ResourceLoader.load_threaded_get_status(caminho)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var recurso = ResourceLoader.load_threaded_get(caminho)
			get_tree().change_scene_to_packed(recurso)
			return
		elif status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Falha ao carregar cena: " + caminho)
			return
		await get_tree().process_frame
