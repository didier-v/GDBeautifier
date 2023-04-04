@tool
extends EditorPlugin

var command_id: int = -1
var beauty = preload("res://addons/GDBeautifier/beauty.tscn")
var is_in_dock: bool = false
var beauty_dock


func _enter_tree():
	beauty_dock = beauty.instantiate()
	connect("main_screen_changed", on_main_screen_changed)
	beauty_dock.script_editor = get_editor_interface().get_script_editor()
	if get_editor_interface().get_script_editor().visible:
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, beauty_dock)
		is_in_dock = true


func _exit_tree(): #exit tree
	disconnect("main_screen_changed", on_main_screen_changed)
	if is_in_dock:
		remove_control_from_docks(beauty_dock)
	beauty_dock.free()


func on_main_screen_changed(screen):
	if screen == "Script":
		add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, beauty_dock)
		is_in_dock = true
	else:
		if is_in_dock:
			remove_control_from_docks(beauty_dock)
	is_in_dock = screen == "Script"
