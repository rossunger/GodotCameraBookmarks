extends HBoxContainer

@export var bookmark: Transform3D

func get_name_control():
	return $BookmarkName
	
func get_delete_control():
	return $DeleteButton

func get_GoToBookmark_control():
	return $GoToBookmark
	
