### Andrew Rucks 11/2/2024 ###
## Visually represents the grids.

extends Node2D

var grid:Grid
const TILE_MULT = 20

@export_color_no_alpha var obstacle_color:Color
@export_color_no_alpha var free_color:Color
@export_color_no_alpha var visited_color:Color
@export_color_no_alpha var special_color:Color

var show_visited:bool = false
var show_distance:bool = false
var show_path:bool = false
var grid_mode = "BFS"

var bfs_grid:Grid
var dfs_grid:Grid

var spot = preload("res://spot.tscn")

func _ready() -> void:
	for y in Main.GRIDSIZE:
		for x in Main.GRIDSIZE:
			var o:Node2D = spot.instantiate()
			self.add_child(o)
			o.set_position(Vector2(x * TILE_MULT, y * TILE_MULT))

func set_bfs_grid(grid:Grid) -> void:
	self.bfs_grid = grid
	
func set_dfs_grid(grid:Grid) -> void:
	self.dfs_grid = grid
	
func render_grid() -> void:
	_clear()
	
	# bfs or dfs mode:
	var grid:Grid
	if grid_mode == "BFS":
		grid = bfs_grid
	elif grid_mode == "DFS":
		grid = dfs_grid
	
	# loop through visual grid and modify each spot.
	var i = 0	
	for y in grid.height:
		for x in grid.width:
			var o = self.get_child(i)
			
			if grid.query(Vector2i(x, y)).is_obstacle:
				o.get_child(0).color = obstacle_color
				
			if grid.query(Vector2i(x, y)).was_visited and show_visited:
				o.get_child(0).color = visited_color
				if show_distance:
					o.get_child(2).text = str(grid.query(Vector2i(x, y)).distance)
					
			elif not grid.query(Vector2i(x, y)).is_obstacle:
				o.get_child(0).color = free_color
				
			if grid.query(Vector2i(x, y)).data == "start":
				o.get_child(0).color = special_color
				o.get_child(2).text = "  S"
				
			elif grid.query(Vector2i(x, y)).data == "end":
				o.get_child(0).color = special_color
				o.get_child(2).text = "  E"
				
			elif grid.query(Vector2i(x, y)).data == "path" and show_path:
				o.get_child(1).visible = true
				
			i += 1

## Resets the grid colors.
func _clear() -> void:
	var i = 0	
	for y in Main.GRIDSIZE:
		for x in Main.GRIDSIZE:
			var o = self.get_child(i)
			o.get_child(0).color = free_color
			o.get_child(1).visible = false
			o.get_child(2).text = ""
			i += 1
