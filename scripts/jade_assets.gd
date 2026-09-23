extends RefCounted
## Approved artwork only; regions do not include generated values or controls.
const ROOT := "res://assets/ui/meowa/"
static var cache: Dictionary = {}
static var key_shader: Shader
static func region(sheet: String, rect: Rect2) -> AtlasTexture:
 var key := sheet + str(rect)
 if cache.has(key): return cache[key]
 var t := AtlasTexture.new()
 t.atlas = load(ROOT + sheet + ".png")
 t.region = rect
 t.filter_clip = true
 cache[key] = t
 return t
static func sword(index: int) -> AtlasTexture:
 var positions := [Vector2(30,95),Vector2(690,95),Vector2(30,390),Vector2(690,390),Vector2(30,690)]
 return region("race-moving-parts-01",Rect2(positions[clampi(index,0,4)],Vector2(620,200)))
static func boat() -> AtlasTexture:
 return region("race-moving-parts-01",Rect2(750,610,520,320))
static func lever(pulled: bool = false) -> AtlasTexture:
 return region("race-moving-parts-01",Rect2(710 if pulled else 160,940,420,335))
static func icon(index: int) -> AtlasTexture:
 return region("jade-navigation-icons-01",Rect2((index%4)*332,(index/4)*442,332,442))
static func piece(index: int) -> AtlasTexture:
 var y := 35 if index < 4 else (510 if index < 8 else 970)
 var height := 450 if index < 8 else 330
 return region("jade-play-pieces-01",Rect2((index%4)*332,y,332,height))
static func sprite(texture: Texture2D) -> TextureRect:
 var node := TextureRect.new()
 node.texture = texture
 node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 node.mouse_filter = Control.MOUSE_FILTER_IGNORE
 if key_shader == null:
  key_shader = Shader.new()
  key_shader.code = "shader_type canvas_item; varying vec4 tint; void vertex(){tint=COLOR;} void fragment(){vec4 c=texture(TEXTURE,UV); float hi=max(c.r,max(c.g,c.b)); float lo=min(c.r,min(c.g,c.b)); float keep=max(smoothstep(0.18,0.27,hi),smoothstep(0.045,0.09,hi-lo)); COLOR=vec4(c.rgb,c.a*keep)*tint;}"
 var mat := ShaderMaterial.new()
 mat.shader = key_shader
 node.material = mat
 return node
