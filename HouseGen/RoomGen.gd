extends Node
@export var tilemap : TileMap
@export var sand_tilemap : TileMap

@export var big_table_1 : PackedScene # kitchen / center
@export var big_table_2 : PackedScene # kitchen / center
@export var bed : PackedScene # bedroom / wall
@export var computer_desk : PackedScene #living room / wall
@export var rolling_chair : PackedScene #living room / center
@export var fish_coffee_table : PackedScene #living room / center
@export var closet : PackedScene #living room,hallways,bedroom,bathroom / wall
@export var big_couch : PackedScene #living room, bedroom / center
@export var couch : PackedScene # living room, bedroom / center
@export var tv : PackedScene # living room / wall
@export var open_dresser : PackedScene # bedroom / wall
@export var tub : PackedScene #bathroom / wall
@export var sink_1 : PackedScene #bathroom / wall
@export var sink_2 : PackedScene #bathroom / wall
@export var toilet : PackedScene #bathroom / wall
@export var stove : PackedScene #kitchen / wall
@export var fridge : PackedScene #kitchen / wall
@export var table_chair_1 : PackedScene #kitchen / center
@export var table_chair_2 : PackedScene #kitchen / center
@export var kitchen_sink : PackedScene #kitchen / wall
@export var box_1 : PackedScene #anywhere / center
@export var box_2 : PackedScene #anywhere / center
@export var lamp : PackedScene #anywhere /center

class SpawnInfo:
	var angle : float
	var position : Vector2
	func _init(rad : float, pos : Vector2):
		angle = rad
		position = pos
class DualPos:
	var top_left : Vector2
	var bottom_right : Vector2
	func _init(topleft : Vector2, bottomright : Vector2):
		top_left = topleft
		bottom_right = bottomright
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
	var type : RoomTypes
	var furniture : Array[PickupObject]
	var wall_has_door : Array[bool] = [false,false,false,false]
	func _init(passed_grid_pos : Vector2i, passed_size : Vector2i, passed_doors : Array[Door], passed_entrance : Door):
		grid_pos = passed_grid_pos
		size = passed_size
		doors = passed_doors
		entrance = passed_entrance
		type = RoomTypes.values().pick_random()
	func duplicate() -> RoomRect:
		return RoomRect.new(grid_pos,size,doors.duplicate(),entrance)
	func is_overlapping(other_room : RoomRect) ->bool:
		var house_one_actual_size = (size.abs())*(size/size)
		var house_two_actual_size = (other_room.size.abs())*(other_room.size/other_room.size) 
		var my_rect = Rect2(grid_pos, house_one_actual_size)
		var other_rect = Rect2(other_room.grid_pos, house_two_actual_size)
		return my_rect.intersects(other_rect,true)		
enum RoomTypes{HALLWAY,KITCHEN,BEDROOM,BATHROOM,LIVINGROOM} 
const tilemap_dict = {
	RoomTypes.HALLWAY : 0,
	RoomTypes.KITCHEN : 0,
	RoomTypes.BEDROOM : 0,
	RoomTypes.BATHROOM : 0,
	RoomTypes.LIVINGROOM : 0,
}
const tile_dict = { #dict for mapping the tiles to sensible names
	"OPEN_FLOOR" : Vector2i(0,4),
	"CORNER_TOP_RIGHT" : Vector2i(3,1),
	"CORNER_TOP_LEFT" : Vector2i(0,1),
	"CORNER_BOTTOM_RIGHT" : Vector2i(2,1),
	"CORNER_BOTTOM_LEFT" : Vector2i(1,1),
	"INSIDE_VERTICAL_CORNER_TOP_RIGHT" : Vector2i(2,2),
	"INSIDE_VERTICAL_CORNER_TOP_LEFT" : Vector2i(0,2),
	"INSIDE_VERTICAL_CORNER_BOTTOM_RIGHT" : Vector2i(3,2),
	"INSIDE_VERTICAL_CORNER_BOTTOM_LEFT" : Vector2i(1,2),
	"INSIDE_HORIZONTAL_CORNER_TOP_RIGHT" : Vector2i(2,3),
	"INSIDE_HORIZONTAL_CORNER_TOP_LEFT" : Vector2i(0,3),
	"INSIDE_HORIZONTAL_CORNER_BOTTOM_RIGHT" : Vector2i(3,3),
	"INSIDE_HORIZONTAL_CORNER_BOTTOM_LEFT" : Vector2i(1,3),
	"LEFT_WALL" : Vector2i(0,0),
	"TOP_WALL" : Vector2i(2,0),
	"BOTTOM_WALL" : Vector2i(1,0),
	"RIGHT_WALL" : Vector2i(3,0),
	}

