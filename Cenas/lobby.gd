extends Control

# Main game scene — using the UID from project.godot (current main scene)
# Godot resolves UIDs to file paths automatically at runtime
const CENA_JOGO = "uid://d1fp3455quaio"

func _ready():
	# Connect buttons to their handler functions
	$BotaoIniciar.pressed.connect(_ao_iniciar)
	$BotaoSair.pressed.connect(_ao_sair)

func _ao_iniciar():
	# Change to the main gameplay scene
	var caminho = ResourceUID.get_id_path(ResourceUID.text_to_id(CENA_JOGO))
	get_tree().change_scene_to_file(caminho)

func _ao_sair():
	# Close the application (equivalent to Alt+F4)
	get_tree().quit()
