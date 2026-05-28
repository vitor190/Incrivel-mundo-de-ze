extends CanvasLayer

signal finished(woke_on_time: bool)

const ROUNDS := [
	{"target": 0.10, "speed": 1.6, "penalty": 3.0},
	{"target": 0.20, "speed": 1.1, "penalty": 5.0},
	{"target": 0.32, "speed": 0.8, "penalty": 8.0},
]

const XP_REWARD := 10.0
const BAR_WIDTH := 360.0
const POINTER_WIDTH := 24.0

@onready var intro: Control = $Intro
@onready var bar_ui: Control = $BarUI
@onready var result_ui: Control = $Result
@onready var pointer: TextureRect = $BarUI/Bar/Pointer
@onready var target_zone: ColorRect = $BarUI/Bar/TargetZone
@onready var attempt_label: Label = $BarUI/AttemptLabel
@onready var difficulty_label: Label = $BarUI/DifficultyLabel
@onready var result_title: Label = $Result/MarginContainer/VBox/ResultTitle
@onready var result_body: Label = $Result/MarginContainer/VBox/ResultBody
@onready var result_hint: Label = $Result/MarginContainer/VBox/ResultHint

enum Phase { INTRO, BAR, RESULT }

var phase: int = Phase.INTRO
var round_idx: int = 0
var pointer_t: float = 0.0
var dir: float = 1.0
var bar_active: bool = false
var hit_this_run: bool = false
var total_penalty: float = 0.0

func _ready() -> void:
	intro.visible = true
	bar_ui.visible = false
	result_ui.visible = false


func _process(delta: float) -> void:
	if not bar_active:
		return

	pointer_t += delta * float(ROUNDS[round_idx].speed) * dir

	if pointer_t >= 1.0:
		pointer_t = 1.0
		dir = -1.0
	elif pointer_t <= 0.0:
		pointer_t = 0.0
		dir = 1.0

	pointer.position.x = pointer_t * (BAR_WIDTH - POINTER_WIDTH)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_action_press(event):
		return

	get_viewport().set_input_as_handled()

	match phase:
		Phase.INTRO:
			_start_round()
		Phase.BAR:
			_check_hit()
		Phase.RESULT:
			_advance_after_result()


func _is_action_press(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return true

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true

	return false


func _start_round() -> void:
	intro.visible = false
	result_ui.visible = false
	bar_ui.visible = true

	var r: Dictionary = ROUNDS[round_idx]
	var t_size: float = BAR_WIDTH * float(r.target)

	target_zone.size = Vector2(t_size, target_zone.size.y)
	target_zone.position = Vector2((BAR_WIDTH - t_size) * 0.5, target_zone.position.y)

	attempt_label.text = "Tentativa %d / 3" % (round_idx + 1)

	var labels := ["Difícil", "Médio", "Fácil"]
	difficulty_label.text = labels[round_idx]

	pointer_t = 0.0
	dir = 1.0
	bar_active = true
	phase = Phase.BAR


func _check_hit() -> void:
	bar_active = false

	var p_center: float = pointer.position.x + POINTER_WIDTH * 0.5
	var z_left: float = target_zone.position.x
	var z_right: float = z_left + target_zone.size.x
	var hit: bool = p_center >= z_left and p_center <= z_right

	bar_ui.visible = false
	result_ui.visible = true
	phase = Phase.RESULT

	if hit:
		hit_this_run = true

		GameState.add_xp(XP_REWARD)

		result_title.text = "Acordou na hora!"
		result_title.modulate = Color(0.4, 0.95, 0.4)

		if total_penalty > 0:
			result_body.text = "Zé pegou o ritmo. Ganhou +%d XP. Total perdido: -%d XP." % [int(XP_REWARD), int(total_penalty)]
		else:
			result_body.text = "Zé acordou pontualmente e ganhou +%d XP." % int(XP_REWARD)

		result_hint.text = "[ESPAÇO para sair da cama]"
	else:
		var pen: float = float(ROUNDS[round_idx].penalty)
		total_penalty += pen

		GameState.lose_xp(pen)

		round_idx += 1

		if round_idx >= ROUNDS.size():
			result_title.text = "Acordou bem tarde…"
			result_title.modulate = Color(1.0, 0.4, 0.4)
			result_body.text = "Sem mais chances. Total perdido: -%d XP." % int(total_penalty)
			result_hint.text = "[ESPAÇO para sair da cama]"
		else:
			result_title.text = "Errou! -%d XP" % int(pen)
			result_title.modulate = Color(1.0, 0.7, 0.3)
			result_body.text = "Próxima tentativa é mais fácil. (-%d XP no total)" % int(total_penalty)
			result_hint.text = "[ESPAÇO para tentar de novo]"


func _advance_after_result() -> void:
	if hit_this_run or round_idx >= ROUNDS.size():
		finished.emit(hit_this_run)
		queue_free()
	else:
		_start_round()
