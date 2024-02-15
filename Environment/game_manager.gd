extends CanvasLayer
class_name GameManager

@export var background : ColorRect
@export var title_text : Label
@export var manager_holder : TextureRect
@export_file var menu_path : String

@export var number_holder : TextureRect
@export var _3tex : Texture2D
@export var _2tex : Texture2D
@export var _1tex : Texture2D


@export var tex_bg : TextureRect



func _ready():
	get_tree().paused = true

	background.color.a = 0.6
	title_text.self_modulate.a = 0
	number_holder.modulate.a = 0
	const text_delay : float = 3

	var tween := get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(manager_holder, "modulate:a", 1, 0.3)

	tween.tween_callback(set_text.bind("Poseidon's waiting!"))
	tex_bg.modulate.a = 0
	tween.parallel().tween_property(tex_bg, "modulate:a", 1, 0.2)

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
	tween.tween_callback(set_text.bind(""))
	tween.parallel().tween_property(tex_bg, "modulate:a", 0, 0.2)
	tween.tween_callback(set_texture.bind(3))

	var num_holder_og_scale : Vector2 = number_holder.scale
	number_holder.scale = Vector2.ZERO
	tween.tween_property(number_holder, "modulate:a", 1, 0.3)
	tween.parallel().tween_property(number_holder, "scale", num_holder_og_scale, 0.4)

	tween.tween_property(number_holder, "self_modulate:a", 1, 0.1)
	tween.tween_interval(0.8)
	tween.tween_property(number_holder, "self_modulate:a", 0, 0.1)

	tween.tween_callback(set_texture.bind(2))


	tween.tween_property(number_holder, "self_modulate:a", 1, 0.1)
	tween.parallel().tween_property(number_holder, "scale", num_holder_og_scale * 1.1, 0.1)
	tween.tween_interval(0.6)
	tween.parallel().tween_property(number_holder, "scale", num_holder_og_scale, 0.1)
	tween.tween_property(number_holder, "self_modulate:a", 0, 0.1)

	tween.tween_property(manager_holder, "modulate:a", 0, 0.2)

	tween.tween_callback(set_texture.bind(1))


	tween.tween_property(number_holder, "self_modulate:a", 1, 0.1)
	tween.parallel().tween_property(number_holder, "scale", num_holder_og_scale * 1.1, 0.1)
	tween.tween_interval(0.6)
	tween.parallel().tween_property(number_holder, "scale", num_holder_og_scale, 0.1)
	tween.tween_property(number_holder, "self_modulate:a", 0, 0.1)

	tween.tween_property(background, "color:a", 0, 0.7)

	var cam = get_tree().get_first_node_in_group("cam")
	tween.tween_property(cam, "global_position", Vector2(100, 100), 0.2)


	tween.tween_callback(unpause)

func set_text(stri : String):
	title_text.text = stri


func unpause():
	get_tree().paused = false
	EventBus.increase_intensity.emit()




func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(menu_path)


func set_texture(index : int):
	match index:
		1:
			number_holder.texture = _1tex
		2:
			number_holder.texture = _2tex
		3:
			number_holder.texture = _3tex


func enable_text_bg(val : bool):
	tex_bg.vsible = val
