extends CanvasLayer

signal finished(success: bool)

const SOM_ACERTO := preload("res://assets/assets - sons/u_3bsnvt0dsu-successed-295058.mp3")
const SOM_ERRO := preload("res://assets/assets - sons/lesiakower-error-mistake-sound-effect-incorrect-answer-437420.mp3")

const XP_HIT := 3.0
const XP_MISS := 2.0
const PASS_THRESHOLD := 3

const QUESTIONS := [
	{
		"q": "Qual estrutura repete um bloco enquanto uma condição é verdadeira?",
		"options": ["if", "for", "while", "switch"],
		"answer": 2,
		"explain": "while repete enquanto a condição permanecer verdadeira.",
	},
	{
		"q": "O que o operador % retorna entre dois inteiros?",
		"options": ["Quociente", "Resto da divisão", "Produto", "Diferença"],
		"answer": 1,
		"explain": "% é o módulo: retorna o resto da divisão inteira.",
	},
	{
		"q": "Em uma lista zero-indexed [10, 20, 30, 40], qual é lista[2]?",
		"options": ["10", "20", "30", "40"],
		"answer": 2,
		"explain": "Em listas zero-indexed o terceiro elemento (índice 2) é 30.",
	},
	{
		"q": "Qual operador lógico é verdadeiro APENAS se AMBOS os lados forem verdadeiros?",
		"options": ["OR", "AND", "NOT", "XOR"],
		"answer": 1,
		"explain": "AND exige que os dois operandos sejam verdadeiros.",
	},
	{
		"q": "Após este código, quanto vale x?\n\nx = 5\nif x > 3:\n    x = x * 2\nelse:\n    x = x + 1",
		"options": ["5", "6", "10", "15"],
		"answer": 2,
		"explain": "x=5 é maior que 3, então entra no if: 5 * 2 = 10.",
	},
]

enum Phase { INTRO, QUESTION, FEEDBACK, FINAL }

@onready var intro: Control = $Intro
@onready var quiz_ui: Control = $QuizUI
@onready var feedback_ui: Control = $Feedback
@onready var final_ui: Control = $Final

@onready var attempt_label: Label = $QuizUI/MarginContainer/VBox/AttemptLabel
@onready var question_label: Label = $QuizUI/MarginContainer/VBox/QuestionLabel

@onready var option_buttons: Array[Button] = [
	$QuizUI/MarginContainer/VBox/OptionA,
	$QuizUI/MarginContainer/VBox/OptionB,
	$QuizUI/MarginContainer/VBox/OptionC,
	$QuizUI/MarginContainer/VBox/OptionD,
]

@onready var feedback_title: Label = $Feedback/MarginContainer/VBox/Title
@onready var feedback_body: Label = $Feedback/MarginContainer/VBox/Body
@onready var feedback_hint: Label = $Feedback/MarginContainer/VBox/Hint

@onready var final_title: Label = $Final/MarginContainer/VBox/Title
@onready var final_body: Label = $Final/MarginContainer/VBox/Body
@onready var final_hint: Label = $Final/MarginContainer/VBox/Hint

var phase: int = Phase.INTRO
var idx: int = 0
var hits: int = 0
var total_gain: float = 0.0
var total_loss: float = 0.0


func _ready() -> void:
	intro.visible = true
	quiz_ui.visible = false
	feedback_ui.visible = false
	final_ui.visible = false

	for i in option_buttons.size():
		var btn: Button = option_buttons[i]
		btn.pressed.connect(_on_option_pressed.bind(i))


func tocar_som(stream: AudioStream) -> void:
	var audio := AudioStreamPlayer.new()
	add_child(audio)

	audio.stream = stream

	if stream == SOM_ERRO:
		audio.volume_db = -20
	else:
		audio.volume_db = -10

	audio.play()
	audio.finished.connect(audio.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	match phase:
		Phase.INTRO:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				_show_question()

		Phase.QUESTION:
			var n := _event_to_number(event)
			if n >= 0 and n < option_buttons.size():
				get_viewport().set_input_as_handled()
				_on_option_pressed(n)

		Phase.FEEDBACK:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				_advance_after_feedback()

		Phase.FINAL:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				finished.emit(hits >= PASS_THRESHOLD)
				queue_free()


func _is_confirm(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_SPACE or event.keycode == KEY_ENTER

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true

	return false


func _event_to_number(event: InputEvent) -> int:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return -1

	match event.keycode:
		KEY_1, KEY_KP_1:
			return 0
		KEY_2, KEY_KP_2:
			return 1
		KEY_3, KEY_KP_3:
			return 2
		KEY_4, KEY_KP_4:
			return 3

	return -1


func _show_question() -> void:
	intro.visible = false
	feedback_ui.visible = false
	final_ui.visible = false
	quiz_ui.visible = true

	var q: Dictionary = QUESTIONS[idx]
	attempt_label.text = "Questão %d / %d" % [idx + 1, QUESTIONS.size()]
	question_label.text = q.q

	var letters: Array = ["A", "B", "C", "D"]

	for i in option_buttons.size():
		var btn: Button = option_buttons[i]
		btn.text = "%s) %s" % [letters[i], q.options[i]]
		btn.disabled = false

	phase = Phase.QUESTION


func _on_option_pressed(choice: int) -> void:
	if phase != Phase.QUESTION:
		return

	for btn in option_buttons:
		btn.disabled = true

	var q: Dictionary = QUESTIONS[idx]
	var correct: bool = choice == int(q.answer)

	quiz_ui.visible = false
	feedback_ui.visible = true
	phase = Phase.FEEDBACK

	if correct:
		tocar_som(SOM_ACERTO)

		hits += 1
		total_gain += XP_HIT
		GameState.add_xp(XP_HIT)

		feedback_title.text = "Correto! +%d XP" % int(XP_HIT)
		feedback_title.modulate = Color(0.4, 0.95, 0.4)
	else:
		tocar_som(SOM_ERRO)

		total_loss += XP_MISS
		GameState.lose_xp(XP_MISS)

		var letters: Array = ["A", "B", "C", "D"]

		feedback_title.text = "Errado! -%d XP (resposta: %s)" % [
			int(XP_MISS),
			letters[int(q.answer)]
		]

		feedback_title.modulate = Color(1.0, 0.5, 0.4)

	feedback_body.text = q.explain
	feedback_hint.text = "[ESPAÇO para continuar]"


func _advance_after_feedback() -> void:
	idx += 1

	if idx >= QUESTIONS.size():
		_show_final()
	else:
		_show_question()


func _show_final() -> void:
	feedback_ui.visible = false
	quiz_ui.visible = false
	final_ui.visible = true
	phase = Phase.FINAL

	var passed: bool = hits >= PASS_THRESHOLD

	if passed:
		final_title.text = "Aprovado: %d / %d" % [hits, QUESTIONS.size()]
		final_title.modulate = Color(0.4, 0.95, 0.4)
	else:
		final_title.text = "Reprovado: %d / %d" % [hits, QUESTIONS.size()]
		final_title.modulate = Color(1.0, 0.5, 0.4)

	final_body.text = "Ganhou +%d XP, perdeu -%d XP. Saldo: %+d XP." % [
		int(total_gain),
		int(total_loss),
		int(total_gain - total_loss)
	]

	final_hint.text = "[ESPAÇO para fechar]"
