extends RefCounted
const T=preload("res://scripts/reference_home_theme.gd")
const INK=preload("res://scripts/ink_assets.gd")
static func skin(name: String, inset: float=30) -> StyleBoxTexture:
 var s:=StyleBoxTexture.new();s.texture=load("res://assets/ui_v4/"+name+".png")
 s.texture_margin_left=0;s.texture_margin_right=0;s.texture_margin_top=0;s.texture_margin_bottom=0
 s.content_margin_left=inset;s.content_margin_right=inset;s.content_margin_top=inset;s.content_margin_bottom=inset
 return s
static func picture(tex: Texture2D, area: Vector2) -> TextureRect:
 var t:=INK.sprite(tex);t.custom_minimum_size=area;return t
static func label(text: String, pixels: int=25, light: bool=true) -> Label:
 var l:=Label.new();l.text=text;l.add_theme_font_override("font",T.FONT.BODY);l.add_theme_font_size_override("font_size",pixels);l.add_theme_color_override("font_color",Color("efe9d6") if light else Color("294940"));l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;return l
static func item_icon(m, key: String) -> Texture2D:
 if key in m.E.MATERIAL_NAMES: return load("res://assets/ui_v5/material_%d.png"%m.E.MATERIAL_NAMES.find(key))
 if key in m.E.PILL_NAMES: return load("res://assets/ui_v5/pill_%d.png"%m.E.PILL_NAMES.find(key))
 if key in m.C.SHOP: return load("res://assets/ui_v4/potion_"+key+".png")
 if key==m.BREAKTHROUGH_PILL: return load("res://assets/ui_v4/potion_breakthrough.png")
 var i: int={"鎮煞令":0,"定命符":1,"偷天符":2,"換命符":3,"斬魔敕令":4}.get(key,-1)
 if i>=0: return INK.relic(i)
 if key in m.sect.C.CARDS: return INK.relic(m.sect.C.CARDS.find(key))
 var name:="inventory"
 if key in m.E.MATERIAL_NAMES or key in m.blood_items: name="crystal"
 elif key in m.E.PILL_NAMES or key==m.BREAKTHROUGH_PILL or key in m.C.SHOP: name="shop"
 return load("res://assets/ui_v3/reference_home/icon_"+name+".png")
static func category(m, key: String) -> String:
 if key in m.sect.C.CARDS: return "问剑"
 if key in m.sect.C.RELICS: return "消耗品"
 if key in m.E.MATERIAL_NAMES or key in m.blood_items: return "材料"
 if key in m.E.PILL_NAMES or key==m.BREAKTHROUGH_PILL: return "丹药"
 return "其他"
