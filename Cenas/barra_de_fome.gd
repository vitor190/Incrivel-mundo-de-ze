extends Node2D

@onready var progress_bar = $CanvasLayer/ProgressBar

func _ready() -> void:
	await get_tree().process_frame

	if progress_bar:
		progress_bar.min_value = 0
		progress_bar.max_value = 100
		progress_bar.value = Global.fome

	var player = get_tree().get_first_node_in_group("player")

	if player:
		if not player.fome_alterada.is_connected(_on_player_fome_alterada):
			player.fome_alterada.connect(_on_player_fome_alterada)

		_on_player_fome_alterada(player.fome_atual)
	else:
		_on_player_fome_alterada(Global.fome)


func _on_player_fome_alterada(novo_valor: float) -> void:
	if progress_bar:
		progress_bar.value = novo_valor
