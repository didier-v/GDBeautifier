class_name Cleaner
extends Resource

## Regular expression
var regex: String
## String used to replace the match
var replacement: String
## True if first char of the match must be added to the replacement string
var add_first_char: bool


func _init(i_regex:String, i_replacement: String, i_add_first_char: bool):
	regex = i_regex
	replacement = i_replacement
	add_first_char = i_add_first_char


func _to_string():
	return "regex:/%s/, replacement:'%s', add_fist_char:%s "%[regex, replacement, add_first_char]
