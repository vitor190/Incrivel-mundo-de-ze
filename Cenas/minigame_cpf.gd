extends CanvasLayer

signal finished(success: bool)

const SOM_ACERTO := preload("res://assets/assets - sons/u_3bsnvt0dsu-successed-295058.mp3")
const SOM_ERRO := preload("res://assets/assets - sons/lesiakower-error-mistake-sound-effect-incorrect-answer-437420.mp3")

const XP_VITORIA := 20.0
const PENALIDADE_DICA := 10.0
const XP_ERRO := 2.0
const MAX_TENTATIVAS := 3

# Dados do desafio: a lista de CPFs do banco e o cliente a verificar.
const LISTA_CPFS := [
	"111.111.111-11",
	"222.222.222-22",
	"333.333.333-33",
	"444.444.444-44",
]
const CPF_CLIENTE := "333.333.333-33"

const DICA := "function verificarCPF(lista, cpf_cliente) {\n  for (let i = 0; i < lista.length; i++) {\n    if (lista[i] === cpf_cliente) {\n      return true;\n    }\n  }\n  return false;\n}"

enum Phase { INTRO, BUILD, FINAL }

@onready var intro: Control = $Intro
@onready var game_ui: Control = $GameUI
@onready var final_ui: Control = $Final

@onready var contexto_label: Label = $GameUI/MarginContainer/VBox/Contexto
@onready var editor: TextEdit = $GameUI/MarginContainer/VBox/Editor
@onready var btn_executar: Button = $GameUI/MarginContainer/VBox/Controles/BtnExecutar
@onready var btn_limpar: Button = $GameUI/MarginContainer/VBox/Controles/BtnLimpar
@onready var btn_dica: Button = $GameUI/MarginContainer/VBox/Controles/BtnDica
@onready var dica_label: Label = $GameUI/MarginContainer/VBox/Dica
@onready var feedback_label: Label = $GameUI/MarginContainer/VBox/Feedback
@onready var tentativas_label: Label = $GameUI/MarginContainer/VBox/Tentativas
@onready var confirmacao_dica: ConfirmationDialog = $ConfirmacaoDica

@onready var final_title: Label = $Final/MarginContainer/VBox/Title
@onready var final_body: Label = $Final/MarginContainer/VBox/Body
@onready var final_hint: Label = $Final/MarginContainer/VBox/Hint

var phase: int = Phase.INTRO
var tentativas: int = 0
var venceu: bool = false
var dica_usada: bool = false


func _ready() -> void:
	intro.visible = true
	game_ui.visible = false
	final_ui.visible = false
	dica_label.visible = false

	var lista_txt := ""
	for i in LISTA_CPFS.size():
		if i > 0:
			lista_txt += ", "
		lista_txt += "\"%s\"" % LISTA_CPFS[i]

	contexto_label.text = "// Banco do Nordeste — sistema de cadastro\nconst lista = [%s];\nlet cpf_cliente = \"%s\";\n\nEscreva a função verificarCPF(lista, cpf_cliente) que percorre\na lista e retorna true se o CPF estiver cadastrado, senão false." % [lista_txt, CPF_CLIENTE]

	editor.placeholder_text = "function verificarCPF(lista, cpf_cliente) {\n  // escreva o laço e a comparação aqui\n}"
	dica_label.text = "Estrutura esperada:\n" + DICA

	btn_executar.pressed.connect(_on_executar)
	btn_limpar.pressed.connect(_limpar)
	btn_dica.pressed.connect(_on_dica_pressed)

	confirmacao_dica.dialog_text = "Ver a dica reduz a recompensa de %d XP para %d XP. Confirmar?" % [int(XP_VITORIA), int(XP_VITORIA - PENALIDADE_DICA)]
	confirmacao_dica.ok_button_text = "Usar dica (-%d XP)" % int(PENALIDADE_DICA)
	confirmacao_dica.confirmed.connect(_confirmar_dica)


