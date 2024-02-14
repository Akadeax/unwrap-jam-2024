extends Node

signal objectDroppedOff(type : PickupObject.Type, damage_percentage : float)

signal objectDestroyed(type : PickupObject.Type)

signal scoreUpdate(current_score : int)

signal amntUpdate(amount_of_objects : Array[int])

signal totalUpdate(current_score : int,amount_of_objects : Array[int])

signal damagesUpdate(total_damage_cost : int)


signal time_over()