var rooms: Array[RoomRect]
var hallways: Array[RoomRect]

func _ready():
			
	for x_idx in 250:
		var x = x_idx - 125
		for y_idx in 250:
			var y = y_idx - 125
			var atlas = Vector2i(0,0)
			var grid_pos = Vector2i(x,y)*8
			sand_tilemap.set_cell(0,grid_pos,0,atlas,0)
	generate_house()
	for i in (rooms.size()):
		square_room_draw(rooms[i])
		if (i != 0):
			fill_room(rooms[i])
	for i in (hallways.size()):
		square_room_draw(hallways[i])
		fill_hallway(hallways[i])

func generate_house():
	var check : bool = true
	while check :
		rooms.clear()
		hallways.clear()
		var room_size : Vector2i = Vector2i(6,6)
		var room_pos : Vector2i = Vector2i(0,0)
		var entrance : Door = Door.new(Vector2i(2,5),Vector2i(0,1),room_pos)
		var amnt_of_hallways : int = [2,2,3].pick_random()
		var hallway_doors : Array[Door]
		print("%s : doors" %amnt_of_hallways) 
		var has_door : Array[bool] = [false,false,false]
		for i in amnt_of_hallways:
			print("run")
			var rand_dir = randi_range(0,2)
			if has_door[rand_dir]:
				i -=1
				continue
			has_door[rand_dir] = true
			if rand_dir == 0 :
				hallway_doors.append(Door.new(Vector2i(0,2),Vector2i(-1,0),room_pos))
			elif rand_dir == 1 :
				hallway_doors.append(Door.new(Vector2i(5,2),Vector2i(1,0),room_pos))
			elif rand_dir == 2 :
				hallway_doors.append(Door.new(Vector2i(2,0),Vector2i(0,-1),room_pos))
		print("done")
		var room : RoomRect = RoomRect.new(room_pos,room_size,hallway_doors,entrance)
		room.wall_has_door = has_door
		rooms.append(room)
		
		for i in range(hallway_doors.size()):
			var new_hallway = generate_hallway(room.doors[i])
			hallways.append(new_hallway)
		for x in hallways.size():
			for i in range(hallways[x].doors.size()):
				var newroom = generate_room(hallways[x].doors[i])
				rooms.append(newroom)
		check = false
		if rooms.size() < 6 :
			check = true
		for i in (rooms.size()):
			for j in (rooms.size()):
				if i != j:
					var my_rect = Rect2(rooms[i].grid_pos, rooms[i].size)
					var other_rect = Rect2(rooms[j].grid_pos, rooms[j].size)
					if my_rect.intersects(other_rect,true) :
						check = check || true
					else :
						check = check || false 
	print (rooms.size())

