class_name Cleaner
extends Resource

## Regular expression (string)
var regex_pattern: String
## Compiled regex
var regex: RegEx
## String used to replace the match
var replacement: String
## True if first char of the match must be added to the replacement string
var add_first_char: bool


func _init(i_regex:String, i_replacement: String, i_add_first_char: bool):
	regex_pattern = i_regex
	replacement = i_replacement
	add_first_char = i_add_first_char
	regex = RegEx.new()
	regex.compile(regex_pattern)
	


func _to_string():
	return "regex:/%s/, replacement:'%s', add_fist_char:%s "%[regex, replacement, add_first_char]
