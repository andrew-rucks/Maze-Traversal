### Andrew Rucks 11/2/2024 ###

class_name Queue
extends Object

var _queue:Array
var _front:int
var _size:int

## Constructor
func _init(capacity:int=512) -> void:
	_queue.resize(capacity)
	_queue.fill(null)
	_front = 0
	_size = 0
	return

## Adds item to back of queue
func enqueue(obj) -> void:
	var avail = (_front + _size) % len(_queue)
	_queue[avail] = obj
	_size += 1
	return
	
## Removes and returns item from the front
func dequeue():
	# edge case: empty
	if is_empty():
		return null
	else:
		var temp = _queue[_front]
		_queue[_front] = null
		_front += 1
		_front = _front % len(_queue)
		_size -= 1
		return temp
	
## Just returns front of the queue
func peek():
	return _queue[_front]	
	
func is_empty() -> bool:
	return (_size == 0)
		

	
	
