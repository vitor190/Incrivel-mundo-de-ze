extends AudioStreamPlayer

func _ready():
	stream = load("res://unifor_theme_v4.ogg")
	stream.loop = true
	play()
