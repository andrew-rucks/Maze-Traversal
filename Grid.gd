### Andrew Rucks 11/2/2024 ###
## Grid class. 
## Access spots on the grid with Vector2i X,Y coordinates.
## The grid iteself is an array composed of 'GridSpots.'
## Width: x axis
## Height: y axis

class_name Grid
extends Object

const OBSTACLE_DENSITY = 0.20 # scale between 0.0 - 1.0

var _grid: Array[GridSpot] = []
var _rng = RandomNumberGenerator.new()

var width:int
var height:int


## Constructor
func _init(w:int, h:int, randomize:bool=true) -> void:
	width = w
	height = h
	_grid.resize(width * height)
	_rng.randomize()
	
	# randomize the grid
	if randomize:
		for s in len(_grid):
			var new_spot = GridSpot.new(false)
			
			# chance to become an obstacle. if random float 0.0-1.0 < chance constant.
			if _rng.randf() <= OBSTACLE_DENSITY:
				new_spot.is_obstacle = true
				
			_grid[s] = new_spot
		
		# fill in the walls
		for y in height:
			query(Vector2i(0, y)).is_obstacle = true		#left side
			query(Vector2i(width-1, y)).is_obstacle = true		#right side
		for x in width:
			query(Vector2i(x, 0)).is_obstacle = true		#top side
			query(Vector2i(x, height-1)).is_obstacle = true		#bottom side
	
	return

					
## Returns the GridSpot at the desired vector2 coordinate.
func query(coord:Vector2i) -> GridSpot:
	# edge case: out of bounds:
	if (abs(coord.x) >= width) or (abs(coord.y) >= height):
		return null

	return _grid[coord.x + (width * coord.y)]


## Returns an array of open spots adjacent to the given spot.	
func get_open_neighbors(coord:Vector2i) -> Array[Vector2i]:
	var result:Array[Vector2i]
	
	var directions = [Vector2i(coord.x, coord.y + 1), Vector2i(coord.x, coord.y - 1), Vector2i(coord.x + 1, coord.y), Vector2i(coord.x - 1, coord.y)]
	for d in directions:
		if (query(d) != null) and (query(d).is_obstacle == false):
			result.append(d)
			
	return result


## Returns an array of visited spots adjacent to the given spot.
func get_visited_neighbors(coord:Vector2i) -> Array[Vector2i]:
	var result:Array[Vector2i]
	
	var directions = [Vector2i(coord.x, coord.y + 1), Vector2i(coord.x, coord.y - 1), Vector2i(coord.x + 1, coord.y), Vector2i(coord.x - 1, coord.y)]
	for d in directions:
		if (query(d) != null) and (query(d).was_visited == true):
			result.append(d)
			
	return result	


## Converts the grid array to printable string.
func _to_string() -> String:
	var string = ""
	for y in height:
		for x in width:
			if query(Vector2i(x, y)).is_obstacle:
				string += "██"
			elif query(Vector2i(x, y)).data == "start":
				string += "St"
			elif query(Vector2i(x, y)).data == "end":
				string += "En"
			elif query(Vector2(x, y)).was_visited:
				string += "▒▒"
			else:
				string += "░░"
		string += "\n"
	return string


## Returns a deep-copy of the Grid	
func duplicate() -> Grid:
	var new = Grid.new(width, height, false)
	# copy the grid array
	var i = 0
	while i < len(self._grid):
		new._grid[i] = self._grid[i].duplicate()
		i += 1

	return new

	
## Inline class. Each spot in the grid is this object.
class GridSpot:
	extends Object
	var is_obstacle:bool
	var was_visited:bool = false
	var distance = -1
	var data = null
	func _init(obstacle:bool) -> void:
		is_obstacle = obstacle
		return
	func duplicate() -> GridSpot:
		var new = GridSpot.new(self.is_obstacle)
		new.was_visited = self.was_visited
		new.distance = self.distance
		new.data = self.data
		return new
