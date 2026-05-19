extends Area2D

@export var cena_destino: String = "res://Cenas/campus.tscn"
@export var mensagem: String = "Saindo da sala do Bloco D..."

var pode_entrar: bool = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if "player" in body.name.to_lower() and pode_entrar:
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
