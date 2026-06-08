extends Node

const LOBBY := "res://Cenas/lobby.tscn"
const REINICIAR_DIA := "res://Cenas/quarto.tscn"

@onready var titulo: Label = $CanvasLayer/VBox/Titulo
@onready var sub: Label = $CanvasLayer/VBox/Sub
@onready var hint: Label = $CanvasLayer/VBox/Hint


func _ready() -> void:
	_mostrar_resultado()


func _mostrar_resultado() -> void:
	var xp_final: float = Global.xp

	if xp_final >= 80.0:
		titulo.text = "★★★ PROMOVIDO!"
		titulo.modulate = Color(1.0, 0.9, 0.2)

		sub.text = "XP: %d\nZé virou Desenvolvedor!" % int(xp_final)

		hint.text = "[ENTER/ESPAÇO] Voltar ao menu"

	elif xp_final >= 60.0:
		titulo.text = "★★ QUASE LÁ!"
		titulo.modulate = Color(0.4, 0.8, 1.0)

		sub.text = "XP: %d\nZé falhou, mas pode repetir o dia." % int(xp_final)

		hint.text = "[ENTER/ESPAÇO] Repetir o dia"

	else:
		titulo.text = "★ GAME OVER"
		titulo.modulate = Color(1.0, 0.3, 0.3)

		sub.text = "XP: %d\nZé não conseguiu completar o dia." % int(xp_final)

		hint.text = "[ENTER/ESPAÇO] Voltar ao menu"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if (
			event.keycode == KEY_ENTER
			or event.keycode == KEY_SPACE
			or event.keycode == KEY_ESCAPE
		):
			get_viewport().set_input_as_handled()

			var xp_final: float = Global.xp

			# RESETA XP PARA NOVO DIA
			Global.xp = 0.0

			# 3 estrelas
			if xp_final >= 80.0:
				get_tree().change_scene_to_file(LOBBY)

			# 2 estrelas
			elif xp_final >= 60.0:
				get_tree().change_scene_to_file(REINICIAR_DIA)

			# 1 estrela
			else:
				get_tree().change_scene_to_file(LOBBY)
