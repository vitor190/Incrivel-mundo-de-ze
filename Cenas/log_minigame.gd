extends Node2D

signal minigame_finished(victory: bool, xp: int)

@onready var log_container : VBoxContainer  = $UI/TerminalPanel/VBox/LogScroll/LogContainer
@onready var log_scroll    : ScrollContainer = $UI/TerminalPanel/VBox/LogScroll
@onready var timer_label   : Label           = $UI/TerminalPanel/VBox/TitleBar/TimerLabel
@onready var spawn_timer   : Timer           = $SpawnTimer
@onready var result_panel  : PanelContainer  = $UI/ResultPanel
@onready var result_title  : Label           = $UI/ResultPanel/ResultVBox/ResultTitle
@onready var result_desc   : Label           = $UI/ResultPanel/ResultVBox/ResultDesc

const TOTAL_ERRORS : int   = 5
const SCROLL_TIME  : float = 2.0
const MAX_LINES    : int   = 12
const XP_VICTORY   : int   = 10
const XP_DEFEAT    : int   = -3

var errors_remaining : int  = TOTAL_ERRORS
var errors_clicked   : int  = 0
var game_active      : bool = false
var lines_in_screen  : Array = []

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
	result_panel.show()
	result_panel.hide()
	_update_counter_label()
	game_active = true
	spawn_timer.wait_time = SCROLL_TIME
	spawn_timer.start()

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
			errors_clicked   += 1
			errors_remaining -= 1
			line.queue_free()
			_update_counter_label()
			if errors_remaining <= 0:
				_end_game(true)
		LineType.WARNING:
			_flash_line(line, Color.WHITE)
			_end_game(false, "Você clicou num [WARNING]!\nEsse não era pra clicar.")
		LineType.INFO:
			_flash_line(line, Color.WHITE)

func _on_line_expired(line: Label, type: LineType) -> void:
	if not game_active:
		return
	if not line.get_meta("alive", false):
		return
	if type == LineType.ERROR:
		_end_game(false, "Um [ERROR] passou sem ser clicado!\nProduction is down. 🔥")
	if is_instance_valid(line):
		line.queue_free()
	lines_in_screen.erase(line)

func _end_game(victory: bool, reason: String = "") -> void:
	game_active = false
	spawn_timer.stop()
	result_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_panel.visible = true

	if victory:
		result_title.text = "Producao estavell"
		result_title.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		result_desc.text = "Voce capturou todos os %d erros.\n+%d XP" % [TOTAL_ERRORS, XP_VICTORY]
	else:
		result_title.text = "Production is down!"
		result_title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		result_desc.text = reason + "\n%d XP" % XP_DEFEAT

func _on_continue_pressed() -> void:
	var victory := result_title.text.begins_with("Producao")
	var xp      := XP_VICTORY if victory else XP_DEFEAT
	emit_signal("minigame_finished", victory, xp)
	queue_free()

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
	timer_label.text = "ERRORs restantes: %d" % errors_remaining

func _scroll_to_bottom() -> void:
	await get_tree().process_frame
	log_scroll.scroll_vertical = log_scroll.get_v_scroll_bar().max_value

func _flash_line(line: Label, color: Color) -> void:
	var original := line.get_theme_color("font_color")
	line.add_theme_color_override("font_color", color)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(line):
		line.add_theme_color_override("font_color", original)

func _start_blink(line: Label) -> void:
	var blink_count := 0
	while is_instance_valid(line) and line.get_meta("alive", false) and blink_count < 20:
		line.modulate.a = 0.4 if line.modulate.a > 0.9 else 1.0
		await get_tree().create_timer(0.3).timeout
		blink_count += 1
	if is_instance_valid(line):
		line.modulate.a = 1.0
