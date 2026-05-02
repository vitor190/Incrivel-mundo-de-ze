extends AudioStreamPlayer

func _ready():
	stream = load("res://assets/audio/unifor_theme.ogg")
	stream.loop = true
	play()
