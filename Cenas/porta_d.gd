extends Area2D

@export var cena_destino: String = "res://Cenas/sala_bloco_d.tscn"
@export var mensagem: String = "Entrando na sala do Bloco D..."

var pode_entrar: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not ("player" in body.name.to_lower() and pode_entrar):
		return

	pode_entrar = false

	var hud = get_tree().get_first_node_in_group("hud")
	var transicao = get_tree().get_first_node_in_group("transicao")

	if hud:
		hud.mostrar_notificacao(mensagem)

	await get_tree().create_timer(1.0).timeout

	if body.has_method("salvar_progresso"):
		body.salvar_progresso(body.global_position + Vector2(0, 50))

	if transicao:
		transicao.ir_para_cena(cena_destino)
