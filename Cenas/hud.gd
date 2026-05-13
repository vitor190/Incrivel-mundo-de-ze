## hud.gd
## Attach this to a CanvasLayer node called "HUD"
## This node must be in your main scene (campus.tscn)
##
## Node structure:
## CanvasLayer (HUD)
##   └── PanelContainer (banner)
##         └── MarginContainer
##               └── Label (mensagem_label)

extends CanvasLayer

@onready var banner = $PanelContainer
@onready var label  = $PanelContainer/MarginContainer/Label
var tween: Tween

func _ready():
	add_to_group("hud")
	banner.modulate.a = 0  # começa invisível

func mostrar_notificacao(texto: String):
	label.text = texto

	# Cancela animação anterior se ainda estiver rodando
	if tween:
		tween.kill()

	tween = create_tween()

	# Aparece suavemente
	tween.tween_property(banner, "modulate:a", 1.0, 0.3)

	# Fica visível por 2 segundos
	tween.tween_interval(2.0)

	# Desaparece suavemente
	tween.tween_property(banner, "modulate:a", 0.0, 0.4)
