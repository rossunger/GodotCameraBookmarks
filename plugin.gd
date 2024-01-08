@tool
extends EditorPlugin

var popup_scene = preload("res://addons/CameraBookmarks/popup.tscn")
var popup: Popup
var bookmark_scene = preload("res://addons/CameraBookmarks/bookmark_details.tscn")

var add_camera_button = Button.new()

@export var current_bookmark = -1: 
	set(value): 
		current_bookmark = value
		add_camera_button.text = str(current_bookmark+1, "/", bookmarks.size())

@export var bookmarks = []
@export var bookmark_names = []
var editor_camera: Camera3D

func _enter_tree() -> void:
	add_camera_button.flat = true
	#add_camera_button.text = "Add Camera"
	add_camera_button.icon = preload("res://addons/CameraBookmarks/camera_bookmark.svg")
	add_camera_button.pressed.connect(_on_bookmark_button_pressed)	
	add_camera_button.gui_input.connect(_on_bookmark_button_gui_input)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, add_camera_button)

func _ready():	
	var _editor_cameras : Array = find_cameras(get_editor_interface().get_base_control())	
	editor_camera = _editor_cameras[0]	
	if ProjectSettings.has_setting("CameraBookmarks/bookmarks"):		
		bookmarks = ProjectSettings.get_setting("CameraBookmarks/bookmarks")
		bookmark_names = ProjectSettings.get_setting("CameraBookmarks/bookmark_names")
		if bookmarks.size() > 0:			
			go_to_bookmark(0)
			add_camera_button.text = str(current_bookmark, "/", bookmarks.size())
	else:
		ProjectSettings.set_setting("CameraBookmarks/bookmarks", [])
		ProjectSettings.set_setting("CameraBookmarks/bookmark_names", [])
	ProjectSettings.set_as_internal("CameraBookmarks/bookmarks", false)
	ProjectSettings.set_as_internal("CameraBookmarks/bookmark_names", false)
	popup = popup_scene.instantiate()
	add_camera_button.add_child(popup)		

func find_cameras(n : Node):
	var result = []
	var has_path = str(n.get_path()).contains("Node3DEditorViewport")
	if n is Camera3D and has_path:
		result.append(n)		
	else:	
		for c in n.get_children():
			var cams = find_cameras(c)
			if cams.size()>0:
				result.append_array(cams)
	return result
#	
func _on_bookmark_button_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		popup.popup(Rect2i(popup.get_parent().global_position+Vector2(0, 35),popup.size))		
		setup_popup()		
		
func _on_bookmark_button_pressed():
	if Input.is_key_pressed(KEY_CTRL):
		#Add Camera at current view	
		if Input.is_key_pressed(KEY_SHIFT):			
			get_undo_redo().create_action("Add Camera From View")
			var new_camera := Camera3D.new()
			new_camera.transform = editor_camera.transform
			get_undo_redo().add_do_reference(new_camera)
			get_undo_redo().add_do_method(get_editor_interface().get_edited_scene_root(), "add_child", new_camera)
			get_undo_redo().add_do_property(new_camera, "owner", get_editor_interface().get_edited_scene_root())
			get_undo_redo().add_undo_method(get_editor_interface().get_edited_scene_root(), "remove_child", new_camera)
			get_undo_redo().commit_action()
		else:
			#Add bookmark at view
			if not bookmarks.has(editor_camera.transform):
				bookmarks.append(editor_camera.transform)								
				bookmark_names.append(str("bookmark", bookmarks.size()))												
				ProjectSettings.set_setting("CameraBookmarks/bookmarks", bookmarks)
				ProjectSettings.set_setting("CameraBookmarks/bookmark_names", bookmark_names)
				go_to_bookmark(bookmarks.size()-1)
	else:				
		go_to_next_bookmark()

func setup_popup():	
	var container = popup.get_child(0)
	for child in container.get_children():
		child.queue_free()
	popup.size.y = 8
	for i in bookmarks.size():
		var bookmark = bookmark_scene.instantiate()
		container.add_child(bookmark)
		bookmark.bookmark = bookmarks[i]
		var name_control = bookmark.find_child("*Name*")
		name_control.text = bookmark_names[i]
		name_control.text_submitted.connect(set_bookmark_name.bind(i, name_control))
		bookmark.find_child("*Delete*").pressed.connect(delete_bookmark.bind(i))
		bookmark.find_child("*GoTo*").pressed.connect(go_to_bookmark.bind(i))

func set_bookmark_name(new_name, i, name_control):
	bookmark_names[i] = new_name
	ProjectSettings.set_setting("CameraBookmarks/bookmark_names", bookmark_names)
	name_control.release_focus()
func go_to_bookmark(i):
	current_bookmark = i
	editor_camera.transform = bookmarks[current_bookmark]
func delete_bookmark(i):
	bookmarks.remove_at(i)
	bookmark_names.remove_at(i)
	ProjectSettings.set_setting("CameraBookmarks/bookmarks", bookmarks)
	ProjectSettings.set_setting("CameraBookmarks/bookmark_names", bookmark_names)
	setup_popup()
	current_bookmark=current_bookmark

func go_to_next_bookmark():
	if bookmarks.size() > 0:
		var next = current_bookmark + 1 if current_bookmark<bookmarks.size()-1 else 0
		go_to_bookmark(next)

func _exit_tree() -> void:
	add_camera_button.queue_free()
