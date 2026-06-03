extends CanvasLayer

signal finished(success: bool)

const SOM_ACERTO := preload("res://assets/assets - sons/u_3bsnvt0dsu-successed-295058.mp3")
const SOM_ERRO := preload("res://assets/assets - sons/lesiakower-error-mistake-sound-effect-incorrect-answer-437420.mp3")

const XP_HIT := 10.0
const XP_MISS := 4.0
const TOLERANCE := 25
const ROUND_COUNT := 3

const TARGETS := [
	Color8(220, 60, 60),
	Color8(80, 200, 120),
	Color8(255, 200, 30),
]

enum Phase { INTRO, MIX, FEEDBACK, FINAL }

@onready var intro: Control = $Intro
@onready var mix_ui: Control = $MixUI
@onready var feedback_ui: Control = $Feedback
@onready var final_ui: Control = $Final

@onready var attempt_label: Label = $MixUI/MarginContainer/VBox/AttemptLabel
@onready var target_swatch: ColorRect = $MixUI/MarginContainer/VBox/Swatches/Target/TargetRect
@onready var current_swatch: ColorRect = $MixUI/MarginContainer/VBox/Swatches/Current/CurrentRect
@onready var target_rgb_label: Label = $MixUI/MarginContainer/VBox/Swatches/Target/TargetRgb
@onready var current_rgb_label: Label = $MixUI/MarginContainer/VBox/Swatches/Current/CurrentRgb

@onready var r_slider: HSlider = $MixUI/MarginContainer/VBox/SliderR/Slider
@onready var g_slider: HSlider = $MixUI/MarginContainer/VBox/SliderG/Slider
@onready var b_slider: HSlider = $MixUI/MarginContainer/VBox/SliderB/Slider

@onready var r_value: Label = $MixUI/MarginContainer/VBox/SliderR/Value
@onready var g_value: Label = $MixUI/MarginContainer/VBox/SliderG/Value
@onready var b_value: Label = $MixUI/MarginContainer/VBox/SliderB/Value

@onready var submit_btn: Button = $MixUI/MarginContainer/VBox/Submit

@onready var feedback_title: Label = $Feedback/MarginContainer/VBox/Title
@onready var feedback_body: Label = $Feedback/MarginContainer/VBox/Body
@onready var feedback_hint: Label = $Feedback/MarginContainer/VBox/Hint

@onready var final_title: Label = $Final/MarginContainer/VBox/Title
@onready var final_body: Label = $Final/MarginContainer/VBox/Body
@onready var final_hint: Label = $Final/MarginContainer/VBox/Hint

var phase: int = Phase.INTRO
var round_idx: int = 0
var hits: int = 0
var total_gain: float = 0.0
var total_loss: float = 0.0
var target: Color = Color.WHITE


func _ready() -> void:
	intro.visible = true
	mix_ui.visible = false
	feedback_ui.visible = false
	final_ui.visible = false

	for s in [r_slider, g_slider, b_slider]:
		s.min_value = 0
		s.max_value = 255
		s.step = 1
		s.value = 0
		s.value_changed.connect(_on_slider_changed)

	submit_btn.pressed.connect(_on_submit)


func tocar_som(stream: AudioStream) -> void:
	var audio := AudioStreamPlayer.new()

	add_child(audio)

	audio.stream = stream

	# ERRO MAIS BAIXO
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
				_start_round()

		Phase.FEEDBACK:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()
				_advance_after_feedback()

		Phase.FINAL:
			if _is_confirm(event):
				get_viewport().set_input_as_handled()

				finished.emit(hits >= 1)
				queue_free()


func _is_confirm(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_SPACE or event.keycode == KEY_ENTER

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true

	return false


func _start_round() -> void:
	intro.visible = false
	feedback_ui.visible = false
	final_ui.visible = false
	mix_ui.visible = true

	target = TARGETS[round_idx]

	target_swatch.color = target

	target_rgb_label.text = "Alvo: (%d, %d, %d)" % [
		_c8(target.r),
		_c8(target.g),
		_c8(target.b)
	]

	r_slider.value = 128
	g_slider.value = 128
	b_slider.value = 128

	_update_current()

	attempt_label.text = "Tentativa %d / %d" % [
		round_idx + 1,
		ROUND_COUNT
	]

	phase = Phase.MIX


func _on_slider_changed(_v: float) -> void:
	if phase != Phase.MIX:
		return

	_update_current()


func _update_current() -> void:
	var r := int(r_slider.value)
	var g := int(g_slider.value)
	var b := int(b_slider.value)

	current_swatch.color = Color8(r, g, b)

	current_rgb_label.text = "Atual: (%d, %d, %d)" % [r, g, b]

	r_value.text = "R: %d" % r
	g_value.text = "G: %d" % g
	b_value.text = "B: %d" % b


func _on_submit() -> void:
	if phase != Phase.MIX:
		return

	var dr: int = absi(int(r_slider.value) - _c8(target.r))
	var dg: int = absi(int(g_slider.value) - _c8(target.g))
	var db: int = absi(int(b_slider.value) - _c8(target.b))

	var max_diff: int = maxi(dr, maxi(dg, db))

	var hit: bool = max_diff <= TOLERANCE

	mix_ui.visible = false
	feedback_ui.visible = true
	phase = Phase.FEEDBACK

	if hit:
		tocar_som(SOM_ACERTO)

		hits += 1
		total_gain += XP_HIT

		GameState.add_xp(XP_HIT)

		feedback_title.text = "Acertou! +%d XP" % int(XP_HIT)
		feedback_title.modulate = Color(0.4, 0.95, 0.4)

	else:
		tocar_som(SOM_ERRO)

		total_loss += XP_MISS

		GameState.lose_xp(XP_MISS)

		feedback_title.text = "Errou! -%d XP" % int(XP_MISS)
		feedback_title.modulate = Color(1.0, 0.5, 0.4)

	feedback_body.text = "Diferenças por canal — R: %d, G: %d, B: %d. Tolerância: %d." % [
		dr,
		dg,
		db,
		TOLERANCE
	]

	feedback_hint.text = "[ESPAÇO para continuar]"


func _advance_after_feedback() -> void:
	round_idx += 1

	if round_idx >= ROUND_COUNT:
		_show_final()
	else:
		_start_round()


func _show_final() -> void:
	mix_ui.visible = false
	feedback_ui.visible = false
	final_ui.visible = true

	phase = Phase.FINAL

	if hits >= 1:
		final_title.text = "Trabalho aceito: %d / %d" % [
			hits,
			ROUND_COUNT
		]

		final_title.modulate = Color(0.4, 0.95, 0.4)

	else:
		final_title.text = "Trabalho recusado: %d / %d" % [
			hits,
			ROUND_COUNT
		]

		final_title.modulate = Color(1.0, 0.5, 0.4)

	final_body.text = "Ganhou +%d XP, perdeu -%d XP. Saldo: %+d XP." % [
		int(total_gain),
		int(total_loss),
		int(total_gain - total_loss)
	]

	final_hint.text = "[ESPAÇO para fechar]"


func _c8(channel: float) -> int:
	return int(round(channel * 255.0))
