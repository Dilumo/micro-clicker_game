extends Node

# Troca para a cena especificada
func go_to_scene(scene_path: String):
	if ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)
	else:
		print("A cena não existe: ", scene_path)
