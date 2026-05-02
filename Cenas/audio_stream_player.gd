extends AudioStreamPlayer

func _ready():
	stream = load("res://unifor_theme.ogg")
	stream.loop = true
	play()
