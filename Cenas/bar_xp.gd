extends ProgressBar

func _ready() -> void:
	value = GameState.xp
	GameState.xp_changed.connect(_on_xp_changed)

func _on_xp_changed(v: float) -> void:
	value = v
