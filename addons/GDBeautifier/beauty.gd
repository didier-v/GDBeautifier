@tool
class_name Beauty
extends VBoxContainer

## The script editor singleton
var script_editor: ScriptEditor = null: set = _set_script_editor
## The current script in the editor
var current_script: Script
## Lines of the script source code in an array
var source_lines: PackedStringArray


@onready var cleanEmptyLinesCheck = %CleanEmptyLinesCheck
@onready var endOfScriptCheck = %EndOfScriptCheck
@onready var endOfLinesCheck = %EndOfLinesCheck
@onready var spacesOperatorsCheck = %SpacesOperatorsCheck
@onready var linesBeforeFuncCheck = %LinesBeforeFuncCheck

## Array of regular expresessions used to beautify
@onready var cleaners: Array[Cleaner] = [
	Cleaner.new("  ", " ", false), # clean multiple spaces
	Cleaner.new("(\\S)[\\s]*,[\\s]*", ", ", true), # clean ,
	Cleaner.new("(\\S)[\\s]*:[\\s]*", ": ", true), # clean :
	Cleaner.new("(?:^|[^\\s!=<+->&^*|])\\s*=\\s*(?!=)", " = ", true), # clean =
	Cleaner.new("\\S\\s*\\+\\s*(?!=|\\s)\\s*", " + ", true), # clean +
	Cleaner.new("[^\\s\\*]\\s*\\*(?!=|\\*)\\s*", " * ", true), # clean *
	Cleaner.new("\\S\\s*/\\s*(?!=|\\s)\\s*", " / ", true), # clean /
	Cleaner.new("\\S\\s*-(?!=|>|\\s)\\s*", " - ", true), # clean -
	Cleaner.new("\\w\\s*%\\s*(?!=|\\s)\\s*", " % ", true), # clean %
	Cleaner.new("[^\\s&]\\s*&\\s*(?!=|\\\"|&)\\s*", " & ", true), # clean &
	Cleaner.new("[^\\s|]\\s*\\|\\s*(?!=|\\s|\\|)\\s*", " | ", true), # clean |
	Cleaner.new("\\S\\s*\\^\\s*(?!=|\\s)\\s*", " ^ ", true), # clean ^
	Cleaner.new("(=|!|>|<) -\\s", " -", true), # clean - (unary)
	Cleaner.new(" !\\s", " !", false), # clean ! (unary)
	Cleaner.new("\\S\\s*&&\\s*", " && ", true), # clean &&
	Cleaner.new("\\S\\s*\\|\\|\\s*", " || ", true), # clean &&
	Cleaner.new("\\S\\s*\\*\\*(?!=)\\s*", " ** ", true), # clean **
	Cleaner.new("\\S\\s*:\\s*=\\s*", " := ", true), # clean := (inferred static typing)
	Cleaner.new("\\S\\s*==\\s*", " == ", true), # clean ==
	Cleaner.new("[^<]\\s*<=\\s*", " <= ", true), # clean <=
	Cleaner.new("[^>]\\s*>=\\s*", " >= ", true), # clean >=
	Cleaner.new("\\S\\s*!=\\s*", " != ", true), # clean !=
	Cleaner.new("\\S\\s*<<(?!=)\\s*", " << ", true), # clean <<
	Cleaner.new("\\S\\s*>>(?!=)\\s*", " >> ", true), # clean >>
	Cleaner.new("\\S\\s*->\\s*", " -> ", true), # clean ->
	Cleaner.new("[^\\s<]\\s*<(?!=|<|\\s)\\s*", " < ", true), # clean <
	Cleaner.new("[^\\s>-]\\s*>(?!=|>|\\s)\\s*", " > ", true), # clean >
	Cleaner.new("\\S\\s*\\+=\\s*", " += ", true), # clean +=
	Cleaner.new("[^*]\\s*\\*=\\s*", " *= ", true), # clean *=
	Cleaner.new("\\S\\s*/=\\s*", " /= ", true), # clean /=
	Cleaner.new("\\S\\s*-=\\s*", " -= ", true), # clean -=
	Cleaner.new("\\S\\s*&=\\s*", " &= ", true), # clean &=
	Cleaner.new("\\S\\s*\\|=\\s*", " |= ", true), # clean |=
	Cleaner.new("\\S\\s*\\^=\\s*", " ^= ", true), # clean ^=
	Cleaner.new("\\S\\s*\\*\\*=\\s*", " **= ", true), # clean **=
	Cleaner.new("\\S\\s*<<=\\s*", " <<= ", true), # clean <<=
	Cleaner.new("\\S\\s*>>=\\s*", " >>= ", true), # clean >>=
]


