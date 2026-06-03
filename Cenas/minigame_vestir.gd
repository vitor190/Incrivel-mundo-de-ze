extends CanvasLayer

signal finished(success: bool)

const SOM_ACERTO := preload("res://assets/assets - sons/u_3bsnvt0dsu-successed-295058.mp3")
const SOM_ERRO := preload("res://assets/assets - sons/lesiakower-error-mistake-sound-effect-incorrect-answer-437420.mp3")

const SEQUENCE_LEN := 5
const WRONG_PENALTY := 2.0
const XP_REWARD := 10.0

const ROUNDS := [
	{"glyph_time": 0.5, "label": "Difícil"},
	{"glyph_time": 1.0, "label": "Médio"},
	{"glyph_time": 2.0, "label": "Fácil"},
]

const DIRS := ["up", "down", "left", "right"]

const GLYPH := {
	"up": "↑",
	"down": "↓",
	"left": "←",
	"right": "→",
}

const HIDDEN_GLYPH := "?"

const COLOR_CURRENT := Color(1.0, 0.93, 0.45)
const COLOR_HIDDEN := Color(0.7, 0.7, 0.7)
const COLOR_DONE := Color(0.45, 0.95, 0.45)

enum Phase { INTRO, SHOW, INPUT, RESULT }

@onready var intro: Control = $Intro
@onready var qte_ui: Control = $QteUI
@onready var result_ui: Control = $Result
@onready var slot_row: HBoxContainer = $QteUI/SlotRow
@onready var attempt_label: Label = $QteUI/AttemptLabel
@onready var difficulty_label: Label = $QteUI/DifficultyLabel
@onready var status_label: Label = $QteUI/StatusLabel
@onready var hint_label: Label = $QteUI/HintLabel
@onready var result_title: Label = $Result/MarginContainer/VBox/ResultTitle
@onready var result_body: Label = $Result/MarginContainer/VBox/ResultBody
@onready var result_hint: Label = $Result/MarginContainer/VBox/ResultHint

var phase: int = Phase.INTRO
var round_idx: int = 0
var sequence: Array[String] = []
var progress: int = 0
var total_penalty: float = 0.0
var success: bool = false
var result_is_final: bool = false


func _ready() -> void:
	intro.visible = true
	qte_ui.visible = false
	result_ui.visible = false
	randomize()


func tocar_som(stream: AudioStream) -> void:
	var audio := AudioStreamPlayer.new()

	add_child(audio)

	audio.stream = stream
	audio.volume_db = -19

	audio.play()

	audio.finished.connect(audio.queue_free)


func _unhandled_input(event: InputEvent) -> void:
	match phase:
		Phase.INTRO:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				_start_round()

		Phase.SHOW:
			pass

		Phase.INPUT:
			var dir := _event_to_dir(event)

			if dir == "":
				return

			get_viewport().set_input_as_handled()
			_on_qte_key(dir)

		Phase.RESULT:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()

				if result_is_final:
					finished.emit(success)
					queue_free()
				else:
					_start_round()


