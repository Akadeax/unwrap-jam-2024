extends Node
@export var tilemap : TileMap

class Door:
	var relative_grid_pos : Vector2i #use pos of room as 0,0
	var global_grid_pos : Vector2i
	var dir : Vector2i #true is vertical false is horizontal
	func _init(passed_relative_grid_pos : Vector2i, passed_dir : Vector2i, passed_house_pos : Vector2i):
		relative_grid_pos = passed_relative_grid_pos
		global_grid_pos = passed_house_pos + passed_relative_grid_pos
		dir = passed_dir

class RoomRect:
	var grid_pos : Vector2i #both of these are on grid not cords
	var size : Vector2i 
	var entrance : Door
	var doors : Array[Door] # need to be on a wall
	func _init(passed_grid_pos : Vector2i, passed_size : Vector2i, passed_doors : Array[Door], passed_entrance : Door):
		grid_pos = passed_grid_pos
		size = passed_size
		doors = passed_doors
		entrance = passed_entrance
	func duplicate() -> RoomRect:
		return RoomRect.new(grid_pos,size,doors.duplicate(),entrance)
		

var tile_dict = { #dict for mapping the tiles to sensible names
	"OPEN_FLOOR" : Vector2i(0,3),
	"CORNER_TOP_RIGHT" : Vector2i(3,1),
	"CORNER_TOP_LEFT" : Vector2i(0,1),
	"CORNER_BOTTOM_RIGHT" : Vector2i(2,1),
	"CORNER_BOTTOM_LEFT" : Vector2i(1,1),
	"INSIDE_CORNER_TOP_RIGHT" : Vector2i(2,2),
	"INSIDE_CORNER_TOP_LEFT" : Vector2i(0,2),
	"INSIDE_CORNER_BOTTOM_RIGHT" : Vector2i(3,2),
	"INSIDE_CORNER_BOTTOM_LEFT" : Vector2i(1,2),
	"LEFT_WALL" : Vector2i(0,0),
	"RIGHT_WALL" : Vector2i(2,0),
	"BOTTOM_WALL" : Vector2i(1,0),
	"TOP_WALL" : Vector2i(3,0),
	}

var rooms: Array[RoomRect]
var hallways: Array[RoomRect]

func _ready():
	var room_size : Vector2i = Vector2i(6,6)
	var room_pos : Vector2i = Vector2i(0,0)
	var entrance : Door = Door.new(Vector2i(2,5),Vector2i(0,1),room_pos)
		
	var doors : Array[Door] = [
		Door.new(Vector2i(0,2),Vector2i(-1,0),room_pos),
		Door.new(Vector2i(5,2),Vector2i(1,0),room_pos),
		Door.new(Vector2i(2,0),Vector2i(0,-1),room_pos),
	] 
	var room : RoomRect = RoomRect.new(room_pos,room_size,doors,entrance)
	rooms.append(room)
	square_room_draw(room,true)
	print(doors.size())
	
	for i in range(doors.size()):
		var new_hallway = generate_hallway(room.doors[i])
		square_room_draw(new_hallway,false)
		hallways.append(new_hallway)
	#for x in hallways.size():
		#for i in range(hallways[x].doors.size()):
			#var newroom = generate_room(hallways[x].doors[i])
			#square_room_draw(newroom)
			#rooms.append(newroom)
	
func square_room_draw(room : RoomRect,wood : bool):
	var doors : Array[Door] = room.doors.duplicate() 
	doors.append(room.entrance)
	for xIdx in range(room.size.x):
		for yIdx in range(room.size.y):
			var tile_name : String = "OPEN_FLOOR"
			if xIdx == 0 && (yIdx != 0 && yIdx != (room.size.y-1)):
				tile_name = "LEFT_WALL"
			elif xIdx == room.size.x-1 && (yIdx != 0 && yIdx != (room.size.y-1)):
				tile_name = "RIGHT_WALL"
			if yIdx == 0 && (xIdx != 0 && xIdx != (room.size.x-1)):
				tile_name = "TOP_WALL"
			elif yIdx == room.size.y-1 && (xIdx != 0 && xIdx != (room.size.x-1)):
				tile_name = "BOTTOM_WALL"
			elif xIdx == 0 && yIdx == 0:
				tile_name = "CORNER_TOP_LEFT"
			elif xIdx == 0 && yIdx == (room.size.y-1):
				tile_name = "CORNER_BOTTOM_LEFT"
			elif yIdx == (room.size.y-1) && xIdx == (room.size.x-1):
				tile_name = "CORNER_BOTTOM_RIGHT"
			elif yIdx == 0 && xIdx == (room.size.x-1):
				tile_name = "CORNER_TOP_RIGHT"
			if tile_name == "OPEN_FLOOR":
				tilemap.set_cell(0,(Vector2i(xIdx,yIdx)+room.grid_pos)*8,0,Vector2i(randi_range(0,3),tile_dict[tile_name].y)+(int(wood)*Vector2i(4,0)),0)
			else:
				tilemap.set_cell(0,(Vector2i(xIdx,yIdx)+room.grid_pos)*8,0,(tile_dict[tile_name])+(int(wood)*Vector2i(4,0)),0)
	for i in range(doors.size()):
		var tile1_name : String 
		var tile2_name : String
		if (doors[i].dir.x):
			if doors[i].relative_grid_pos.x == 0:
				tile1_name = "INSIDE_CORNER_TOP_LEFT"
				tile2_name = "INSIDE_CORNER_BOTTOM_LEFT"
			else :
				tile1_name = "INSIDE_CORNER_TOP_RIGHT"
				tile2_name = "INSIDE_CORNER_BOTTOM_RIGHT"
			tilemap.set_cell(0,(doors[i].relative_grid_pos+room.grid_pos)*8,0,tile_dict[tile1_name]+(int(wood)*Vector2i(4,0)),0)
			tilemap.set_cell(0,(doors[i].relative_grid_pos+room.grid_pos+Vector2i(0,1))*8,0,tile_dict[tile2_name]+(int(wood)*Vector2i(4,0)),0)
		else:
			if doors[i].relative_grid_pos.y == 0:
				tile1_name = "INSIDE_CORNER_TOP_LEFT"
				tile2_name = "INSIDE_CORNER_TOP_RIGHT"
			else :
				tile1_name = "INSIDE_CORNER_BOTTOM_LEFT"
				tile2_name = "INSIDE_CORNER_BOTTOM_RIGHT"
			tilemap.set_cell(0,(doors[i].relative_grid_pos+room.grid_pos)*8,0,tile_dict[tile1_name]+(int(wood)*Vector2i(4,0)),0)
			tilemap.set_cell(0,(doors[i].relative_grid_pos+room.grid_pos+Vector2i(1,0))*8,0,tile_dict[tile2_name]+(int(wood)*Vector2i(4,0)),0)

