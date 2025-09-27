extends EditorScript


func _run():
	print("""
	a+b"a+b
	""" + """ (())""")
	print("
	fdfdsq
	")
	test_regex()
	var variation = randf_range( - .25, 0.25)


func test_regex():
	var regex = RegEx.new()
	regex.compile(r"((?:if|return|while)\s+-)\s*")
	var line = "\treturn - 1 + a # and something"
	line = regex.sub(line, "$1")
	print(line)
