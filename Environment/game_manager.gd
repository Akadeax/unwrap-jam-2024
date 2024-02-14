extends Node
class_name GameManager

var current_score : int = 0
var score_display_amount : int = 0
@export var score_display : Label


func add_score(amount : int):
	current_score += amount
