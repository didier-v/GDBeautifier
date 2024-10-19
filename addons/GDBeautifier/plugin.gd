@tool
extends EditorPlugin

var default_shortcut: Shortcut = preload("res://addons/GDBeautifier/default_shortcut.tres")
var gd_beautifier = preload("res://addons/GDBeautifier/gd_beautifier.tscn")
var is_in_dock: bool = false
var beauty_dock


func _enter_tree():
	beauty_dock = gd_beautifier.instantiate()
	connect("main_screen_changed", _on_main_screen_changed)
	beauty_dock.script_editor = get_editor_interface().get_script_editor()
	if get_editor_interface().get_script_editor().visible:
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, beauty_dock)
		is_in_dock = true


func _exit_tree():
	disconnect("main_screen_changed", _on_main_screen_changed)
	if is_in_dock:
		remove_control_from_docks(beauty_dock)
	beauty_dock.free()


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if beauty_dock != null and is_in_dock and default_shortcut.matches_event(event):
		beauty_dock._on_beautify_pressed()


func _on_main_screen_changed(screen):
	if screen == "Script":
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, beauty_dock)
		is_in_dock = true
	else:
		if is_in_dock:
			remove_control_from_docks(beauty_dock)
	is_in_dock = screen == "Script"
