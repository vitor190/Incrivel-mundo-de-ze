extends ProgressBar

func _ready() -> void:
	await get_tree().process_frame

	min_value = 0
	max_value = GameState.MAX_XP
	value = GameState.xp

	if not GameState.xp_changed.is_connected(_on_xp_changed):
		GameState.xp_changed.connect(_on_xp_changed)


func _on_xp_changed(novo_valor: float) -> void:
	value = novo_valor
