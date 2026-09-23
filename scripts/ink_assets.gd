extends RefCounted
## All regions point at inspected, transparent production sheets, never mockup UI.
const ROOT = "res://assets/ui/ink/"
static var cache := {}
static func texture(name: String) -> Texture2D:
 if not cache.has(name): cache[name] = load(ROOT+name+".png")
 return cache[name]
static func region(sheet: String, rect: Rect2) -> AtlasTexture:
 var key := sheet+str(rect)
 if not cache.has(key):
  var atlas := AtlasTexture.new();atlas.atlas = texture(sheet);atlas.region = rect;atlas.filter_clip = true;cache[key] = atlas
 return cache[key]
static func button(row: int, column: int = 0) -> Texture2D:
 var bounds := [[22,313,702,554],[698,313,1365,554],[1357,313,2024,554],[28,703,693,947],[703,703,1352,947],[1363,704,2012,947],[25,1129,676,1347],[701,1129,1342,1347],[1360,1129,2002,1347],[18,1506,676,1736],[701,1506,1341,1736],[1357,1506,2008,1736]]
 return bounded("controls",bounds[clampi(row*3+column,0,11)])
static func panel(index: int) -> Texture2D:
 return bounded("panels",[[31,30,1015,745],[1042,29,2029,745],[33,786,1015,1122],[1040,786,2027,1123],[238,1165,848,2010],[1117,1178,1849,1987]][index])
static func bounded(sheet: String, bounds: Array) -> Texture2D:
 return region(sheet,Rect2(bounds[0],bounds[1],bounds[2]-bounds[0],bounds[3]-bounds[1]))
static func sword(index: int) -> Texture2D:
 return bounded("objects",[[45,90,1000,445],[1030,105,2020,450],[45,555,1000,910],[1025,570,2020,915],[35,1085,1000,1405]][clampi(index,0,4)])
static func boat() -> Texture2D: return bounded("objects",[1080,930,1970,1500])
static func lever(pulled: bool = false) -> Texture2D: return bounded("objects",[1250,1580,1805,1980] if pulled else [350,1450,755,1980])
static func icon(index: int) -> Texture2D:
 return region("icons",Rect2((index%4)*512,(index/4)*512,512,512))
static func piece(index: int) -> Texture2D:
 return region("cards-bones",Rect2((index%4)*512,(index/4)*682,512,682))
static func relic(index: int) -> Texture2D:
 return region("relics",Rect2((index%4)*512,(index/4)*1024,512,1024))
static func sprite(value: Texture2D) -> TextureRect:
 var node := TextureRect.new();node.texture = value
 node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 node.mouse_filter = Control.MOUSE_FILTER_IGNORE
 return node
