extends Control

## A function
func foo():
	var bar = 10
	while bar>0:
		pass

# Called when the node enters the scene tree for the first time.
func _ready():

	$Beauty.source_lines = """
	var x=0
	var y:="foo"
	var z :  =  "bar"
	var t:int=0

func test(a, b,c, d ,e, f,g):

	a = a        + b
	a = a +b
	a = a+ b
	a = a  + b  +c  + d  + e
	a = a*b
	a=a* b *c *  d
	a =a/ b /c /  d     /  e
	a =a- b-c -  d     -  e-f
	a = d - e-f
	a =- b
	a=-b
	a=a**2, a=a **2, a=a** 2

	a =! b
	a=a&!b

	a=a%b % c %d  %e % f
	var a=%Node.property
	var a=[%Node1,‰Node2]
	call_some_func(%Node1,%Node2)
	x=y%%Toto.z
	x = y % %Toto.z

	string=&"string"

	a==b, a ==b, a== b , a[i]==b
	a>=b, a
	a>=b, a >=b, a>= b
	a<=b, a <=b, a<= b
	a!=b, a !=b, a!= b
	a+=b, a +=b, a+= b
	a-=b, a -=b, a-= b
	a*=b, a *=b, a*= b
	a/=b, a /=b, a/= b
	a&=b, a &=b, a&= b
	a|=b, a |=b, a|= b
	a^=b, a ^=b, a^= b
	a**=b, a **=b, a**= b
	a<<=b, a <<=b, a<<= b
	a>>=b, a >>=b, a>>= b
	a>b
	a<b

	a<<b
	a>>b

	a =b&c &d
	a =b|c |d
	a= b^c ^d ^e


	a= b&&c &&d&& e
	a= b||c ||d|| e

func test(a:int,b:int, c, d, e, f, g)->z:
func test(a:int, b    :   int, c, d, e, f, g) -> z :
	a = a  + b  + c  + d  + e
	a = a*b
	a=a* b *c *  d


if $node/test:
	var node_test = $node/test
	var node_text = $node/test.text
	$node/test.text="node/test"
	$node/test = "spaces"
	$node/test	=	"tabs"


	""".split("\n")


	$Beauty._apply_cleaners()
	$Beauty._clean_func1()
	$Beauty._clean_empty_lines()
	$Beauty._clean_end_of_script()
	$Beauty._clean_end_of_lines()