func generate_room( prev_door : Door) -> RoomRect:
	const max_size : int = 8
	const min_size : int = 4
	var size : Vector2i = Vector2i(	randi_range(min_size,max_size),
									randi_range(min_size,max_size))
	var pos : Vector2i
	var pos_correction : Vector2i
	var entry_door : Door 
	if prev_door.dir.x == -1:
		pos.x = prev_door.relative_grid_pos.x - size.x 
		pos_correction = Vector2i(-1,0)
		pos.y = prev_door.global_grid_pos.y - (size.y-3)
	elif prev_door.dir.x == 1:
		pos.x = prev_door.relative_grid_pos.x + 1
		pos_correction = Vector2i(1,0)
		pos.y = prev_door.global_grid_pos.y - (size.y-3)
	elif prev_door.dir.y == -1:
		pos.y = prev_door.relative_grid_pos.y - size.y
		pos_correction = Vector2i(0,-1)
		pos.x = prev_door.global_grid_pos.x - (size.x-3)
	elif prev_door.dir.y == 1:
		pos.y = prev_door.relative_grid_pos.y + 1
		pos_correction = Vector2i(0,1)
		pos.x = prev_door.global_grid_pos.x - (size.x-3)
	entry_door.dir = prev_door.dir * -1
	entry_door.relative_grid_pos = prev_door.global_grid_pos + pos_correction - pos

	var room : RoomRect = RoomRect.new(pos,size,[],entry_door)
	return room

func generate_hallway(prev_door : Door) -> RoomRect:
	#make an array that contains the walls that dont contain a door yet:
	var wall_has_door : Array[bool] = [false,false,false,false]
	#generate the hallway itself
	const max_size : int = 15
	const min_size : int = 8
	var size : Vector2i = Vector2i(	randi_range(min_size,max_size),	randi_range(min_size,max_size))
	var pos : Vector2i
	var pos_correction : Vector2i
	#generate the entry door
	var entry_door : Door = Door.new(Vector2i(0,0),Vector2i(0,0),Vector2i(0,0))
	if prev_door.dir.x == -1:
		wall_has_door[0] = true
		size.y = 4
		pos.x = prev_door.relative_grid_pos.x - size.x 
		pos_correction = Vector2i(-1,0)
		pos.y = prev_door.global_grid_pos.y - 1
	elif prev_door.dir.x == 1:
		wall_has_door[1] = true
		size.y = 4
		pos.x = prev_door.relative_grid_pos.x + 1
		pos_correction = Vector2i(1,0)
		pos.y = prev_door.global_grid_pos.y - 1
	elif prev_door.dir.y == -1:
		wall_has_door[2] = true
		size.x = 4
		pos.y = prev_door.relative_grid_pos.y - size.y
		pos_correction = Vector2i(0,-1)
		pos.x = prev_door.global_grid_pos.x - 1
	elif prev_door.dir.y == 1:
		wall_has_door[3] = true
		size.x = 4
		pos.y = prev_door.relative_grid_pos.y + 1
		pos_correction = Vector2i(0,1)
		pos.x = prev_door.global_grid_pos.x - 1
	entry_door.dir = prev_door.dir * -1
	entry_door.relative_grid_pos = prev_door.global_grid_pos + pos_correction - pos
	#make the doors in the hallway
	var door_amnt : int = randi_range(1,3)
	var doors : Array[Door] 
	for i in (door_amnt):
		var door_dir = randi_range(0,3)
		if wall_has_door[door_dir]:
			continue
		var dir : Vector2i
		if door_dir == 0:
			dir = Vector2i(1,0)
		elif door_dir == 1:
			dir = Vector2i(-1,0)
		elif door_dir == 2:
			dir = Vector2i(0,1)
		elif door_dir == 3:
			dir = Vector2i(0,-1)
	var room : RoomRect = RoomRect.new(pos,size,[],entry_door)
	return room
