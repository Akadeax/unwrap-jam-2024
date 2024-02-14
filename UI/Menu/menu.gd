extends Node2D
class_name Menu

@export var music : AudioStream
@export var game_start : AudioStream

@export var ripple_rect : ColorRect
@export var fade_rect : ColorRect

@export var game_scene : PackedScene

func _ready():
	SoundManager.play_music(music)


func _on_play_pressed():
	SoundManager.stop_music(0.3)
	SoundManager.play_ui_sound(game_start)

	var mat := ripple_rect.material as ShaderMaterial
	mat.set_shader_parameter("height", mat.get_shader_parameter("height") * 7)

	var tween := get_tree().create_tween()
	tween.tween_property(fade_rect, "color:a", 1, 2)
	tween.tween_interval(1)
	tween.tween_callback(load_game)


func load_game():
	get_tree().change_scene_to_packed(game_scene)


func _on_quit_pressed():
	get_tree().quit()
