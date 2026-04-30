extends SubViewport

@onready var camera2d = $Camera2D
@onready var player = $"../../../../player" 

func _ready() -> void:
	world_2d = get_tree().root.world_2d



func _process(delta: float) -> void:
	if player:
		camera2d.position = camera2d.position.lerp(player.position, 5 * delta)
