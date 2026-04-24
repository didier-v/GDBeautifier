@tool
extends VBoxContainer

class_name GDBeautifierScene

## The script editor singleton
var script_editor: ScriptEditor = null: set = _set_script_editor
## The current script in the editor
var current_script: Script
## The beautifier
var beauty: Beauty

@onready var clean_empty_lines_check: CheckBox = %CleanEmptyLinesCheck
@onready var end_of_script_check: CheckBox = %EndOfScriptCheck
@onready var end_of_lines_check: CheckBox = %EndOfLinesCheck
@onready var spaces_operators_check: CheckBox = %SpacesOperatorsCheck
@onready var lines_before_func_check: CheckBox = %LinesBeforeFuncCheck
@onready var lines_before_func_count: SpinBox = %linesBeforeFuncCount

var lines_before_func: int = 2


func _ready():
	_load_preferences()
	clean_empty_lines_check.tooltip_text = clean_empty_lines_check.text
	end_of_lines_check.tooltip_text = end_of_lines_check.text
	end_of_script_check.tooltip_text = end_of_script_check.text
	spaces_operators_check.tooltip_text = spaces_operators_check.text
	beauty = Beauty.new()


## Sets the current script editor.
## Connects signals to detect change of script and update the current script.
func _set_script_editor(val: ScriptEditor):
	if script_editor != null:
		script_editor.editor_script_changed.disconnect(_on_script_changed)
	script_editor = val
	script_editor.editor_script_changed.connect(_on_script_changed)
	current_script = script_editor.get_current_script()


## Updates the current script when it changes.
func _on_script_changed(script: Script):
	current_script = script


## Beautifies the current script.
func _on_beautify_pressed():
	var source_lines: Array[String]

	if Engine.is_editor_hint():
		# Get unsaved code from the editor widget
		var code_edit = script_editor.get_current_editor().get_base_editor()
		source_lines = Array(Array(code_edit.text.split("\n")), TYPE_STRING, "", null)
	else:
		# Fallback for non-editor context (tests)
		source_lines = Array(Array(current_script.source_code.split("\n")), TYPE_STRING, "", null)

	if spaces_operators_check.button_pressed:
		source_lines = beauty.apply_cleaners(source_lines)
	if lines_before_func_check.button_pressed:
		source_lines = beauty.clean_func(source_lines, lines_before_func)
	if clean_empty_lines_check.button_pressed:
		source_lines = beauty.clean_empty_lines(source_lines)
	if end_of_script_check.button_pressed:
		source_lines = beauty.clean_end_of_script(source_lines)
	if end_of_lines_check.button_pressed:
		source_lines = beauty.clean_end_of_lines(source_lines)
	_update_code(source_lines)


func _on_end_of_lines_check_toggled(button_pressed):
	if button_pressed:
		clean_empty_lines_check.button_pressed = true


func _on_clean_empty_lines_check_toggled(button_pressed):
	if not button_pressed:
		end_of_lines_check.button_pressed = false


func _on_toggle(button_pressed):
	lines_before_func_count.editable = lines_before_func_check.button_pressed
	_save_preferences()


func _on_lines_before_func_count_value_changed(value: float) -> void:
	lines_before_func = clampi(int(lines_before_func_count.value), 0, 9)
	_save_preferences()


## Saves the addon preferences in a config file.
func _save_preferences():
	var config_file = ConfigFile.new()
	config_file.set_value("prefs", "spaces_operators_check", spaces_operators_check.button_pressed)
	config_file.set_value("prefs", "lines_before_func_check", lines_before_func_check.button_pressed)
	config_file.set_value("prefs", "clean_empty_lines_check", clean_empty_lines_check.button_pressed)
	config_file.set_value("prefs", "end_of_script_check", end_of_script_check.button_pressed)
	config_file.set_value("prefs", "end_of_lines_check", end_of_lines_check.button_pressed)
	config_file.set_value("prefs", "lines_before_func_count", lines_before_func)
	var err = config_file.save("res://addons/GDBeautifier/prefs.cfg")


## Loads the addon preferences if a pref file is available.
func _load_preferences():
	var config_file = ConfigFile.new()
	var err = config_file.load("res://addons/GDBeautifier/prefs.cfg")
	if err != OK:
		return
	spaces_operators_check.button_pressed = config_file.get_value("prefs", "spaces_operators_check", true)
	lines_before_func_check.button_pressed = config_file.get_value("prefs", "lines_before_func_check", true)
	clean_empty_lines_check.button_pressed = config_file.get_value("prefs", "clean_empty_lines_check", true)
	end_of_script_check.button_pressed = config_file.get_value("prefs", "end_of_script_check", true)
	end_of_lines_check.button_pressed = config_file.get_value("prefs", "end_of_lines_check", true)
	lines_before_func = config_file.get_value("prefs", "lines_before_func_count", lines_before_func)
	lines_before_func_count.value = lines_before_func


## Update the code in the script editor.
## Or prints the updated code if beautify is run out of the editor (for tests).
func _update_code(source_lines):
	var updated_source_code = "\n".join(source_lines)
	if Engine.is_editor_hint():
		var code_edit = script_editor.get_current_editor().get_base_editor()
		code_edit.text = updated_source_code
	else:
		print("updated:\n", updated_source_code)