func _is_confirm(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_SPACE or event.keycode == KEY_ENTER

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true

	return false


func _event_to_dir(event: InputEvent) -> String:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return ""

	match event.keycode:
		KEY_UP, KEY_W:
			return "up"

		KEY_DOWN, KEY_S:
			return "down"

		KEY_LEFT, KEY_A:
			return "left"

		KEY_RIGHT, KEY_D:
			return "right"

	return ""


func _start_round() -> void:
	intro.visible = false
	result_ui.visible = false
	qte_ui.visible = true

	sequence.clear()

	for i in SEQUENCE_LEN:
		sequence.append(DIRS[randi() % DIRS.size()])

	progress = 0
	status_label.text = ""

	attempt_label.text = "Tentativa %d / %d" % [round_idx + 1, ROUNDS.size()]
	difficulty_label.text = ROUNDS[round_idx].label

	_render_all_hidden()

	phase = Phase.SHOW
	hint_label.text = "Memorize a sequência…"

	await _reveal_sequence(float(ROUNDS[round_idx].glyph_time))

	if phase != Phase.SHOW:
		return

	_render_for_input()

	phase = Phase.INPUT
	hint_label.text = "Aperte a seta destacada em amarelo (setas ou WASD)"


func _render_all_hidden() -> void:
	for i in slot_row.get_child_count():
		var slot := slot_row.get_child(i) as Label

		if i >= sequence.size():
			slot.visible = false
			continue

		slot.visible = true
		slot.text = HIDDEN_GLYPH
		slot.modulate = COLOR_HIDDEN


func _reveal_sequence(glyph_time: float) -> void:
	for i in sequence.size():
		var slot := slot_row.get_child(i) as Label

		slot.text = GLYPH[sequence[i]]
		slot.modulate = COLOR_CURRENT

		await get_tree().create_timer(glyph_time).timeout

		if not is_instance_valid(self):
			return

		slot.text = HIDDEN_GLYPH
		slot.modulate = COLOR_HIDDEN


func _render_for_input() -> void:
	for i in slot_row.get_child_count():
		var slot := slot_row.get_child(i) as Label

		if i >= sequence.size():
			slot.visible = false
			continue

		slot.visible = true
		slot.text = HIDDEN_GLYPH

		if i == 0:
			slot.modulate = COLOR_CURRENT
		else:
			slot.modulate = COLOR_HIDDEN


func _on_qte_key(dir: String) -> void:
	if dir == sequence[progress]:
		var slot := slot_row.get_child(progress) as Label

		slot.text = GLYPH[dir]
		slot.modulate = COLOR_DONE

		progress += 1

		if progress >= sequence.size():
			_finish_success()
		else:
			var next_slot := slot_row.get_child(progress) as Label
			next_slot.modulate = COLOR_CURRENT

	else:
		_handle_wrong()


func _handle_wrong() -> void:
	# SOM DE ERRO
	tocar_som(SOM_ERRO)

	total_penalty += WRONG_PENALTY

	GameState.lose_xp(WRONG_PENALTY)

	round_idx += 1

	qte_ui.visible = false
	result_ui.visible = true
	phase = Phase.RESULT

	if round_idx >= ROUNDS.size():
		success = false
		result_is_final = true

		result_title.text = "Não vestiu a tempo…"
		result_title.modulate = Color(1.0, 0.4, 0.4)

		result_body.text = "Zé desistiu. Total perdido: −%d XP. Volte ao guarda-roupa pra tentar de novo." % int(total_penalty)

		result_hint.text = "[ESPAÇO para fechar]"

	else:
		result_is_final = false

		var nxt: Dictionary = ROUNDS[round_idx]

		result_title.text = "Errou! −%d XP" % int(WRONG_PENALTY)
		result_title.modulate = Color(1.0, 0.7, 0.3)

		result_body.text = "Próxima tentativa: %s — cada seta visível por %.1f s. Total perdido: −%d XP." % [
			nxt.label,
			float(nxt.glyph_time),
			int(total_penalty)
		]

		result_hint.text = "[ESPAÇO para tentar de novo]"


func _finish_success() -> void:
	# SOM DE ACERTO
	tocar_som(SOM_ACERTO)

	success = true
	result_is_final = true

	GameState.add_xp(XP_REWARD)
	GameState.set_dressed(true)

	qte_ui.visible = false
	result_ui.visible = true
	phase = Phase.RESULT

	result_title.text = "Pronto, vestido!"
	result_title.modulate = Color(0.4, 0.95, 0.4)

	if total_penalty > 0:
		result_body.text = "Zé vestiu o uniforme depois de %d tropeço(s). Ganhou +%d XP. Total perdido: −%d XP." % [
			int(total_penalty / WRONG_PENALTY),
			int(XP_REWARD),
			int(total_penalty)
		]
	else:
		result_body.text = "Zé vestiu o uniforme de primeira e ganhou +%d XP. Hora de ir pra aula." % int(XP_REWARD)

	result_hint.text = "[ESPAÇO para fechar o guarda-roupa]"
