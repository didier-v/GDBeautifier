@tool
extends EditorPlugin

var default_shortcut: Shortcut = preload("res://addons/GDBeautifier/default_shortcut.tres")
var gd_beautifier = preload("res://addons/GDBeautifier/gd_beautifier.tscn")
var is_in_dock: bool = false
var beauty_scene: GDBeautifierScene
var dock: EditorDock


func _enter_tree():
	beauty_scene = gd_beautifier.instantiate()
	main_screen_changed.connect(_on_main_screen_changed)
	beauty_scene.script_editor = EditorInterface.get_script_editor()
	if EditorInterface.get_script_editor().visible:
		dock = EditorDock.new()
		dock.add_child(beauty_scene)
		dock.default_slot = EditorDock.DOCK_SLOT_LEFT_UR
		dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_HORIZONTAL
		add_dock(dock)
		is_in_dock = true


func _exit_tree():
	disconnect("main_screen_changed", _on_main_screen_changed)
	remove_dock(dock)
	dock.queue_free()


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): return
	if beauty_scene != null and is_in_dock and default_shortcut.matches_event(event):
		beauty_scene._on_beautify_pressed()


func _on_main_screen_changed(screen):
	if screen == "Script":
		add_dock(dock)
		is_in_dock = true
	else:
		if is_in_dock:
			remove_dock(dock)
	is_in_dock = screen == "Script"