func square_room_draw(room : RoomRect):
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
			var atlas = Vector2i(tile_dict[tile_name])+(tilemap_dict[room.type]*Vector2i(4,0))
			if tile_name == "OPEN_FLOOR":
				atlas = Vector2i(randi_range(0,3),tile_dict[tile_name].y)+(tilemap_dict[room.type]*Vector2i(4,0))
			var grid_pos = (Vector2i(xIdx,yIdx)+room.grid_pos)*8
			tilemap.set_cell(0,grid_pos,0,atlas,0)
			
	for i in range(doors.size()):
		var tile1_name : String 
		var tile2_name : String
		if (doors[i].dir.x):
			if doors[i].relative_grid_pos.x == 0:
				tile1_name = "INSIDE_HORIZONTAL_CORNER_TOP_LEFT"
				tile2_name = "INSIDE_HORIZONTAL_CORNER_BOTTOM_LEFT"
			else :
				tile1_name = "INSIDE_HORIZONTAL_CORNER_TOP_RIGHT"
				tile2_name = "INSIDE_HORIZONTAL_CORNER_BOTTOM_RIGHT"
			var atlas1 = tile_dict[tile1_name]+(tilemap_dict[room.type]*Vector2i(4,0))
			var atlas2 = tile_dict[tile2_name]+(tilemap_dict[room.type]*Vector2i(4,0))
			
			var grid_pos_1 = (doors[i].relative_grid_pos+room.grid_pos)*8
			var grid_pos_2 = grid_pos_1+Vector2i(0,8)
			tilemap.set_cell(0,grid_pos_1,0,atlas1,0)
			tilemap.set_cell(0,grid_pos_2,0,atlas2,0)
		else:
			if doors[i].relative_grid_pos.y == 0:
				tile1_name = "INSIDE_VERTICAL_CORNER_TOP_LEFT"
				tile2_name = "INSIDE_VERTICAL_CORNER_TOP_RIGHT"
			else :
				tile1_name = "INSIDE_VERTICAL_CORNER_BOTTOM_LEFT"
				tile2_name = "INSIDE_VERTICAL_CORNER_BOTTOM_RIGHT"
			var atlas1 = tile_dict[tile1_name]+(tilemap_dict[room.type]*Vector2i(4,0))
			var atlas2 = tile_dict[tile2_name]+(tilemap_dict[room.type]*Vector2i(4,0))
			
			var grid_pos_1 =(doors[i].relative_grid_pos+room.grid_pos)*8
			var grid_pos_2 = grid_pos_1 +Vector2i(8,0)
			tilemap.set_cell(0,grid_pos_1,0,atlas1,0)
			tilemap.set_cell(0,grid_pos_2,0,atlas2,0)

func generate_room( prev_door : Door) -> RoomRect:
	var wall_has_door : Array[bool] = [false,false,false,false]
	const max_size : int = 8
	const min_size : int = 4
	var size : Vector2i = Vector2i(	randi_range(min_size,max_size),randi_range(min_size,max_size))
	var pos : Vector2i
	var pos_correction : Vector2i
	var entry_door : Door = Door.new(Vector2i(0,0),Vector2i(0,0),Vector2i(0,0)) 
	if prev_door.dir.x == -1:
		wall_has_door[0] = true
		pos.x = prev_door.global_grid_pos.x + 1 
		pos_correction = Vector2i(1,0)
		pos.y = prev_door.global_grid_pos.y - 1
	elif prev_door.dir.x == 1:
		wall_has_door[2] = true
		pos.x = prev_door.global_grid_pos.x - size.x
		pos_correction = Vector2i(-1,0)
		pos.y = prev_door.global_grid_pos.y - 1
	elif prev_door.dir.y == -1:
		wall_has_door[1] = true
		pos.y = prev_door.global_grid_pos.y + 1
		pos_correction = Vector2i(0,1)
		pos.x = prev_door.global_grid_pos.x - 1
	elif prev_door.dir.y == 1:
		wall_has_door[3] = true
		pos.y = prev_door.global_grid_pos.y - size.y
		pos_correction = Vector2i(0,-1)
		pos.x = prev_door.global_grid_pos.x - 1
	entry_door.dir = prev_door.dir 
	entry_door.relative_grid_pos = prev_door.global_grid_pos + pos_correction - pos
	entry_door.global_grid_pos = pos + entry_door.relative_grid_pos

	var room : RoomRect = RoomRect.new(pos,size,[],entry_door)
	room.wall_has_door = wall_has_door
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
		pos.x = prev_door.global_grid_pos.x - size.x 
		pos_correction = Vector2i(-1,0)
		pos.y = prev_door.global_grid_pos.y - 1
	elif prev_door.dir.x == 1:
		wall_has_door[1] = true
		size.y = 4
		pos.x = prev_door.global_grid_pos.x + 1
		pos_correction = Vector2i(1,0)
		pos.y = prev_door.global_grid_pos.y - 1
	elif prev_door.dir.y == -1:
		wall_has_door[2] = true
		size.x = 4
		pos.y = prev_door.global_grid_pos.y - size.y
		pos_correction = Vector2i(0,-1)
		pos.x = prev_door.global_grid_pos.x - 1
	elif prev_door.dir.y == 1:
		wall_has_door[3] = true
		size.x = 4
		pos.y = prev_door.global_grid_pos.y + 1
		pos_correction = Vector2i(0,1)
		pos.x = prev_door.global_grid_pos.x - 1
	entry_door.dir = prev_door.dir * -1
	entry_door.relative_grid_pos = prev_door.global_grid_pos + pos_correction - pos
	entry_door.global_grid_pos = pos + entry_door.relative_grid_pos
	#make the doors in the hallway
	var door_amnt : int = [2,2,2,3].pick_random()
	var doors : Array[Door] 
	for i in (door_amnt):
		var door_dir = randi_range(0,3)
		if wall_has_door[door_dir]:
			i -=1
			continue
		wall_has_door[door_dir] = true
		var dir : Vector2i
		var door_pos : Vector2i
		if door_dir == 0:
			dir = Vector2i(-1,0)
			door_pos.x = size.x-1
			if size.y == 4:
				door_pos.y = 1
			else: 
				door_pos.y = randi_range(1,size.y-4)
		elif door_dir == 1:
			dir = Vector2i(1,0)
			door_pos.x = 0
			if size.y == 4:
				door_pos.y = 1
			else: 
				door_pos.y = randi_range(1,size.y-4)
		elif door_dir == 2:
			dir = Vector2i(0,-1)
			door_pos.y = size.y-1
			if size.x == 4:
				door_pos.x = 1
			else: 
				door_pos.x = randi_range(1,size.x-4)
		elif door_dir == 3:
			dir = Vector2i(0,1)
			door_pos.y = 0
			if size.x == 4:
				door_pos.x = 1
			else: 
				door_pos.x = randi_range(1,size.x-4)
		var new_door : Door = Door.new(door_pos,dir,pos)
		doors.append(new_door)
	var room : RoomRect = RoomRect.new(pos,size,doors,entry_door)
	room.type = RoomTypes.HALLWAY
	return room

