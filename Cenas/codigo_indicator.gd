extends Label # AGORA HERDA DE LABEL

func _ready() -> void:
	# Começa invisível se a task não estiver ativa (ajuste conforme sua lógica)
	# hide() 
	
	# Assim que a cena carregar ou o indicador aparecer, começa a flutuar
	iniciar_flutuacao()

func iniciar_flutuacao() -> void:
	# Cria um animador que roda em loop infinito
	var tween = create_tween().set_loops()
	
	# Grava a altura original (Y) que você deixou na tela 2D
	var altura_original = position.y
	
	# Anima subindo 5 pixels (suave como uma onda)
	tween.tween_property(self, "position:y", altura_original - 5, 0.5).set_trans(Tween.TRANS_SINE)
	
	# Anima descendo de volta para a posição original
	tween.tween_property(self, "position:y", altura_original, 0.5).set_trans(Tween.TRANS_SINE)

# Exemplo dentro do script que gerencia a área do computador de Lógica
# Verifique o caminho exato na sua árvore de cena se der erro
@onready var indicador_logica: Label = $"../LogicaIndicator" 

func _on_jogador_iniciou_a_task() -> void:
	# O jogador interagiu e o minigame abriu
	indicador_logica.hide() # Esconde o '!'
