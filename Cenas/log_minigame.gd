extends CanvasLayer

signal minigame_concluido(sucesso: bool, xp_ganho: int)

const TOTAL_ERRORS : int   = 5
const SCROLL_TIME  : float = 2.0
const MAX_LINES    : int   = 12
const XP_VITORIA   : int   = 20

@onready var painel_intro   = $Painel/Centro/VBox/PainelIntro
@onready var painel_jogo    = $Painel/Centro/VBox/PainelJogo
@onready var painel_result  = $Painel/Centro/VBox/PainelResultado

@onready var log_container  : VBoxContainer   = $Painel/Centro/VBox/PainelJogo/VBox/LogScroll/LogContainer
@onready var log_scroll     : ScrollContainer = $Painel/Centro/VBox/PainelJogo/VBox/LogScroll
@onready var lbl_erros      : Label           = $Painel/Centro/VBox/PainelJogo/VBox/HBoxStatus/LblErros
@onready var spawn_timer    : Timer           = $SpawnTimer
@onready var lbl_titulo_result : Label = $Painel/Centro/VBox/PainelResultado/VBoxContainer/LblTituloResult
@onready var lbl_resultado     : Label = $Painel/Centro/VBox/PainelResultado/VBoxContainer/LblResultado

var errors_remaining : int  = TOTAL_ERRORS
var game_active      : bool = false
var lines_in_screen  : Array = []
var erros_cometidos  : int  = 0

const INFO_MESSAGES : Array = [
	"[INFO]  Server started on port 3000",
	"[INFO]  Request GET /api/users completed in 42ms",
	"[INFO]  Database connection established",
	"[DEBUG] Fetching user data from cache",
	"[INFO]  Response 200 OK — /api/health",
	"[DEBUG] Worker thread pool initialized (8 threads)",
	"[INFO]  Config loaded: production.env",
	"[DEBUG] GC cycle completed, freed 128MB",
	"[INFO]  Scheduled job 'cleanup' triggered",
	"[INFO]  Auth token refreshed for user #4821",
]

const WARNING_MESSAGES : Array = [
	"[WARNING] Memory usage above 80% threshold",
	"[WARNING] Response time degraded: 1.2s avg",
	"[WARNING] Disk space below 20% on /var/log",
	"[WARNING] Rate limit approaching for API key #7",
	"[WARNING] Deprecated endpoint /v1/auth still in use",
]

const ERROR_MESSAGES : Array = [
	"[ERROR] NullPointerException at UserService.java:84",
	"[ERROR] Connection refused: db-primary:5432",
	"[ERROR] Segmentation fault (core dumped) in worker",
	"[ERROR] Stack overflow in recursive call — depth 10000",
	"[ERROR] Out of memory: kill process or sacrifice child",
]

const COLOR_INFO    := Color(0.75, 0.75, 0.75)
const COLOR_WARNING := Color(1.0,  0.85, 0.0)
const COLOR_ERROR   := Color(1.0,  0.2,  0.2)

enum LineType { INFO, WARNING, ERROR }


func _ready() -> void:
	visible = false

func abrir() -> void:
	visible = true
	_esconder_hud(true)
	_mostrar_intro()

func _mostrar_intro() -> void:
	game_active = false
	painel_intro.visible = true
	painel_jogo.visible = false
	painel_result.visible = false

func _iniciar_jogo() -> void:
	errors_remaining = TOTAL_ERRORS
	erros_cometidos  = 0
	game_active = true
	lines_in_screen.clear()
	_update_counter_label()
	painel_intro.visible = false
	painel_jogo.visible = true
	painel_result.visible = false
	spawn_timer.wait_time = SCROLL_TIME
	spawn_timer.start()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_fechar(false)
		return
	if event.is_action_pressed("ui_accept"):
		if painel_intro.visible:
			_iniciar_jogo()
		elif painel_result.visible:
			_fechar(lbl_titulo_result.text == "Producao Estavel!")

func _on_spawn_timer_timeout() -> void:
	if not game_active:
		return
	_spawn_log_line()
	_scroll_to_bottom()