func fill_room(room : RoomRect):
	var min_items : int
	var max_items : int 
	var center_types : Array[PackedScene] = [big_table_1]
	var wall_types : Array[PackedScene] = [big_table_1]
	var weights : Array[bool] = [true,false]
	if room.type == RoomTypes.BATHROOM:
		min_items = 4
		max_items = 6
		#append center furniture
		center_types.append(box_1)
		center_types.append(box_2)
		center_types.append(lamp)
		#append wall furniture
		wall_types.append(closet)
		wall_types.append(tub)
		wall_types.append(sink_1)
		wall_types.append(sink_2)
		wall_types.append(toilet)
		weights.append(false)
		weights.append(false)
		
	if room.type == RoomTypes.BEDROOM:
		min_items = 3
		max_items = 8
		#append center furniture
		center_types.append(box_1)
		center_types.append(box_2)
		center_types.append(lamp)
		center_types.append(big_couch)
		center_types.append(couch)
		#append wall furniture
		wall_types.append(bed)
		wall_types.append(closet)
		wall_types.append(open_dresser)
		weights.append(false)
		
	if room.type == RoomTypes.KITCHEN:
		min_items = 4
		max_items = 7
		#append center furniture
		center_types.append(box_1)
		center_types.append(box_2)
		center_types.append(lamp)
		center_types.append(big_table_1)
		center_types.append(big_table_2)
		center_types.append(table_chair_1)
		center_types.append(table_chair_2)
		#append wall furniture
		wall_types.append(stove)
		wall_types.append(fridge)
		wall_types.append(kitchen_sink)
		weights.append(false)
	if room.type == RoomTypes.LIVINGROOM:
		min_items = 3
		max_items = 6
		#append center furniture
		center_types.append(box_1)
		center_types.append(box_2)
		center_types.append(lamp)
		center_types.append(rolling_chair)
		center_types.append(fish_coffee_table)
		center_types.append(big_couch)
		center_types.append(couch)
		#append wall furniture
		wall_types.append(computer_desk)
		wall_types.append(closet)
		wall_types.append(tv)
	fill(randi_range(min_items,max_items),center_types,wall_types,room,weights)

