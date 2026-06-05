extends CanvasLayer

signal finished(success: bool)

const SOM_OK := preload("res://assets/assets - sons/u_3bsnvt0dsu-successed-295058.mp3")
const SOM_ERRO := preload("res://assets/assets - sons/lesiakower-error-mistake-sound-effect-incorrect-answer-437420.mp3")

const META := 5                  # carneirinhos a ajudar antes de dormir
const XP_POR_OBSTACULO := 2.0
const XP_PENALIDADE := 2.0       # bateu num obstáculo: a task vale 2 XP a menos

const GROUND_Y := 56.0           # ovelha.position.y no chão
const JUMP_Y := 12.0             # ovelha.position.y no topo do pulo
const VEL_INICIAL := 200.0       # velocidade inicial do obstáculo (px/s)
const VEL_INCREMENTO := 32.0     # acelera a cada carneirinho ajudado
const SPAWN_X := 560.0
const DESPAWN_X := 40.0

enum Phase { INTRO, JOGO, FINAL }

@onready var intro: Control = $Intro
@onready var game_ui: Control = $GameUI
@onready var final_ui: Control = $Final

@onready var contador: Label = $GameUI/MarginContainer/VBox/Contador
@onready var aviso: Label = $GameUI/MarginContainer/VBox/Aviso
@onready var ovelha: Control = $GameUI/MarginContainer/VBox/Campo/Ovelha
@onready var obstaculo: Control = $GameUI/MarginContainer/VBox/Campo/Obstaculo

@onready var final_body: Label = $Final/MarginContainer/VBox/Body

var phase: int = Phase.INTRO
var desviados: int = 0
var no_chao: bool = true
var contou_atual: bool = false
var jump_tween: Tween
var ovelha_x: float = 0.0
var vel_atual: float = VEL_INICIAL


func _ready() -> void:
	intro.visible = true
	game_ui.visible = false
	final_ui.visible = false
	set_process(false)


func _unhandled_input(event: InputEvent) -> void:
	match phase:
		Phase.INTRO:
			if _confirm(event):
				get_viewport().set_input_as_handled()
				_iniciar()
		Phase.JOGO:
			if _confirm(event):
				get_viewport().set_input_as_handled()
				_pular()
		Phase.FINAL:
			if _confirm(event):
				get_viewport().set_input_as_handled()
				finished.emit(true)
				queue_free()

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if phase != Phase.FINAL:
			get_viewport().set_input_as_handled()
			finished.emit(false)
			queue_free()


func _confirm(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_UP or event.keycode == KEY_W
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return true
	return false


func _iniciar() -> void:
	intro.visible = false
	game_ui.visible = true
	phase = Phase.JOGO

	desviados = 0
	no_chao = true
	contou_atual = false
	vel_atual = VEL_INICIAL

	ovelha_x = ovelha.position.x
	ovelha.position.y = GROUND_Y
	obstaculo.position.x = SPAWN_X

	aviso.text = "Ajude os carneirinhos a pular!"
	_atualizar()
	set_process(true)


func _process(delta: float) -> void:
	if phase != Phase.JOGO:
		return

	obstaculo.position.x -= vel_atual * delta

	# Bateu no obstáculo (no chão e sobrepondo a ovelha).
	if no_chao and _colide():
		_bateu()
		return

	# Passou completamente pela ovelha sem bater: desviou.
	if not contou_atual and obstaculo.position.x + obstaculo.size.x < ovelha_x:
		contou_atual = true
		_desviou()

	# Saiu da tela: gera o próximo.
	if obstaculo.position.x < DESPAWN_X:
		_respawn()


func _colide() -> bool:
	var ox := obstaculo.position.x
	var ow := obstaculo.size.x
	var ow_ovelha := ovelha.size.x
	return ox < ovelha_x + ow_ovelha and ox + ow > ovelha_x


func _pular() -> void:
	if not no_chao:
		return

	no_chao = false

	if jump_tween and jump_tween.is_valid():
		jump_tween.kill()

	jump_tween = create_tween()
	jump_tween.tween_property(ovelha, "position:y", JUMP_Y, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(ovelha, "position:y", GROUND_Y, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	jump_tween.tween_callback(func(): no_chao = true)


func _desviou() -> void:
	desviados += 1
	GameState.add_xp(XP_POR_OBSTACULO)
	_tocar(SOM_OK)

	# Cada carneirinho ajudado deixa o próximo obstáculo mais rápido.
	vel_atual += VEL_INCREMENTO

	aviso.modulate = Color(0.7, 1.0, 0.7)
	aviso.text = "+1 carneirinho contado! (%d)" % desviados
	_atualizar()

	if desviados >= META:
		_dormir()


func _bateu() -> void:
	_tocar(SOM_ERRO)
	GameState.lose_xp(XP_PENALIDADE)

	aviso.modulate = Color(1.0, 0.55, 0.45)
	aviso.text = "O carneirinho tropeçou! -%d XP" % int(XP_PENALIDADE)

	_respawn()


func _respawn() -> void:
	# Reaparece à direita com um pequeno espaçamento aleatório.
	obstaculo.position.x = SPAWN_X + randf_range(0.0, 120.0)
	contou_atual = false


func _atualizar() -> void:
	contador.text = "Carneirinhos ajudados: %d / %d" % [desviados, META]


func _dormir() -> void:
	phase = Phase.FINAL
	set_process(false)
	game_ui.visible = false
	final_ui.visible = true
	final_body.text = "Você ajudou %d carneirinhos a pular e pegou no sono.\nGanhou XP por cada um (e perdeu 2 a cada tropeço)." % META


func _tocar(stream: AudioStream) -> void:
	var audio := AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = stream
	audio.volume_db = -14 if stream == SOM_ERRO else -12
	audio.play()
	audio.finished.connect(audio.queue_free)
