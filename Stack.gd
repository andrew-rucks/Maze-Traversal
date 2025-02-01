### Andrew Rucks 11/2/2024 ###

class_name Stack
extends Object

var _stack:Array
var _top:int
const DEFAULT_SIZE = 512

## Constructor
func _init() -> void:
	_top = -1
	_stack.resize(DEFAULT_SIZE)
	_stack.fill(null)
	return
	
## Adds item to top of stack
func push(obj) -> void:
	# edge case: full
	if is_full():
		_stack[_top] = obj
	else:
		_top += 1
		_stack[_top] = obj
	return
	
## Removes and returns the top of the stack
func pop():
	# edge case: empty
	if is_empty():
		return null
	else:
		var ret = _stack[_top]
		_top -= 1
		return ret
		
## Returns top of stack without removing
func peek():
	# edge case: empty
	if is_empty():
		return null
	else:
		return _stack[_top]
	
func is_full() -> bool:
	return (_top == (DEFAULT_SIZE-1))
	
func is_empty() -> bool:
	return (_top == -1)
		