func fill_hallway(room : RoomRect):
	var min_items = 0
	var max_items = 2
	var center_types : Array[PackedScene] 
	var wall_types : Array[PackedScene] 
	var weights : Array[bool] = [true,false]
	#append center rooms
	center_types.append(box_1)
	center_types.append(box_2)
	center_types.append(lamp)
	#append wall rooms
	wall_types.append(closet)
	fill(randi_range(min_items,max_items),center_types,wall_types,room,weights)
	
func fill(item_amount : int, center_types : Array[PackedScene],wall_types : Array[PackedScene],room : RoomRect, weight :Array[bool]):
	if (center_types.size() == 0 && wall_types.size() == 0 ):
		pass
	for i in (item_amount):
		if weight.pick_random():
			if (center_types.size() == 0):
				i -=1
				continue
			var spawn_info = get_available_center_location(room)
			var child = center_types.pick_random().instantiate()
			add_child(child)
			child.global_position = spawn_info.position
			child.global_rotation = spawn_info.angle
		else : 
			if (wall_types.size() == 0):
				i -=1
				continue
			var spawn_info = get_available_wall_location(room)
			var child = wall_types.pick_random().instantiate()
			if (spawn_info.position == Vector2(100000000,100000000)):
				i -=1
				continue
			add_child(child)
			child.global_position = spawn_info.position
			child.global_rotation = spawn_info.angle


func get_available_wall_location(room : RoomRect) -> SpawnInfo:
	var possible_walls : int = 0
	var spawn_rects : Array[DualPos] =[
		DualPos.new(
			tilemap.map_to_local(Vector2(Vector2(room.grid_pos) +Vector2(room.size.x-1,0.2))*8*2.5),
			tilemap.map_to_local((Vector2(room.grid_pos) + Vector2(room.size) + Vector2(-1.2,-1))*8*2.5)
			),
		DualPos.new(
			tilemap.map_to_local((Vector2(room.grid_pos) + Vector2(room.size) - Vector2(room.size.x,1.2))*8*2.5),
			tilemap.map_to_local((Vector2(room.grid_pos) + Vector2(room.size) - Vector2(1,1))*8*2.5)
			),
		DualPos.new(
			tilemap.map_to_local((Vector2(room.grid_pos))*8*2.5),
			tilemap.map_to_local(Vector2(Vector2(room.grid_pos) +Vector2(0.2,room.size.y- 1))*8*2.5)
			),
		DualPos.new(
			tilemap.map_to_local((Vector2(room.grid_pos))*8*2.5),
			tilemap.map_to_local(Vector2(Vector2(room.grid_pos) + Vector2(room.size)-Vector2(1,room.size.y-0.2))*8*2.5)
			),
	] 
	for i in range(room.wall_has_door.size()):
		if !room.wall_has_door[i] :
			possible_walls +=1
	if (possible_walls == 0):
		return SpawnInfo.new(0,Vector2(100000000,100000000))
	var check : bool = false 
	var picked_wall : int = 0
	while !check:
		picked_wall = randi_range(0,3)
		if !room.wall_has_door[picked_wall]:
			check = true
			room.wall_has_door[picked_wall] = true
	var angle : float = 0
	var chosen_pos :Vector2 = Vector2(randf_range(spawn_rects[picked_wall].top_left.x,spawn_rects[picked_wall].bottom_right.x),randf_range(spawn_rects[picked_wall].top_left.y,spawn_rects[picked_wall].bottom_right.y))
	if (picked_wall == 0):
		angle = PI/2
	elif (picked_wall == 1):
		angle = PI
	elif (picked_wall == 2):
		angle = PI + PI/2
	elif (picked_wall == 3):
		angle = 0
	
	return SpawnInfo.new(angle,chosen_pos)
	
func get_available_center_location(room:RoomRect) -> SpawnInfo:
	var top_left : Vector2 = (Vector2(room.grid_pos)+Vector2(1,1))*8*2.5
	var bottom_right : Vector2 = (room.grid_pos +(room.size-Vector2i(2,2)))*8*2.5
	top_left = tilemap.map_to_local(top_left)
	bottom_right = tilemap.map_to_local(bottom_right)
	var chosen_pos :Vector2 = Vector2(randf_range(top_left.x,bottom_right.x),randf_range(top_left.y,bottom_right.y))
	var angle = [0,PI/2,PI,PI+PI/2].pick_random()
	return SpawnInfo.new(angle,chosen_pos)
