extends TileMapLayer

func _ready() -> void:
	var blocks = _find_connected_platforms()
	
	for block in blocks:
		if block.is_empty(): continue
		
		# 1. Bereken het centrum van het platform op basis van alle cellen
		var min_x = block[0].x
		var max_x = block[0].x
		var min_y = block[0].y
		var max_y = block[0].y
		
		for cell in block:
			min_x = min(min_x, cell.x)
			max_x = max(max_x, cell.x)
			min_y = min(min_y, cell.y)
			max_y = max(max_y, cell.y)
			
		# Bereken de gemiddelde grid-cel en zet deze om naar wereldpixels
		var center_cell = Vector2((min_x + max_x) / 2.0, (min_y + max_y) / 2.0)
		# We gebruiken map_to_local om de exacte pixelpositie te krijgen
		var world_center = map_to_local(Vector2i(floor(center_cell.x), floor(center_cell.y)))
		
		# 2. Maak het losse platform aan en zet het op de juiste plek in de wereld
		var platform = AnimatableBody2D.new() # Of StaticBody2D
		platform.global_position = world_center
		get_parent().add_child.call_deferred(platform)
		
		# 3. Maak de visuele laag aan ALS KIND van het platform
		var platform_layer = TileMapLayer.new()
		platform_layer.tile_set = tile_set
		platform.add_child(platform_layer)
		
		# Compenseer de positie van de layer zodat de tegels rondom het nieuwe middelpunt staan
		platform_layer.position = -world_center
		
		# 4. Verplaats de tegels van de hoofdmap naar het nieuwe platform
		for cell in block:
			var source_id = get_cell_source_id(cell)
			var atlas_coords = get_cell_atlas_coords(cell)
			var alternative_tile = get_cell_alternative_tile(cell)
			
			platform_layer.set_cell(cell, source_id, atlas_coords, alternative_tile)
			set_cell(cell, -1) # Verwijder uit de hoofdmap

# Het algoritme dat groepen van 1 of meer blokken zoekt
func _find_connected_platforms() -> Array:
	var visited = {}
	var platforms = []
	var all_cells = get_used_cells()
	
	for cell in all_cells:
		if cell in visited:
			continue
			
		var current_platform = []
		var queue = [cell]
		visited[cell] = true
		
		while queue.size() > 0:
			var current = queue.pop_front()
			current_platform.append(current)
			
			var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
			for dir in directions:
				var neighbor = current + dir
				if neighbor in all_cells and not neighbor in visited:
					visited[neighbor] = true
					queue.append(neighbor)
					
		platforms.append(current_platform)
	return platforms
