extends SubViewport

@onready var camera2d = $Camera2D
@onready var player = $"../../../../player" 

func _ready() -> void:
	world_2d = get_tree().root.world_2d



func _process(delta: float) -> void:
	$Camera2D.position = player.position
