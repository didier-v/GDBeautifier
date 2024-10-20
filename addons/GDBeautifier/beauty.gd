extends Object
class_name Beauty

## Array of regular expresessions used to beautify
var cleaners: Array[Cleaner] = [
	Cleaner.new(r"  +", "", true), # clean multiple spaces
	Cleaner.new(r"(\S)[\s]*,[\s]*", ", ", true), # clean ,
	Cleaner.new(r"(\S)[\s]*:[\s]*", ": ", true), # clean :
	Cleaner.new(r"(?:^|[^\s!=<+->&^*|])\s*=\s*(?!=)", " = ", true), # clean =
	Cleaner.new(r"\S\s*\+\s*(?!=|\s)\s*", " + ", true), # clean +
	Cleaner.new(r"[^\s\*]\s*\*(?!=|\*)\s*", " * ", true), # clean *
	Cleaner.new(r"\S\s*/\s*(?!=|\s)\s*", " / ", true), # clean /
	Cleaner.new(r"[^\s\(\[]\s*-(?!=|>)\s*", " - ", true), # clean -
	Cleaner.new(r"\w\s*%\s*(?!=|\s)\s*", " % ", true), # clean %
	Cleaner.new("[^\\s&]\\s*&\\s*(?!=|\\\"|&)\\s*", " & ", true), # clean &
	Cleaner.new(r"[^\s|]\s*\|\s*(?!=|\s|\|)\s*", " | ", true), # clean |
	Cleaner.new(r"\S\s*\^\s*(?!=|\s)\s*", " ^ ", true), # clean ^
	Cleaner.new(r"(=|!|>|<) -\s", " -", true), # clean - (unary) after = ! < >
	Cleaner.new(r"(\(|\[) -\s", "-", true), # clean - (unary) after ( [
	Cleaner.new(r"((?:if|elif|return|while)\s+-)\s*", "$1", false), # clean - (unary) after keyword
	Cleaner.new(r" !\s", "!", true), # clean ! (unary)
	Cleaner.new(r"\S\s*&&\s*", " && ", true), # clean &&
	Cleaner.new(r"\S\s*\|\|\s*", " || ", true), # clean &&
	Cleaner.new(r"\S\s*\*\*(?!=)\s*", " ** ", true), # clean **
	Cleaner.new(r"\S\s*:\s*=\s*", " := ", true), # clean := (inferred static typing)
	Cleaner.new(r"\S\s*==\s*", " == ", true), # clean ==
	Cleaner.new(r"[^<]\s*<=\s*", " <= ", true), # clean <=
	Cleaner.new(r"[^>]\s*>=\s*", " >= ", true), # clean >=
	Cleaner.new(r"\S\s*!=\s*", " != ", true), # clean !=
	Cleaner.new(r"\S\s*<<(?!=)\s*", " << ", true), # clean <<
	Cleaner.new(r"\S\s*>>(?!=)\s*", " >> ", true), # clean >>
	Cleaner.new(r"\S\s*->\s*", " -> ", true), # clean ->
	Cleaner.new(r"[^\s<]\s*<(?!=|<|\s)\s*", " < ", true), # clean <
	Cleaner.new(r"[^\s>-]\s*>(?!=|>|\s)\s*", " > ", true), # clean >
	Cleaner.new(r"\S\s*\+=\s*", " += ", true), # clean +=
	Cleaner.new(r"[^*]\s*\*=\s*", " *= ", true), # clean *=
	Cleaner.new(r"\S\s*/=\s*", " /= ", true), # clean /=
	Cleaner.new(r"\S\s*-=\s*", " -= ", true), # clean -=
	Cleaner.new(r"\S\s*&=\s*", " &= ", true), # clean &=
	Cleaner.new(r"\S\s*\|=\s*", " |= ", true), # clean |=
	Cleaner.new(r"\S\s*\^=\s*", " ^= ", true), # clean ^=
	Cleaner.new(r"\S\s*\*\*=\s*", " **= ", true), # clean **=
	Cleaner.new(r"\S\s*<<=\s*", " <<= ", true), # clean <<=
	Cleaner.new(r"\S\s*>>=\s*", " >>= ", true), # clean >>=
]

## The multiline state of a line
enum Multiline {
	## not in a multiline string
	NONE,
	## the whole line is in a multiline string
	FULL,
	## the end line is in a multiline string
	END,
}


## Removes spaces and tabs in empty lines.
func clean_empty_lines(source_lines: Array[String]) -> Array[String]:
	for i in range(source_lines.size()):
		if source_lines[i] != "" and source_lines[i].strip_edges() == "":
			source_lines[i] = ""
	return source_lines


## Removes spaces at the end of each line.
func clean_end_of_lines(source_lines: Array[String]) -> Array[String]:
	for i in range(source_lines.size()):
		source_lines[i] = source_lines[i].strip_edges(false, true)
	return source_lines


