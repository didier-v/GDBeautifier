extends GutTest

var beauty: Beauty


func before_all():
	beauty = Beauty.new()


func test_assignment_cleaners():
	var source_lines: Array[String] = [
		'	var x=0',
		'var y:="foo"',
		'var z :  =  "bar"',
		'	var t:int=0',
	]
	var expected_lines: Array[String] = [
		'	var x = 0',
		'var y := "foo"',
		'var z := "bar"',
		'	var t: int = 0',
	]
	_process_tests(source_lines, expected_lines)


func test_assignment_operators_cleaners():
	var source_lines: Array[String] = [
		'a+=b, a +=b, a+= b',
		'a-=b, a -=b, a-= b',
		'a*=b, a *=b, a*= b',
		'a/=b, a /=b, a/= b',
		'a&=b, a &=b, a&= b',
		'a|=b, a |=b, a|= b',
		'a^=b, a ^=b, a^= b',
		'a**=b, a **=b, a**= b',
		'a<<=b, a <<=b, a<<= b',
		'a>>=b, a >>=b, a>>= b',
	]
	var expected_lines: Array[String] = [
		'a += b, a += b, a += b',
		'a -= b, a -= b, a -= b',
		'a *= b, a *= b, a *= b',
		'a /= b, a /= b, a /= b',
		'a &= b, a &= b, a &= b',
		'a |= b, a |= b, a |= b',
		'a ^= b, a ^= b, a ^= b',
		'a **= b, a **= b, a **= b',
		'a <<= b, a <<= b, a <<= b',
		'a >>= b, a >>= b, a >>= b',
	]
	_process_tests(source_lines, expected_lines)


func test_arguments_cleaners():
	var source_lines: Array[String] = [
		'func test(a, b,c, d ,e, f,g):	',
		'func test(a:int,b:int, c, d, e, f, g)->z: ',
		'func test(a:int, b    :   int, c, d, e, f, g) -> z : ',
	]
	var expected_lines: Array[String] = [
		'func test(a, b, c, d, e, f, g): ',
		'func test(a: int, b: int, c, d, e, f, g) -> z: ',
		'func test(a: int, b: int, c, d, e, f, g) -> z: ',
	]
	_process_tests(source_lines, expected_lines)


func test_operators_cleaners():
	var source_lines: Array[String] = [
		'a = a        + b',
		'a = a +b',
		'a = a+ b',
		'a = a  + b  +c  + d  + e',
		'a =a+ b+c +  d     +  e+f',
		'a = a*b',
		'a=a* b *c *  d',
		'a =a/ b /c /  d     /  e',
		'a =a- b-c -  d     -  e-f',
		'a = d - e-f',
		'a =- b',
		'a=-b',
		'a=a**2, a=a **2, a=a** 2',
		'a =b&c &d',
		'a =b|c |d',
		'a= b^c ^d ^e',
		'a= b&&c &&d&& e',
		'a= b||c ||d|| e',
		'a =! b',
		'a=a&!b',
		'a=a%b % c %d  %e % f',
		'a<<b',
		'a>>b',
		'a = (-b-1)',
		'a = ( - b-1)',
		'return -  1 + a # comment',
		'[-1,1]',
		'[ - 1,1]',
	]
	var expected_lines: Array[String] = [
		'a = a + b',
		'a = a + b',
		'a = a + b',
		'a = a + b + c + d + e',
		'a = a + b + c + d + e + f',
		'a = a * b',
		'a = a * b * c * d',
		'a = a / b / c / d / e',
		'a = a - b - c - d - e - f',
		'a = d - e - f',
		'a = -b',
		'a = -b',
		'a = a ** 2, a = a ** 2, a = a ** 2',
		'a = b & c & d',
		'a = b | c | d',
		'a = b ^ c ^ d ^ e',
		'a = b && c && d && e',
		'a = b || c || d || e',
		'a = !b',
		'a = a & !b',
		'a = a % b % c % d % e % f',
		'a << b',
		'a >> b',
		'a = (-b - 1)',
		'a = (-b - 1)',
		'return -1 + a # comment',
		'[-1, 1]',
		'[-1, 1]',
	]
	_process_tests(source_lines, expected_lines)


func test_comparison_operators_cleaners():
	var source_lines: Array[String] = [
		'a==b, a ==b, a== b , a[i]==b',
		'a>=b, a',
		'a>=b, a >=b, a>= b ',
		'a<=b, a <=b, a<= b',
		'a!=b, a !=b, a!= b',
		'a>b',
		'a<b',
	]
	var expected_lines: Array[String] = [
		'a == b, a == b, a == b, a[i] == b',
		'a >= b, a',
		'a >= b, a >= b, a >= b ',
		'a <= b, a <= b, a <= b',
		'a != b, a != b, a != b',
		'a > b',
		'a < b',
	]
	_process_tests(source_lines, expected_lines)


func test_nodepath_cleaners():
	var source_lines: Array[String] = [
		'var a=%Node.property',
		'var a=[%Node1,‰Node2]',
		'call_some_func(%Node1,%Node2)',
		'x=y%%Toto.z',
		'x = y % %Toto.z',
	]
	var expected_lines: Array[String] = [
		'var a = %Node.property',
		'var a = [%Node1, ‰Node2]',
		'call_some_func(%Node1, %Node2)',
		'x = y % %Toto.z',
		'x = y % %Toto.z',
	]
	_process_tests(source_lines, expected_lines)


func test_comments():
	var source_lines: Array[String] = [
		'a+b # +a+b',
		'"a+b # "+a+b',
		'"a+b # "+a+b #b+c',
	]
	var expected_lines: Array[String] = [
		'a + b # +a+b',
		'"a+b # " + a + b',
		'"a+b # " + a + b #b+c',
	]
	_process_tests(source_lines, expected_lines)


func test_strings():
	var source_lines = """
string=&"string"
"solo'quote_a+b"
"ignore\\"quote_a+b"
"a+b
b+c+d+'x'+e
   do  not  remove   +   spaces !
"
r"a+b+\\\"+c
+d+e"+a+b+'x+y
+z'+a+
"a+'a+b'+b"+'a+b'+c+d
\"\"\"
	a+b"a+b
\"\"\"
print(\"\"\"
a+b\"a+b
\"\"\" + \"\"\" (())\"\"\")
a+b""".split("\n")

	var expected_lines = """
string = &"string"
"solo'quote_a+b"
"ignore\\"quote_a+b"
"a+b
b+c+d+'x'+e
   do  not  remove   +   spaces !
"
r"a+b+\\\"+c
+d+e" + a + b + 'x+y
+z' + a + 
"a+'a+b'+b" + 'a+b' + c + d
\"\"\"
	a+b"a+b
\"\"\"
print(\"\"\"
a+b\"a+b
\"\"\" + \"\"\" (())\"\"\")
a + b""".split("\n")
	_process_tests(source_lines, expected_lines)


func _process_tests(source_lines, expected_lines):
	source_lines = beauty.apply_cleaners(source_lines)
	for i in range(source_lines.size()):
		assert_eq(source_lines[i], expected_lines[i], "%d: %s failed"%[i, expected_lines[i]])
