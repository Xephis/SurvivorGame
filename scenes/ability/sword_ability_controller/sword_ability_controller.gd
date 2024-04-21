extends Node

const MAX_RANGE = 150
@export var sword_ability: PackedScene
var damage = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	# get the player and enemies
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	
	# filter enemies that are further than MAX_RANGE away.
	enemies = enemies.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	if enemies.size() == 0:
		return
	
	# get the closest enemy
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	
	#instantiate sword at enemy[0] in the array of enemies (closest)
	var sword_instance = sword_ability.instantiate() as SwordAbility
	player.get_parent().add_child(sword_instance)
	sword_instance.hitbox_component.damage = damage
	sword_instance.global_position = enemies[0].global_position
	#randomise sword location by 2*pi (TAU) * 4 around the enemy position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	
	var enemy_direction = enemies[0].global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()
