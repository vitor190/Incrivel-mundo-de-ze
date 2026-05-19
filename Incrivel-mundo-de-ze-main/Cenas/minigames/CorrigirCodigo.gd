extends CanvasLayer

signal minigame_concluido(sucesso: bool, xp_ganho: int)

const TEMPO_TOTAL := 60.0
const PENALIDADE_ERRO := 2.0
const XP_VITORIA := 30

var linhas_codigo: Array = [
	"extends Node",
	"var energia = 100",
	"var tarefa_pronta = false",
	"func estudar():",
	"energia -= 10",
	"tarefa_pronta = true",
	"print(\"Tarefa concluida\")"
]

var linha_atual := 0
var tempo_restante: float = TEMPO_TOTAL
var jogo_ativo := false
var erros_totais := 0

# Nós da UI — vamos criar eles no Passo 3
@onready var painel_intro = $Painel/Centro/VBox/PainelIntro
@onready var painel_jogo = $Painel/Centro/VBox/PainelJogo
@onready var painel_resultado = $Painel/Centro/VBox/PainelResultado
@onready var lbl_tempo = $Painel/Centro/VBox/PainelJogo/VBox/HBoxStatus/LblTempo
@onready var lbl_progresso = $Painel/Centro/VBox/PainelJogo/VBox/HBoxStatus/LblProgresso
@onready var rtl_codigo_feito = $Painel/Centro/VBox/PainelJogo/VBox/RtlCodigoFeito
@onready var lbl_proxima = $Painel/Centro/VBox/PainelJogo/VBox/LblProxima
@onready var le_input = $Painel/Centro/VBox/PainelJogo/VBox/LeInput
@onready var lbl_feedback = $Painel/Centro/VBox/PainelJogo/VBox/LblFeedback
@onready var lbl_resultado = $Painel/Centro/VBox/PainelResultado/LblResultado

func _ready():
	visible = false

func _process(delta):
	if not jogo_ativo:
		return
	tempo_restante -= delta
	_atualizar_hud()
	if tempo_restante <= 0:
		_fim_jogo(false)

func abrir():
	visible = true
	_mostrar_intro()

func _mostrar_intro():
	jogo_ativo = false
	painel_intro.visible = true
	painel_jogo.visible = false
	painel_resultado.visible = false

func _iniciar_jogo():
	linha_atual = 0
	tempo_restante = TEMPO_TOTAL
	erros_totais = 0
	jogo_ativo = true
	rtl_codigo_feito.text = ""
	lbl_feedback.text = ""
	le_input.text = ""
	painel_intro.visible = false
	painel_jogo.visible = true
	painel_resultado.visible = false
	_atualizar_proxima()
	_atualizar_hud()
	le_input.grab_focus()

func _on_le_input_text_submitted(texto: String):
	if not jogo_ativo:
		return
	le_input.text = ""
	if _normalizar(texto) == _normalizar(linhas_codigo[linha_atual]):
		rtl_codigo_feito.text += "[color=#7ec8e3]" + linhas_codigo[linha_atual].xml_escape() + "[/color]\n"
		lbl_feedback.text = "✓ Correto!"
		lbl_feedback.modulate = Color.GREEN
		linha_atual += 1
		if linha_atual >= linhas_codigo.size():
			_fim_jogo(true)
		else:
			_atualizar_proxima()
	else:
		tempo_restante = max(tempo_restante - PENALIDADE_ERRO, 0)
		erros_totais += 1
		lbl_feedback.text = "✗ Errado! -2 segundos"
		lbl_feedback.modulate = Color.TOMATO

func _fim_jogo(vitoria: bool):
	jogo_ativo = false
	painel_jogo.visible = false
	painel_resultado.visible = true
	if vitoria:
		lbl_resultado.text = "✅ Código corrigido!\n\n+%d XP\n\nErros: %d | Tempo restante: %.1fs\n\n[ Pressione ESPAÇO ou ESC para fechar ]" % [XP_VITORIA, erros_totais, max(tempo_restante, 0)]
	else:
		lbl_resultado.text = "❌ Tempo esgotado!\n\nVocê completou %d / %d linhas.\n\n[ Pressione ESPAÇO ou ESC para fechar ]" % [linha_atual, linhas_codigo.size()]
	emit_signal("minigame_concluido", vitoria, XP_VITORIA if vitoria else 0)

func _atualizar_proxima():
	lbl_proxima.text = linhas_codigo[linha_atual]
	lbl_feedback.text = ""

func _atualizar_hud():
	lbl_tempo.text = "⏱ %.1fs" % max(tempo_restante, 0)
	lbl_progresso.text = "Linha %d/%d" % [linha_atual + 1, linhas_codigo.size()]
	if tempo_restante <= 10:
		lbl_tempo.modulate = Color.TOMATO
	elif tempo_restante <= 20:
		lbl_tempo.modulate = Color.YELLOW
	else:
		lbl_tempo.modulate = Color.WHITE

func _normalizar(s: String) -> String:
	var r = s.strip_edges().to_lower()
	for par in [["á","a"],["à","a"],["ã","a"],["â","a"],["é","e"],["ê","e"],["í","i"],["ó","o"],["ô","o"],["õ","o"],["ú","u"],["ç","c"]]:
		r = r.replace(par[0], par[1])
	return r

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		jogo_ativo = false
		visible = false
		emit_signal("minigame_concluido", false, 0)
		return
	if event.is_action_pressed("ui_accept"):
		if painel_intro.visible:
			_iniciar_jogo()
		elif painel_resultado.visible:
			visible = false