func _ready():
	_load_preferences()
	cleanEmptyLinesCheck.tooltip_text = cleanEmptyLinesCheck.text
	endOfLinesCheck.tooltip_text = endOfLinesCheck.text
	endOfScriptCheck.tooltip_text = endOfScriptCheck.text
	spacesOperatorsCheck.tooltip_text = spacesOperatorsCheck.text
	linesBeforeFuncCheck.tooltip_text = linesBeforeFuncCheck.text


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
	source_lines = current_script.source_code.split("\n")
	if spacesOperatorsCheck.button_pressed:
		_apply_cleaners()
	if linesBeforeFuncCheck.button_pressed:
		_clean_func()
	if cleanEmptyLinesCheck.button_pressed:
		_clean_empty_lines()
	if endOfScriptCheck.button_pressed:
		_clean_end_of_script()
	if endOfLinesCheck.button_pressed:
		_clean_end_of_lines()


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


## Removes spaces and tabs in empty lines.
func _clean_empty_lines():
	for i in range(source_lines.size()):
		if source_lines[i] != "" and source_lines[i].strip_edges() == "":
			source_lines[i] = ""
	_update_code()


func _clean_end_of_lines():
	for i in range(source_lines.size()):
		source_lines[i] = source_lines[i].strip_edges(false, true)
	_update_code()


## Removes empty lines at the end of the script.
func _clean_end_of_script():
	var i = source_lines.size() - 1
	while i >= 0:
		if source_lines[i] == "":
			source_lines.remove_at(i)
			i -= 1
		else:
			source_lines.append("") #only 1 empty line at the end
			break
	_update_code()


## Checks that there are exactly two empty lines above functions (and above function comments).
func _clean_func():
	#A any line
	#F func
	#C comment
	#E empty
	#expected result:  EEC*F

	var func_index = -1
	var i = source_lines.size()
	while i >= 0:
		i -= 1
		var line = source_lines[i]
		if line.begins_with("func "):
			func_index = i
		if i == func_index - 1:
			if line.begins_with("#"):
				func_index = i
			elif not line.is_empty():
				source_lines.insert(i + 1, "")
				source_lines.insert(i + 1, "")
				func_index += 2
		elif i == func_index - 2:
			if not line.is_empty():
				source_lines.insert(i + 1, "")
				func_index += 1
		elif i == func_index - 3:
			if line.is_empty():
				source_lines.remove_at(i)
				func_index -= 1
				pass
	_update_code()


## Cleans the source code by applying each defined cleaner on each line.
func _apply_cleaners():
	var regex = RegEx.new()
	for i in range(source_lines.size()):
		var line = source_lines[i]
		var comment_pos = source_lines[i].find("#")
		var quote_ranges = _get_quote_ranges(source_lines[i])
		for cleaner in cleaners:
			regex.compile(cleaner.regex)
			var result = regex.search(source_lines[i], 0, comment_pos)
			while result != null:
				if not _is_in_ranges(result.get_start(), quote_ranges):
					var str = result.get_string()
					var new_str = (str[0] if cleaner.add_first_char else "") + cleaner.replacement
					var offset = 1 if cleaner.add_first_char else 0
					source_lines[i] = source_lines[i].substr(0, result.get_start() + offset) + cleaner.replacement + source_lines[i].substr(result.get_end())
					comment_pos = source_lines[i].find("#")
					quote_ranges = _get_quote_ranges(source_lines[i])
				result = regex.search(source_lines[i], result.get_end() - 1, comment_pos)
	_update_code()


## Returns true if line is a comment.
func _is_comment(line: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[ \t]*#")
	return regex.search(line) != null


## Returns an array of start and end positions of each string in a line.
## Works with single quote and double quote strings.
func _get_quote_ranges(line: String) -> Array:
	var quote_ranges = []
	var in_string = false
	var start_pos = -1
	var end_pos = -1
	var i = 0
	while i < line.length():
		var char = line[i]
		if char == "'" or char == '"':
			if not in_string:
				in_string = true
				start_pos = i
			else:
				end_pos = i
				quote_ranges.append({"start": start_pos, "end": end_pos})
				in_string = false
		elif in_string and char == "\\":
			i += 1
		i += 1
	return quote_ranges


## Returns true if pos is in one of the ranges.
func _is_in_ranges(pos: int, ranges: Array) -> bool:
	var result = false
	for range in ranges:
		var start = range.start
		var end = range.end
		result = result or (pos >= start and pos < end - 1)
	return result


## Update the code in the script editor.
## Or prints the updated code if beautify is run out of the editor (for tests).
func _update_code():
	var updated_source_code = "\n".join(source_lines)
	if Engine.is_editor_hint():
		var code_edit = script_editor.get_current_editor().get_base_editor()
		code_edit.text = updated_source_code
	else:
		print("updated:\n", updated_source_code)
