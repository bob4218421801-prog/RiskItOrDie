extends Control
var model: RefCounted
var elapsed := 0.0
var room_elapsed := 0.0
func _ready(): mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(delta):
 visible = model.modal.get("kind","") == "dialogue" and model.modal.get("id","") == "opening"
 if visible: elapsed += delta;queue_redraw()
 else: elapsed = 0
 if visible and model.modal.get("index",0) >= 2: room_elapsed += delta
 else: room_elapsed = 0
func _draw():
 if not visible: return
 draw_rect(Rect2(0,0,1920,1080),Color.BLACK)
 var step: int = model.modal.get("index",0)
 if step < 2: return
 var light := Color(.16,.21,.23,clampf(room_elapsed*1.5,0,1))
 draw_rect(Rect2(120,80,1680,920),light)
 for x in [220,1520]:
  draw_rect(Rect2(x,120,180,500),Color("253c42"))
  for row in range(6): draw_line(Vector2(x,150+row*80),Vector2(x+180,150+row*80),Color("587172"),3)
 for i in range(12):
  var y := 150+i*60+sin(elapsed*.8+i)*7
  draw_line(Vector2(120,y),Vector2(290,y-15),Color(.65,.8,.8,.12),2,true)
 if step in [2,3]:
  var center := Vector2(960,185)
  for ring in range(3): draw_arc(center,45+ring*25+sin(elapsed*3)*4,0,TAU,64,Color(.4,.9,.75,.5),3,true)
 if step >= 7:
  var font := ThemeDB.fallback_font
  draw_string(font,Vector2(710,155),"年齡 %.0f　壽元 %.0f　剩餘 %.0f 年" % [model.age,model.lifespan,model.lifespan-model.age],HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color("f1ce94"))
