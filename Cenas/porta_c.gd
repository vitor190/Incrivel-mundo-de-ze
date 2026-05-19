extends Area2D

@export var cena_destino: String = "res://Cenas/sala_bloco_c.tscn"
@export var mensagem: String = "Entrando na sala do Bloco C..."
# Quando true, a porta só permite passagem se GameState.is_dressed for true.
# Caso contrário avisa via HUD e ignora o trigger até o jogador voltar e tentar
# de novo (sem consumir pode_entrar).
@export var requer_vestido: bool = false

var pode_entrar: bool = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not ("player" in body.name.to_lower() and pode_entrar):
		return

	if requer_vestido and not GameState.is_dressed:
		var hud_block = get_tree().get_first_node_in_group("hud")
		if hud_block:
			hud_block.mostrar_notificacao("Vista-se antes de sair do quarto.")
		return

	pode_entrar = false
	print("player detectado! Iniciando transição...")

	var hud = get_tree().get_first_node_in_group("hud")
	print("HUD encontrado: ", hud)

	var transicao = get_tree().get_first_node_in_group("transicao")
	print("Transicao encontrada: ", transicao)

	if hud:
		hud.mostrar_notificacao(mensagem)

	await get_tree().create_timer(1.0).timeout

	if transicao:
		transicao.ir_para_cena(cena_destino)
