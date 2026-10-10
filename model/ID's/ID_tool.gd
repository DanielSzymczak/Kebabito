@tool
extends EditorScript

func _run():
	var total_objects = 5
	var folder_path = "res://model/ID's/item/"
	var object_name : String = "item_ID"
	
	# 1. Ensure the directory exists
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_recursive_absolute(folder_path)
		print("Created directory: ", folder_path)

	# 2. Loop to create files
	for i in range(1, total_objects + 1):
		var new_id = CrafterID.new()
		
		# Set the internal name (e.g., "crafter1")
		var display_name = object_name + str(i)
		new_id.id_name = display_name
		
		# Define the file path (e.g., "res://data/crafters/crafter1.tres")
		var file_path = folder_path + display_name + ".tres"
		
		# 3. Save to disk
		var error = ResourceSaver.save(new_id, file_path)
		
		if error == OK:
			print("Successfully created: ", file_path)
		else:
			print("Failed to save ", display_name, ". Error code: ", error)
			
	# Update the FileSystem dock so they appear immediately
	get_editor_interface().get_resource_filesystem().scan()
