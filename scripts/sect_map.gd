extends Control
## The four destinations lead to existing sect actions, never separate inventories.
signal destination_selected(destination: String)
const A = preload("res://scripts/jade_assets.gd")
var model: RefCounted
var image: TextureRect
var entries: Array[Button] = []
const LOCATIONS = [Vector2(.464,.32),Vector2(.276,.85),Vector2(.728,.48),Vector2(.657,.86)]
const PEOPLE = ["師父","小師妹","大師姐","俸祿堂"]
func _ready():
 custom_minimum_size.y = 510
 size_flags_horizontal = Control.SIZE_EXPAND_FILL
 image = TextureRect.new()
 image.texture = load(A.ROOT+"sect-map-preview-01.png")
 image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 image.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(image)
 for i in range(4):
  var place: String = PEOPLE[i]
  var b := Button.new()
  b.text = place+"的家" if i in [1,2] else place
  b.add_theme_font_size_override("font_size",23)
  preload("res://scripts/jade_theme.gd").apply_button(b)
  b.disabled = (i == 1 and not model.sect.junior_met) or (i == 2 and not model.sect.senior_met)
  if b.disabled: b.tooltip_text=""
  b.pressed.connect(func(): destination_selected.emit(place))
  add_child(b);entries.append(b)
 resized.connect(layout)
 layout()
func layout():
 if image == null: return
 image.size = size
 var dimensions := Vector2(minf(size.x,size.y*1328.0/747.0),size.y)
 var origin := (size-dimensions)*.5
 for i in range(entries.size()):
  entries[i].size = Vector2(190,43)
  entries[i].position = origin+LOCATIONS[i]*dimensions-entries[i].size*.5