## Removes empty lines at the end of the script.
func clean_end_of_script(source_lines: Array[String]) -> Array[String]:
	var i = source_lines.size() - 1
	while i >= 0:
		if source_lines[i] == "":
			source_lines.remove_at(i)
			i -= 1
		else:
			source_lines.append("") #only 1 empty line at the end
			break
	return source_lines


## Checks that there are exactly two empty lines above functions (and above function comments).
func clean_func(source_lines: Array[String]) -> Array[String]:
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
	return source_lines


## Cleans the source code by applying each defined cleaner on each line.
func apply_cleaners(source_lines: Array[String]) -> Array[String]:
	var regex = RegEx.new()
	var is_current_line_in_string := false # true when current line is in multiline string
	var is_next_line_in_string := false # true when next line starts in multiline string
	var quote_type_start: String # quote type of the multiline at the start of the current line, if any
	var quote_type_end: String # quote type of the multiline at the end of the current line, if any
	for i in range(source_lines.size()):
		# get the previous multiline state
		is_current_line_in_string = is_next_line_in_string
		quote_type_start = quote_type_end

		var line = source_lines[i]
		var quote_ranges_result = _get_quote_ranges(line, is_current_line_in_string, quote_type_start)
		var quote_ranges = quote_ranges_result[0]
		quote_type_end = quote_ranges_result[2]
		is_next_line_in_string = quote_ranges_result[1] != Multiline.NONE
		var comment_pos = _find_comment_position(source_lines[i], quote_ranges)
		for cleaner in cleaners:
			regex.compile(cleaner.regex)
			var result = regex.search(line, 0, comment_pos) # Search in the line, ignore comments
			while result != null:
				var result_start = result.get_start()
				if not _is_in_ranges(result_start, quote_ranges):
					var str = result.get_string()
					if cleaner.add_first_char:
						var offset = 1
						line = line.substr(0, result.get_start() + offset) + cleaner.replacement + line.substr(result.get_end())
					else: # replace
						line = regex.sub(line, cleaner.replacement)
					quote_ranges_result = _get_quote_ranges(line, is_current_line_in_string, quote_type_start)
					quote_ranges = quote_ranges_result[0]
					comment_pos = _find_comment_position(line, quote_ranges)
				result = regex.search(line, result.get_end() - 1, comment_pos)
		source_lines[i] = line
	return source_lines


## Returns true if line is a comment.
func _is_comment(line: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[ \t]*#")
	return regex.search(line) != null


## Finds the comment starting position in a line, ignoring dashes that are in strings
func _find_comment_position(line: String, string_ranges: Array) -> int:
	var found := false
	var position := -1
	while position < line.length():
		position = line.find("#", position + 1)
		if position == -1:
			return -1
		elif not _is_in_ranges(position, string_ranges):
			return position
	return -1


## Returns an array of start and end positions of each string in a line.[br]
## Works with single quote and double quote strings.[br]
## Returns a tuple [Array of string ranges, in_multiline boolean, quote_type string]
func _get_quote_ranges(line: String, in_multiline: bool = false, quote_type: String = "") -> Array:
	var quote_ranges = []
	var in_string = false
	var escape_next = false
	var start_pos = -1
	var end_pos = -1
	var i = 0

	if in_multiline and quote_type != "":
		var regex = RegEx.new()
		regex.compile(r"(?<!\\)" + quote_type)
		var result = regex.search(line)
		if result == null:
			quote_ranges.append({"start": 0, "end": line.length()})
			return [quote_ranges, Multiline.FULL, quote_type] # for lines in strings the range is the whole line
		else:
			in_multiline = false # end of the multiline
			quote_type = "" # clear quote type
			quote_ranges.append({"start": 0, "end": result.get_end() - 1}) # last part of the multiline
			i = result.get_end()

	while i < line.length():
		var char = line[i]
		if escape_next: # if true, ignore next character
			escape_next = false
		elif in_string and char == "\\": # backslash means ignore next character
			escape_next = true
		elif (  #  a quote has been found
				(quote_type == "" and (char == "'" or char == '"')) 
				or (quote_type != "" and quote_type == line.substr(i,quote_type.length()))
			):
			if not in_string:
				# starting a string with the detected quote type
				var quote_expr = line.substr(i,3) # check if triple-quote type
				if quote_expr == '"""' || quote_expr == "'''":
					quote_type = quote_expr
				else:
					quote_type = char # one char quote type
				in_string = true
				start_pos = i
			else:
				end_pos = i+quote_type.length() # ending a string
				i += quote_type.length() - 1
				quote_type = "" # clear quote type
				quote_ranges.append({"start": start_pos, "end": end_pos})
				in_string = false
		i += 1
	if in_string:
		# string not terminated at the end of line, starting a multiline
		in_multiline = true
		quote_ranges.append({"start": start_pos, "end": line.length()})
	return [quote_ranges, Multiline.END if in_multiline else Multiline.NONE, quote_type]


## Returns true if pos is in one of the ranges.
func _is_in_ranges(pos: int, ranges: Array) -> bool:
	var result = false
	for range in ranges:
		var start = range.start
		var end = range.end
		result = result or (pos >= start and pos < end - 1)
	return result
