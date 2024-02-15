extends Node2D
class_name Menu

@export var music : AudioStream
@export var game_start : AudioStream

@export var ripple_rect : ColorRect
@export var fade_rect : ColorRect

@export var solo_scene : PackedScene
@export var coop_scene : PackedScene

@export var music_player : AudioStreamPlayer
@export var start_player : AudioStreamPlayer

func _ready():
	music_player.play()


func _on_solo_pressed():
	music_player.stop()
	start_player.play()

	var mat := ripple_rect.material as ShaderMaterial
	mat.set_shader_parameter("height", mat.get_shader_parameter("height") * 7)

	var tween := get_tree().create_tween()
	tween.tween_property(fade_rect, "color:a", 1, 2)
	tween.tween_interval(1)
	tween.tween_callback(load_solo)



func _on_coop_pressed():
	music_player.stop()
	start_player.play()

	var mat := ripple_rect.material as ShaderMaterial
	mat.set_shader_parameter("height", mat.get_shader_parameter("height") * 7)

	var tween := get_tree().create_tween()
	tween.tween_property(fade_rect, "color:a", 1, 2)
	tween.tween_interval(1)
	tween.tween_callback(load_coop)



func load_solo():
	get_tree().change_scene_to_packed(solo_scene)


func load_coop():
	get_tree().change_scene_to_packed(coop_scene)


func _on_quit_pressed():
	get_tree().quit()
