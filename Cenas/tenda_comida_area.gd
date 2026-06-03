extends Area2D

@export var fome_recuperada: float = 15.0
@export var mensagem: String = "[E] Comer"

var player_ref: Node = null

@onready var label: Label = $Label
@onready var som_comer: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	label.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if not player_ref:
		return

	if Input.is_action_just_pressed("interact"):
		_comer()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	player_ref = body

	label.text = mensagem
	label.visible = true


func _on_body_exited(body: Node) -> void:
	if body != player_ref:
		return

	player_ref = null
	label.visible = false


func _comer() -> void:
	if not player_ref:
		return

	# SOM DE COMER
	if som_comer:
		som_comer.play()

	# AUMENTA A FOME
	var nova_fome: float = Global.fome + fome_recuperada

	nova_fome = clamp(nova_fome, 0.0, 100.0)

	Global.fome = nova_fome

	# Atualiza player
	if "fome_atual" in player_ref:
		player_ref.fome_atual = nova_fome

	# Atualiza barra HUD
	if player_ref.has_signal("fome_alterada"):
		player_ref.fome_alterada.emit(nova_fome)

	# Notificação
	var hud = get_tree().get_first_node_in_group("hud")

	if hud and hud.has_method("mostrar_notificacao"):
		hud.mostrar_notificacao(
			"+%d de fome" % int(fome_recuperada)
		)
