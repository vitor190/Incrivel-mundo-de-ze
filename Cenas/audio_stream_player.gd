extends AudioStreamPlayer

func _ready():
	stream = load("res://unifor_theme.ogg")  # caminho correto!
	stream.loop = true
	play()
