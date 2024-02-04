tool
extends EditorPlugin

const helper_ui = preload("res://addons/mazeGen3D/mazeGenGUI.tscn")
var helper_instance

func _enter_tree():
	helper_instance = helper_ui.instance()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, helper_instance)
	

func has_main_screen():
	return true

func _exit_tree():
	if helper_instance:
		remove_control_from_docks(helper_instance)
		helper_instance.queue_free()

func make_visible(visible):
	if helper_instance:
		helper_instance.visible = visible

func get_plugin_name():
	return "Maze Generator"

func get_plugin_icon():
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
