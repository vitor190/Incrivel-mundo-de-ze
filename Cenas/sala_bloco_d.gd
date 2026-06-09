extends Node2D

const MINIGAME_CODIGO: PackedScene = preload("res://Cenas/NPC's/Mudanças_Mateus/CorrigirCodigo.tscn")
const MINIGAME_LOGICA: PackedScene = preload("res://Cenas/minigame_quiz_logica.tscn")

const MISSAO_ID := "unifor_bloco_d"
const CODIGO_SUB_ID := "bloco_d_mini1"
const LOGICA_SUB_ID := "bloco_d_mini2"

var minigame_aberto := false
var minigame_inst: Node = null
var _logica_tween: Tween = null
var _codigo_tween: Tween = null

# --- CAMINHOS EXATOS BASEADOS NA ÁRVORE DE CENAS VISÍVEL NA IMAGE_4.PNG ---

# Task de Código (Provavelmente a da Esquerda, que não está sumindo)
# Note que a rota é "LogicaArea/IndicadorQuest"
@onready var codigo_indicator: CanvasItem = $"LogicaArea/IndicadorQuest"

# Task do Quiz (Provavelmente a da Direita, que sumiu corretamente)
# ATENÇÃO À TYPO: O nó na árvore está como "IndicadorQues" (sem T no final)
@onready var logica_indicator: CanvasItem = $"TileMaps/sala de aula/Area2D/IndicadorQuest2"

# Referências às Area2D para colisão (usando as rotas da árvore)
@onready var codigo_area_colisao: Area2D = $LogicaArea
@onready var logica_area_colisao: Area2D = $"TileMaps/sala de aula/Area2D"

# -----------------------------------------------------------------------------


func _ready() -> void:
	# Diz para o sistema qual bloco estamos gerenciando
	GerenciadorMissoes.set_cena("bloco_d")

	# Conecta os sinais de colisão usando as referências de rota exatas
	if codigo_area_colisao:
		codigo_area_colisao.body_entered.connect(_on_codigo_entrou)
	else:
		push_error("⚠️ Erro: Area2D de colisão do Código não encontrada na rota '$LogicaArea'!")

	if logica_area_colisao:
		logica_area_colisao.body_entered.connect(_on_logica_entrou)
	else:
		push_error("⚠️ Erro: Area2D de colisão do Quiz não encontrada na rota '$TileMaps/sala de aula/Area2D'!")

	# Faz a primeira checagem para ver se já concluímos as tarefas e oculta os ícones se necessário
	_refresh_indicators()


func _refresh_indicators() -> void:
	var has_minigame := minigame_aberto

	# Lógica para o indicador do Código (Esquerda)
	_codigo_tween = _set_indicator(
		codigo_indicator,
		_codigo_tween,
		not has_minigame and not _sub_finalizada(CODIGO_SUB_ID)
	)

	# Lógica para o indicador do Quiz (Direita)
	_logica_tween = _set_indicator(
		logica_indicator,
		_logica_tween,
		not has_minigame and not _sub_finalizada(LOGICA_SUB_ID)
	)


# Função auxiliar para gerenciar visibilidade e animação (idêntica à anterior)
func _set_indicator(lbl: CanvasItem, tween: Tween, show: bool) -> Tween:
	if lbl == null:
		return null

	if tween and tween.is_valid():
		tween.kill()

	if not show:
		lbl.visible = false
		return null

	# Mostra e anima se não estiver concluída e não tiver minigame aberto
	lbl.visible = true
	lbl.modulate.a = 1.0

	var t := create_tween()
	t.set_loops()
	t.tween_property(lbl, "modulate:a", 0.35, 0.55)
	t.tween_property(lbl, "modulate:a", 1.0, 0.55)

	return t


func _on_codigo_entrou(body: Node2D) -> void:
	if minigame_aberto or _sub_finalizada(CODIGO_SUB_ID):
		return

	# Verifica se quem entrou foi o Zé
	if not body.is_in_group("player") and body.name != "player":
		return

	# Esconde o ponto de exclamação da esquerda instantaneamente
	if codigo_indicator:
		codigo_indicator.hide()

	_abrir_codigo()


func _on_logica_entrou(body: Node2D) -> void:
	if minigame_aberto or _sub_finalizada(LOGICA_SUB_ID):
		return

	# Verifica se quem entrou foi o Zé
	if not body.is_in_group("player") and body.name != "player":
		return

	# Esconde o ponto de exclamação da direita instantaneamente
	if logica_indicator:
		logica_indicator.hide()

	_abrir_logica()


func _get_player() -> Node:
	var tree := get_tree()
	if tree == null: return null
	return tree.get_first_node_in_group("player")


func _set_player_movement(enabled: bool) -> void:
	var player := _get_player()
	if player and "movement_enabled" in player:
		player.movement_enabled = enabled


func _abrir_codigo() -> void:
	minigame_aberto = true
	_set_player_movement(false)
	_refresh_indicators()

	minigame_inst = MINIGAME_CODIGO.instantiate()
	add_child(minigame_inst)

	var canvas: CanvasLayer = minigame_inst.get_node_or_null("CanvasLayer")

	# Verificação de segurança idêntica
	if canvas == null:
		push_error("⚠️ CanvasLayer não encontrado dentro do minigame CorrigirCodigo!")
		_reset_on_abrir_fail()
		return

	if canvas.has_signal("minigame_concluido"):
		canvas.minigame_concluido.connect(_fechar_codigo)

	if canvas.has_method("abrir"):
		canvas.abrir()


func _reset_on_abrir_fail() -> void:
	minigame_aberto = false
	_set_player_movement(true)
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()
	minigame_inst = null
	_refresh_indicators()


func _fechar_codigo(sucesso: bool, xp) -> void:
	minigame_aberto = false
	_set_player_movement(true)

	if sucesso:
		GameState.add_xp(float(xp))
		GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, CODIGO_SUB_ID)
	else:
		GerenciadorMissoes.falhar_sub_missao(MISSAO_ID, CODIGO_SUB_ID)

	# Limpeza e atualização
	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()

	minigame_inst = null
	# Esta chamada DEVE ocultar a exclamação se GerenciadorMissoes salvou corretamente
	_refresh_indicators()


func _abrir_logica() -> void:
	minigame_aberto = true
	_set_player_movement(false)
	_refresh_indicators()

	minigame_inst = MINIGAME_LOGICA.instantiate()
	add_child(minigame_inst)

	if minigame_inst.has_signal("finished"):
		minigame_inst.finished.connect(_fechar_logica)
	else:
		push_error("⚠️ O minigame de lógica não possui o signal finished!")


func _fechar_logica(sucesso: bool) -> void:
	minigame_aberto = false
	_set_player_movement(true)

	if sucesso:
		GerenciadorMissoes.concluir_sub_missao(MISSAO_ID, LOGICA_SUB_ID)
	else:
		GerenciadorMissoes.falhar_sub_missao(MISSAO_ID, LOGICA_SUB_ID)

	if is_instance_valid(minigame_inst):
		minigame_inst.queue_free()

	minigame_inst = null
	_refresh_indicators()


# Função para verificar o status real da missão no seu Singleton (Autoload)
func _sub_finalizada(sub_id: String) -> bool:
	var subs: Array = DadosMissoes.missoes.get(MISSAO_ID, {}).get("sub_missoes", [])

	for sub in subs:
		if sub.get("id", "") == sub_id:
			# Retorna true se estiver concluída OU falhou
			return bool(sub.get("concluida", false)) or bool(sub.get("falhou", false))

	# Se não achou, assume que não acabou
	return false
