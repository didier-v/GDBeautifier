@tool
extends VBoxContainer

## The script editor singleton
var script_editor: ScriptEditor = null: set = _set_script_editor
## The current script in the editor
var current_script: Script
## The beautifier
var beauty: Beauty

@onready var cleanEmptyLinesCheck = %CleanEmptyLinesCheck
@onready var endOfScriptCheck = %EndOfScriptCheck
@onready var endOfLinesCheck = %EndOfLinesCheck
@onready var spacesOperatorsCheck = %SpacesOperatorsCheck
@onready var linesBeforeFuncCheck = %LinesBeforeFuncCheck


func _ready():
	_load_preferences()
	cleanEmptyLinesCheck.tooltip_text = cleanEmptyLinesCheck.text
	endOfLinesCheck.tooltip_text = endOfLinesCheck.text
	endOfScriptCheck.tooltip_text = endOfScriptCheck.text
	spacesOperatorsCheck.tooltip_text = spacesOperatorsCheck.text
	linesBeforeFuncCheck.tooltip_text = linesBeforeFuncCheck.text
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
	var source_lines = current_script.source_code.split("\n")
	if spacesOperatorsCheck.button_pressed:
		source_lines = beauty.apply_cleaners(source_lines)
	if linesBeforeFuncCheck.button_pressed:
		source_lines = beauty.clean_func(source_lines)
	if cleanEmptyLinesCheck.button_pressed:
		source_lines = beauty.clean_empty_lines(source_lines)
	if endOfScriptCheck.button_pressed:
		source_lines = beauty.clean_end_of_script(source_lines)
	if endOfLinesCheck.button_pressed:
		source_lines = beauty.clean_end_of_lines(source_lines)
	_update_code(source_lines)


func _on_end_of_lines_check_toggled(button_pressed):
	if button_pressed:
		cleanEmptyLinesCheck.button_pressed = true


func _on_clean_empty_lines_check_toggled(button_pressed):
	if not button_pressed:
		endOfLinesCheck.button_pressed = false


func _on_toggle(button_pressed):
	_save_preferences()


## Saves the addon preferences in a config file.
func _save_preferences():
	var config_file = ConfigFile.new()
	config_file.set_value("prefs", "spacesOperatorsCheck", spacesOperatorsCheck.button_pressed)
	config_file.set_value("prefs", "linesBeforeFuncCheck", linesBeforeFuncCheck.button_pressed)
	config_file.set_value("prefs", "cleanEmptyLinesCheck", cleanEmptyLinesCheck.button_pressed)
	config_file.set_value("prefs", "endOfScriptCheck", endOfScriptCheck.button_pressed)
	config_file.set_value("prefs", "endOfLinesCheck", endOfLinesCheck.button_pressed)
	var err = config_file.save("res://addons/GDBeautifier/prefs.cfg")


## Loads the addon preferences if a pref file is available.
func _load_preferences():
	var config_file = ConfigFile.new()
	var err = config_file.load("res://addons/GDBeautifier/prefs.cfg")
	if err != OK:
		return
	spacesOperatorsCheck.button_pressed = config_file.get_value("prefs", "spacesOperatorsCheck", true)
	linesBeforeFuncCheck.button_pressed = config_file.get_value("prefs", "linesBeforeFuncCheck", true)
	cleanEmptyLinesCheck.button_pressed = config_file.get_value("prefs", "cleanEmptyLinesCheck", true)
	endOfScriptCheck.button_pressed = config_file.get_value("prefs", "endOfScriptCheck", true)
	endOfLinesCheck.button_pressed = config_file.get_value("prefs", "endOfLinesCheck", true)


## Update the code in the script editor.
## Or prints the updated code if beautify is run out of the editor (for tests).
func _update_code(source_lines):
	var updated_source_code = "\n".join(source_lines)
	if Engine.is_editor_hint():
		var code_edit = script_editor.get_current_editor().get_base_editor()
		code_edit.text = updated_source_code
	else:
		print("updated:\n", updated_source_code)
