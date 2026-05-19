extends CanvasLayer

@onready var escurecer: ColorRect = $"Escurecer"
@onready var onibus: Sprite2D = $"OnibusAnimado"

func _ready():
	visible = true
	escurecer.color = Color.BLACK
	escurecer.modulate.a = 0.0
	onibus.visible = false

func tocar_animacao_viagem():
	var tamanho_tela = get_viewport().get_visible_rect().size

	onibus.visible = true
	escurecer.modulate.a = 0.0

	var altura_faixa = tamanho_tela.y * 0.50
	escurecer.size = Vector2(tamanho_tela.x, altura_faixa)
	escurecer.position = Vector2(0, (tamanho_tela.y - altura_faixa) / 2.0)

	var centro_faixa_y = escurecer.position.y + altura_faixa / 2.0

	onibus.scale = Vector2(1.3, 1.3)
	onibus.position = Vector2(tamanho_tela.x + 250, centro_faixa_y)

	var tween = create_tween()
	tween.tween_property(escurecer, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(onibus, "position", Vector2(0, centro_faixa_y), 1.4)

	await tween.finished

	# Expande a faixa para cobrir a tela inteira enquanto carrega
	escurecer.size = Vector2(tamanho_tela.x, tamanho_tela.y)
	escurecer.position = Vector2(0, 0)
	onibus.visible = false
