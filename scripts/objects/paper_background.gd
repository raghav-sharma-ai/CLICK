extends CanvasLayer

## PaperBackground
## Renders the paper-industrial drafting environment:
## warm paper fill (#EDE7D8), technical millimeter grid lines,
## and subtle architectural framing marks.

@export var show_grid: bool = true
@export var grid_size: float = 40.0

const C_BACKGROUND: Color = Color("EDE7D8")
const C_GRID: Color = Color(0.48, 0.49, 0.46, 0.12)
const C_MAJOR_GRID: Color = Color(0.48, 0.49, 0.46, 0.22)
const C_STAMP: Color = Color(0.14, 0.15, 0.13, 0.3)

func _ready() -> void:
	layer = -100 # Behind all gameplay elements
	# Create a control node that fills the viewport and redraws on resize
	var control := Control.new()
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(control)
	control.draw.connect(_on_draw.bind(control))
	get_viewport().size_changed.connect(control.queue_redraw)

func _on_draw(canvas: Control) -> void:
	var rect := canvas.get_rect()
	# 1. Warm paper fill
	canvas.draw_rect(rect, C_BACKGROUND, true)

	if not show_grid:
		return

	# 2. Technical blueprint / millimeter grid
	var x: float = 0.0
	var col_idx: int = 0
	while x < rect.size.x:
		var c := C_MAJOR_GRID if (col_idx % 4 == 0) else C_GRID
		canvas.draw_line(Vector2(x, 0), Vector2(x, rect.size.y), c, 1.0)
		x += grid_size
		col_idx += 1

	var y: float = 0.0
	var row_idx: int = 0
	while y < rect.size.y:
		var c := C_MAJOR_GRID if (row_idx % 4 == 0) else C_GRID
		canvas.draw_line(Vector2(0, y), Vector2(rect.size.x, y), c, 1.0)
		y += grid_size
		row_idx += 1

	# 3. Outer technical border & corner registration marks
	var margin: float = 16.0
	var inner_rect := rect.grow(-margin)
	canvas.draw_rect(inner_rect, C_MAJOR_GRID, false, 1.5)
	
	# Corner drafting crosses
	var cross_len: float = 8.0
	var corners := [
		inner_rect.position,
		Vector2(inner_rect.end.x, inner_rect.position.y),
		Vector2(inner_rect.position.x, inner_rect.end.y),
		inner_rect.end
	]
	for pt in corners:
		canvas.draw_line(pt - Vector2(cross_len, 0), pt + Vector2(cross_len, 0), C_MAJOR_GRID, 1.5)
		canvas.draw_line(pt - Vector2(0, cross_len), pt + Vector2(0, cross_len), C_MAJOR_GRID, 1.5)
