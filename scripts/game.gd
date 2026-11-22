extends Control

@onready var noodlesbutton = $"game background/Noodlesbutton"
@onready var brothbutton = $"game background/Brothbutton"
@onready var toppingsbutton = $"game background/Toppingsbutton"
@onready var servebutton = $"game background/Servebutton"
@onready var salvagebutton = $"game background/Salvagebutton"
@onready var restartbutton = $"game background/RestartButton"
@onready var game_over_label: Label = $"game background/GameOverLabel"
@onready var final_score_label: Label = $"game background/FinalScoreLabel"
@onready var scorelabel: Label = $"game background/Scorelabel"
@onready var liveslabel: Label = $"game background/Liveslabel"
@onready var ingredients_title: Label = $"game background/ingredients title"
@onready var orderlabel: Label = $"game background/orderlabel"
@onready var level_label: Label = $"game background/LevelLabel"


var score = 0
var lives = 3
var salvage_available = false

var selected_noodles = ""
var selected_broth = ""
var selected_topping = ""

var noodles = ["Thick", "Thin", "Curly", "Wavy", "Udon", "Rice"]	
var broths = ["Pork", "Miso", "Shoyu", "Tonkotsu", "Spicy", "Sesame"]
var toppings = ["Egg", "Corn", "Mushroom", "Spring Onion", "Seaweed", "Tofu"]

var current_order = {}
var patience_speed: float = 5.0
var patience: float = 100.0
var level: int = 1

func _ready():
	noodlesbutton.pressed.connect(_on_noodles_pressed)
	brothbutton.pressed.connect(_on_broth_pressed)
	toppingsbutton.pressed.connect(_on_toppings_pressed)
	servebutton.pressed.connect(_on_serve_pressed)
	salvagebutton.pressed.connect(_on_salvage_pressed)
	restartbutton.pressed.connect(_on_restart_pressed)

	salvagebutton.hide()
	game_over_label.hide()
	final_score_label.hide()
	restartbutton.hide()

	new_order()
func _process(delta):
	patience -= patience_speed * delta
	patience = max(patience, 0)
	if patience <= 0:
		lives -= 1
		patience = 100 # Reset patience so it doesn't trigger every single frame
		update_display()

	if lives <= 0:
		game_over()


func new_order():
	current_order = {
		"noodles": noodles.pick_random(),
		"broth": broths.pick_random(),
		"topping": toppings.pick_random()
	}
	
	patience = 100

	selected_noodles = ""
	selected_broth = ""
	selected_topping = ""
	salvage_available = false

	noodlesbutton.text = "NOODLES"
	brothbutton.text = "BROTH"
	toppingsbutton.text = "TOPPINGS"

	orderlabel.text = "CUSTOMER ORDER\nNoodles: " + current_order["noodles"] + "\nBroth: " + current_order["broth"] + "\nTopping: " + current_order["topping"]
	update_display()


func update_display():
	if score >= 1000:
		level = 3
		patience_speed = 9.0
	elif score >= 500:
		level = 2
		patience_speed = 7.0
	else:
		level = 1
		patience_speed = 5.0

	level_label.text = "LEVEL: " + str(level)
	scorelabel.text = "SCORE: " + str(score)
	liveslabel.text = "LIVES: " + "❤️".repeat(lives)


func _on_noodles_pressed():
	selected_noodles = noodles.pick_random()
	noodlesbutton.text = selected_noodles



func _on_broth_pressed():
	selected_broth = broths.pick_random()
	brothbutton.text = selected_broth



func _on_toppings_pressed():
	selected_topping = toppings.pick_random()
	toppingsbutton.text = selected_topping

	



func _on_serve_pressed():
	if selected_noodles == "" or selected_broth == "" or selected_topping == "":
		orderlabel.text = "Choose all ingredients first!"
		return

	var correct = (
		selected_noodles == current_order["noodles"]
		and selected_broth == current_order["broth"]
		and selected_topping == current_order["topping"]
	)

	if correct:
		if salvage_available:
			score += 150
			orderlabel.text = "SALVAGED! +150 POINTS!"
		else:
			score += 100
			orderlabel.text = "PERFECT RAMEN! +100!"

		update_display()
		await get_tree().create_timer(1.5).timeout
		new_order()

	else:
		if not salvage_available:
			salvage_available = true
			salvagebutton.show()
			orderlabel.text = "WRONG ORDER!\nUse your chance again!"
		else:
			lives -= 1
			salvage_available = false
			salvagebutton.hide()
			update_display()

			if lives <= 0:
				game_over()
			else:
				orderlabel.text = "SALVAGE FAILED!\nNext customer coming..."
				await get_tree().create_timer(1.5).timeout
				new_order()


func game_over():
	game_over_label.show()
	final_score_label.text = "FINAL SCORE: " + str(score)
	final_score_label.show()
	restartbutton.show()

	noodlesbutton.disabled = true
	brothbutton.disabled = true
	toppingsbutton.disabled = true
	servebutton.disabled = true
	salvagebutton.hide()


func _on_salvage_pressed():
	salvagebutton.hide()
	selected_noodles = ""
	selected_broth = ""
	selected_topping = ""

	noodlesbutton.text = "NOODLES"
	brothbutton.text = "BROTH"
	toppingsbutton.text = "TOPPINGS"

	orderlabel.text = "SALVAGE ACTIVATED!\nTry this order again!"
	
	
func _on_restart_pressed():
	get_tree().reload_current_scene()
