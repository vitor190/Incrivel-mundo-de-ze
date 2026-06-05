## cena_final.gd — PLACEHOLDER.
## Cena final do dia, a ser desenvolvida por outro desenvolvedor.
## O fluxo de "dormir" do quarto_noite leva até aqui via a transição padrão.
## Por enquanto: tela de encerramento. ENTER/ESPAÇO volta ao menu (lobby).
extends Node

const LOBBY := "res://Cenas/lobby.tscn"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			get_tree().change_scene_to_file(LOBBY)
