## missoes_painel.gd
## Attach em CanvasLayer "PainelMissoes" em todas as cenas

extends CanvasLayer

@onready var lista = $Panel/VBoxContainer/lista_missoes
@onready var panel = $Panel

func _ready():
	panel.position = Vector2(10, 10)
	panel.custom_minimum_size = Vector2(260, 200)
	GerenciadorMissoes.missoes_atualizadas.connect(atualizar_painel)
	atualizar_painel()

func atualizar_painel():
	for filho in lista.get_children():
		filho.queue_free()

	var missoes = GerenciadorMissoes.get_missoes_ativas()

	if missoes.is_empty():
		var label = Label.new()
		label.text = "Nenhuma missão ativa"
		label.modulate = Color(0.6, 0.6, 0.6)
		label.add_theme_font_size_override("font_size", 18)
		lista.add_child(label)
		return

	var proxima = missoes[0]

	var lbl = Label.new()
	lbl.text = "○ " + proxima["texto"]
	lbl.modulate = Color(1.0, 0.85, 0.3)
	lbl.add_theme_font_size_override("font_size", 20)
	lista.add_child(lbl)

	for sub in proxima.get("sub_missoes", []):
		var lbl_sub = Label.new()
		if sub["concluida"]:
			lbl_sub.text = "  ✓ " + sub["texto"]
			lbl_sub.modulate = Color(0.5, 0.5, 0.5)
		else:
			lbl_sub.text = "  - " + sub["texto"]
			lbl_sub.modulate = Color(0.85, 0.85, 0.85)
		lbl_sub.add_theme_font_size_override("font_size", 18)
		lista.add_child(lbl_sub)