func tocar_som(stream: AudioStream) -> void:
	var audio := AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = stream
	audio.volume_db = -20 if stream == SOM_ERRO else -10
	audio.play()
	audio.finished.connect(audio.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	match phase:
		Phase.INTRO:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				_iniciar_build()
		Phase.FINAL:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				finished.emit(venceu)
				queue_free()

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if phase == Phase.BUILD:
			get_viewport().set_input_as_handled()
			_mostrar_final(false, "Você desistiu da tarefa.")


func _is_confirm(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_SPACE or event.keycode == KEY_ENTER
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true
	return false


func _iniciar_build() -> void:
	intro.visible = false
	final_ui.visible = false
	game_ui.visible = true
	phase = Phase.BUILD
	tentativas = 0
	_limpar()
	_atualizar_tentativas()
	await get_tree().process_frame
	editor.grab_focus()


func _limpar() -> void:
	editor.text = ""
	feedback_label.text = ""


func _on_dica_pressed() -> void:
	if dica_usada:
		# Já pagou pela dica: pode esconder/mostrar à vontade.
		dica_label.visible = not dica_label.visible
	else:
		confirmacao_dica.popup_centered()


func _confirmar_dica() -> void:
	dica_usada = true
	dica_label.visible = true
	btn_dica.text = "Dica (-%d XP)" % int(PENALIDADE_DICA)


func _atualizar_tentativas() -> void:
	tentativas_label.text = "Tentativas: %d / %d" % [tentativas, MAX_TENTATIVAS]


func _normalizar(s: String) -> String:
	var n := s.to_lower()
	for ch in [" ", "\t", "\n", "\r"]:
		n = n.replace(ch, "")
	return n


# Valida o código escrito procurando os elementos lógicos obrigatórios.
func _validar(codigo: String) -> Dictionary:
	var n := _normalizar(codigo)

	if n == "":
		return {"ok": false, "erro": "Escreva o código antes de executar."}

	var re_loop := RegEx.new()
	re_loop.compile("for\\([^)]*lista\\.length[^)]*\\)")
	if re_loop.search(n) == null:
		return {"ok": false, "erro": "Faltou um laço 'for' percorrendo a lista (use lista.length)."}

	var re_cmp := RegEx.new()
	re_cmp.compile("(lista\\[\\w+\\]===?cpf_cliente|cpf_cliente===?lista\\[\\w+\\])")
	if re_cmp.search(n) == null:
		return {"ok": false, "erro": "Compare lista[i] com cpf_cliente usando == ."}

	if n.find("returntrue") == -1:
		return {"ok": false, "erro": "Quando achar o CPF, faça 'return true'."}

	if n.find("returnfalse") == -1:
		return {"ok": false, "erro": "Se não achar, faça 'return false' no fim."}

	if n.find("returntrue") > n.rfind("returnfalse"):
		return {"ok": false, "erro": "Ordem errada: 'return false' deve vir depois do laço."}

	return {"ok": true, "erro": ""}


func _on_executar() -> void:
	if phase != Phase.BUILD:
		return

	var r := _validar(editor.text)

	if r["ok"]:
		tocar_som(SOM_ACERTO)
		_mostrar_final(true, "Seu código rodou e encontrou o cliente!\n\nverificarCPF(lista, \"%s\") => true" % CPF_CLIENTE)
		return

	tocar_som(SOM_ERRO)
	tentativas += 1
	GameState.lose_xp(XP_ERRO)
	_atualizar_tentativas()

	if tentativas >= MAX_TENTATIVAS:
		_mostrar_final(false, "O sistema travou! " + str(r["erro"]))
		return

	feedback_label.modulate = Color(1.0, 0.5, 0.4)
	feedback_label.text = "✗ %s  (-%d XP)" % [str(r["erro"]), int(XP_ERRO)]
	editor.grab_focus()


func _mostrar_final(sucesso: bool, mensagem: String) -> void:
	venceu = sucesso
	game_ui.visible = false
	final_ui.visible = true
	phase = Phase.FINAL

	if sucesso:
		var ganho := XP_VITORIA - (PENALIDADE_DICA if dica_usada else 0.0)
		GameState.add_xp(ganho)
		if dica_usada:
			final_title.text = "CPF verificado! +%d XP (dica: -%d)" % [int(ganho), int(PENALIDADE_DICA)]
		else:
			final_title.text = "CPF verificado! +%d XP" % int(ganho)
		final_title.modulate = Color(0.4, 0.95, 0.4)
	else:
		final_title.text = "Tarefa falhada"
		final_title.modulate = Color(1.0, 0.5, 0.4)

	final_body.text = mensagem
	final_hint.text = "[ESPAÇO para fechar]"
