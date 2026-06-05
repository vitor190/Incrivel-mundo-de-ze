extends Area2D

@export var cena_destino: String = "res://Cenas/sala_bloco_c.tscn"
@export var mensagem: String = "Entrando na sala do Bloco C..."
@export var requer_vestido: bool = false

const REARM_DIST := 70.0

var pode_entrar: bool = true
var _rearmar_ao_afastar: bool = false

@onready var _shape: Node2D = get_node_or_null("CollisionShape2D")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_process(false)

	# Se o player nasce colado na porta (acabou de voltar do Bloco C), desarma a
	# entrada até ele se afastar. Evita reentrar sem querer ao andar para cima.
	await get_tree().physics_frame

	var p := get_tree().get_first_node_in_group("player")
	if p and _porta_pos().distance_to(p.global_position) < REARM_DIST:
		pode_entrar = false
		_rearmar_ao_afastar = true
		set_process(true)


func _process(_delta: float) -> void:
	if not _rearmar_ao_afastar:
		return

	var p := get_tree().get_first_node_in_group("player")
	if p and _porta_pos().distance_to(p.global_position) >= REARM_DIST:
		_rearmar_ao_afastar = false
		pode_entrar = true
		set_process(false)


func _porta_pos() -> Vector2:
	return _shape.global_position if _shape else global_position


func _on_body_entered(body: Node2D) -> void:
	if not ("player" in body.name.to_lower() and pode_entrar):
		return

	if requer_vestido and not Global.is_dressed:
		var hud_block = get_tree().get_first_node_in_group("hud")
		if hud_block:
			hud_block.mostrar_notificacao("Vista-se antes de sair do quarto.")
		return

	pode_entrar = false

	var hud = get_tree().get_first_node_in_group("hud")
	var transicao = get_tree().get_first_node_in_group("transicao")

	if hud:
		hud.mostrar_notificacao(mensagem)

	await get_tree().create_timer(1.0).timeout

	if body.has_method("salvar_progresso"):
		body.salvar_progresso(body.global_position + Vector2(0, 55))

	if transicao:
		transicao.ir_para_cena(cena_destino)