func _spawn_log_line() -> void:
	while log_container.get_child_count() >= MAX_LINES:
		var oldest = log_container.get_child(0)
		lines_in_screen.erase(oldest)
		oldest.queue_free()

	var line_type : LineType = _pick_line_type()
	var text      : String   = _pick_message(line_type)

	var line := Label.new()
	line.text = text
	line.add_theme_color_override("font_color", _get_color(line_type))
	line.add_theme_font_size_override("font_size", 14)
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.mouse_filter = Control.MOUSE_FILTER_STOP
	line.set_meta("type",  line_type)
	line.set_meta("alive", true)
	line.gui_input.connect(_on_line_clicked.bind(line))

	if line_type == LineType.ERROR:
		_start_blink(line)

	log_container.add_child(line)
	lines_in_screen.append(line)

	var removal_timer := get_tree().create_timer(SCROLL_TIME * MAX_LINES * 0.5)
	removal_timer.timeout.connect(_on_line_expired.bind(line, line_type))

func _on_line_clicked(event: InputEvent, line: Label) -> void:
	if not game_active:
		return
	if not event is InputEventMouseButton:
		return
	if not (event as InputEventMouseButton).pressed:
		return
	if (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT:
		return
	if not line.get_meta("alive", false):
		return

	line.set_meta("alive", false)
	var type : LineType = line.get_meta("type")

	match type:
		LineType.ERROR:
			errors_remaining -= 1
			line.queue_free()
			_update_counter_label()
			if errors_remaining <= 0:
				_fim_jogo(true)
		LineType.WARNING:
			erros_cometidos += 1
			_fim_jogo(false, "Voce clicou num [WARNING]!\nEsse nao era pra clicar.")
		LineType.INFO:
			pass

func _on_line_expired(line: Label, type: LineType) -> void:
	if not game_active:
		return
	if not line.get_meta("alive", false):
		return
	if type == LineType.ERROR:
		erros_cometidos += 1
		_fim_jogo(false, "Um [ERROR] passou sem ser clicado!\nProduction is down.")
	if is_instance_valid(line):
		line.queue_free()
	lines_in_screen.erase(line)

func _fim_jogo(vitoria: bool, motivo: String = "") -> void:
	game_active = false
	spawn_timer.stop()
	painel_jogo.visible = false
	painel_result.visible = true

	if vitoria:
		lbl_titulo_result.text = "Producao Estavel!"
		lbl_titulo_result.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		lbl_resultado.text = "Voce capturou todos os %d erros sem errar!\n\n+%d XP\n\n[ ESPACO / clique para fechar ]" % [TOTAL_ERRORS, XP_VITORIA]
	else:
		lbl_titulo_result.text = "Production is down!"
		lbl_titulo_result.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		lbl_resultado.text = "%s\n\n-3 XP\n\n[ ESPACO / clique para fechar ]" % motivo

func _fechar(sucesso: bool) -> void:
	_esconder_hud(false)
	visible = false
	emit_signal("minigame_concluido", sucesso, XP_VITORIA if sucesso else 0)

func _esconder_hud(esconder: bool) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.visible = not esconder

func _pick_line_type() -> LineType:
	var rand := randf()
	if rand < 0.15 and errors_remaining > 0:
		return LineType.ERROR
	elif rand < 0.40:
		return LineType.WARNING
	else:
		return LineType.INFO

func _pick_message(type: LineType) -> String:
	match type:
		LineType.ERROR:   return ERROR_MESSAGES[randi() % ERROR_MESSAGES.size()]
		LineType.WARNING: return WARNING_MESSAGES[randi() % WARNING_MESSAGES.size()]
		_:                return INFO_MESSAGES[randi() % INFO_MESSAGES.size()]

func _get_color(type: LineType) -> Color:
	match type:
		LineType.ERROR:   return COLOR_ERROR
		LineType.WARNING: return COLOR_WARNING
		_:                return COLOR_INFO

func _update_counter_label() -> void:
	lbl_erros.text = "ERRORs restantes: %d" % errors_remaining

func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	log_scroll.scroll_vertical = log_scroll.get_v_scroll_bar().max_value

func _start_blink(line: Label) -> void:
	var blink_count := 0
	while is_instance_valid(line) and line.get_meta("alive", false) and blink_count < 20:
		line.modulate.a = 0.4 if line.modulate.a > 0.9 else 1.0
		await get_tree().create_timer(0.3).timeout
		blink_count += 1
	if is_instance_valid(line):
		line.modulate.a = 1.0
