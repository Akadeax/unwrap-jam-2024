extends CanvasLayer
class_name GameManager

@export var background : ColorRect
@export var title_text : Label
@export var manager_holder : TextureRect
@export_file var menu_path : String

func _ready():
	get_tree().paused = true

	background.color.a = 0.4
	title_text.self_modulate.a = 0

	const text_delay : float = 3

	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.tween_property(manager_holder, "modulate:a", 1, 0.3)

	tween.tween_callback(set_text.bind("Poseidon's waiting!"))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.5)
	tween.tween_interval(text_delay)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.2)


	tween.tween_callback(set_text.bind("Bring back as much furniture as possible,"))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.2)
	tween.tween_interval(text_delay)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.2)

	tween.tween_callback(set_text.bind("And throw it into your Poseidovan™."))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.2)
	tween.tween_interval(text_delay)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.2)

	tween.tween_callback(set_text.bind("Don't you dare break any!"))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.2)
	tween.tween_interval(text_delay)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.2)

	tween.tween_callback(set_text.bind("In 3..."))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.1)
	tween.tween_interval(0.8)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.1)

	tween.tween_callback(set_text.bind("In 2..."))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.1)
	tween.tween_interval(0.8)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.1)

	tween.tween_callback(set_text.bind("In 1..."))

	tween.tween_property(title_text, "self_modulate:a", 1, 0.1)
	tween.tween_interval(0.8)
	tween.tween_property(title_text, "self_modulate:a", 0, 0.1)

	tween.tween_property(background, "color:a", 0, 0.7)

	var cam = get_tree().get_first_node_in_group("cam")
	tween.tween_property(cam, "global_position", Vector2(100, 100), 1)

	tween.tween_property(manager_holder, "modulate:a", 0, 0.3)

	tween.tween_callback(unpause)

func set_text(stri : String):
	title_text.text = stri


func unpause():
	get_tree().paused = false
	EventBus.increase_intensity.emit()
	



func _on_menu_pressed():
	get_tree().change_scene_to_file(menu_path)
