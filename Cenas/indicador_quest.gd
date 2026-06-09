extends Sprite2D

# Guardamos a posição inicial em Y para a animação ter uma referência
@onready var posicao_inicial_y = position.y

func _ready():
	animar_flutuacao()

func animar_flutuacao():
	# Cria um Tween que se repete infinitamente
	var tween = create_tween().set_loops()
	
	# Faz o ícone subir 10 pixels em 0.6 segundos com uma transição suave
	tween.tween_property(self, "position:y", posicao_inicial_y - 10.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# Faz o ícone voltar para a posição original
	tween.tween_property(self, "position:y", posicao_inicial_y, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
