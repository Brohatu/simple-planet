@tool
class_name PlateHandler extends Node3D

#var tectonic_plates:Array[TectonicPlate]
#var planet_mesh:GeometryMesh

#region methods
static func generate_tectonic_plates(planet_mesh:GeometryMesh, data:PlanetData) -> Array[TectonicPlate]:
	# Initialise temp TectonicPlate array.
	var tps:Array[TectonicPlate] = []
	tps.resize(data.number_of_plates)
	## Array of unassigned Polygons.
	var unassigned_tiles:Array[Polygon] = Array(planet_mesh.polygons.duplicate())
	
	# Select a random seed tile for each TectonicPlate.
	for tpi in range(tps.size()):
		## Randomly selected index.
		var selection := randi_range(0, unassigned_tiles.size() - 1) 
		## Random seed polygon.
		var p:Polygon = unassigned_tiles.pop_at(selection)
		## Index of seed polygon
		var pi := p.center_vertex_index 
		# Create new plate at plate index tpi
		tps[tpi] = TectonicPlate.new()
		# Push seed plate index to plate
		tps[tpi].tile_indices.push_back(p.center_vertex_index)
		tps[tpi].seed_tile_index = pi
		# Assign drift axis to plate
		tps[tpi].drift_vector = Vector3(randf_range(-1.0,1.0),randf_range(-1.0,1.0),randf_range(-1.0,1.0)).normalized()
		# Assign drift direction to seed polyofon
		p.drift_vector = tps[tpi].drift_vector.cross(p.get_centre_vertex())
		#$DirectionVectors.add_child(p.draw_drift_direction())
		#p.colour = tps[tpi].plate_colour
		#p.colour = Color.BLACK
	
	# Tiles go to closest plate seed
	#voronoi_plates(planet_mesh, tps, unassigned_tiles)
	
	# Plates are expanded at random
	random_fill_plates(planet_mesh, tps, unassigned_tiles)
	
	# Calculate tile dependent plate data for each plate
	for tp in tps:
		tp.parent_mesh = planet_mesh
		#var rotation_vector = tp.draw_rotation_vector()
		#add_child(rotation_vector)
		tp.calculate_edge_tiles()
	
	# Fuse nearby plates a few times to get less blocky shapes
	@warning_ignore("integer_division")
	for i in range(tps.size()/5):
		var tp1:TectonicPlate = tps.pick_random()
		var indices_tp1 := Array(tp1.edge_tile_indices)
		var edge1:int = planet_mesh.polygons[indices_tp1.pick_random()].index
		var edge2:int
		for pi in planet_mesh.polygons[edge1].adjacent_polygon_indices:
			if not indices_tp1.has(pi):
				edge2 = planet_mesh.polygons[pi].index
				break
		
		var tp2:TectonicPlate
		for tp in tps:
			if tp.tile_indices.has(edge2):
				tp2 = tp
				break
		
		#fuse_plates(tp1, tp2)
		#tps.erase(tp2)
	
	# Assign Oceanic plates
	tps = assign_oceanic_plates(tps,data)
	
	# Assign polygon colours
	for tp in tps:
		for pi in tp.tile_indices:
			planet_mesh.polygons[pi].colour = tp.plate_colour
	
	return tps


static func voronoi_plates(planet_mesh:GeometryMesh, tps:Array[TectonicPlate], unassigned_tiles:Array[Polygon]):
	# Assign each tile to the closest seed tile. 
	while unassigned_tiles.size() > 0:
		var p:Polygon = unassigned_tiles.pop_back()
		## Index of Polygon p
		var pi := p.center_vertex_index
		## The current best plate for the tile. 
		var closest_plate:TectonicPlate
		
		for tp in tps:
			## The position of the seed tile.
			var seed_tile_pos := planet_mesh.vertices[tp.seed_tile_index]
			## The position of the current tile.
			var current_tile_pos := planet_mesh.vertices[pi]
			# Using distance squared is faster than distance for comparing
			# vectors.
			var dist_2 = current_tile_pos.distance_squared_to(seed_tile_pos)
			
			if dist_2 < p.dist_to_seed:
				closest_plate = tp
				p.dist_to_seed = dist_2
		
		closest_plate.tile_indices.push_back(pi)
		p.drift_vector = closest_plate.drift_vector.cross(p.get_centre_vertex())
		#$DirectionVectors.add_child(p.draw_drift_direction())
		#p.colour = closest_plate.plate_colour


static func random_fill_plates(planet_mesh:GeometryMesh, tps:Array[TectonicPlate], unassigned_tiles:Array[Polygon]):
	while unassigned_tiles.size() > 0:
		for tp in tps:
			var indices = Array(tp.tile_indices)
			var new_tile
			var tile_to_expand = planet_mesh.polygons[indices.pick_random()]
			new_tile = planet_mesh.polygons[tile_to_expand.adjacent_polygon_indices.pick_random()]
			if new_tile in unassigned_tiles:
				tp.tile_indices.push_back(new_tile.center_vertex_index)
				unassigned_tiles.erase(new_tile)
				new_tile.drift_vector = tp.drift_vector.cross(new_tile.get_centre_vertex())
				new_tile.colour = tp.plate_colour
				#print("Tiles remaining: ", unassigned_tiles.size())
				#$DirectionVectors.add_child(new_tile.draw_drift_direction())


static func assign_oceanic_plates(tps:Array[TectonicPlate], data:PlanetData):
	var ratio := data.tectonic_plate_ratio
	var continental_plates:Array[TectonicPlate] = []
	for i in range(tps.size() * ratio):
		var selected_plate = 0
		while !selected_plate:
			selected_plate = tps.pick_random()
			if not continental_plates.has(selected_plate):
				selected_plate.continental = true
				continental_plates.push_back(selected_plate)
			else:
				selected_plate = 0
	
	#for tp in tps:
		#if tp.continental:
			#tp.plate_colour = Color.DARK_GREEN
		#else:
			#tp.plate_colour = Color.BLUE
	
	return tps


static func fuse_plates(tp1:TectonicPlate, tp2:TectonicPlate):
	tp1.plate_colour = Color.RED
	tp2.plate_colour = Color.BLUE
	tp1.tile_indices.append_array(tp2.tile_indices)

#endregion
