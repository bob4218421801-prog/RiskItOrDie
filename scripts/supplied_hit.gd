extends RefCounted
static func style(b: Button):
 b.flat=true;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 for state in ["normal","hover","pressed","disabled","focus"]: b.add_theme_stylebox_override(state,StyleBoxEmpty.new())
