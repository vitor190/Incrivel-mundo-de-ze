extends Node2D

const MINIGAME = preload("res://Cenas/NPC's/Mudanças_Mateus/CorrigirCodigo.tscn")
const MISSAO_ID := "unifor_bloco_d"
const SUB_ID := "bloco_d_mini1"

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
	if body.name == "player" and not minigame_aberto and not _sub_finalizada():
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
		GameState.add_xp(float(xp))
		GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, SUB_ID)
	else:
		_marcar_falhou()
	while is_instance_valid(minigame_inst) and minigame_inst.visible:
		await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()

func _sub_finalizada() -> bool:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])
	for sub in subs:
		if sub.get("id", "") == SUB_ID:
			return bool(sub.get("concluida", false)) or bool(sub.get("falhou", false))
	return false

func _marcar_falhou() -> void:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])
	for sub in subs:
		if sub.get("id", "") == SUB_ID:
			sub["falhou"] = true
			GerenciadorMissoes.emit_signal("missoes_atualizadas")
			return
