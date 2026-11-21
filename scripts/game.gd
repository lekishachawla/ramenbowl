
extends Control

var score = 0
var lives = 3
var salvage_available = false

var selected_noodles = ""
var selected_broth = ""
var selected_topping = ""

var noodles = ["Thick", "Thin", "Curly"]
var broths = ["Pork", "Miso", "Shoyu"]
var toppings = ["Egg", "Corn", "Mushroom"]

var current_order = {}

func _ready():
	$Noodlesbutton.pressed.connect(_on_noodles_pressed)
	$Brothbutton.pressed.connect(_on_broth_pressed)
	$Toppingsbutton.pressed.connect(_on_toppings_pressed)
	$Servebutton.pressed.connect(_on_serve_pressed)
	$Salvagebutton.pressed.connect(_on_salvage_pressed)
	$Salvagebutton.hide()
	$RestartButton.pressed.connect(_on_restart_pressed)

	$GameOverLabel.hide()
	$FinalScoreLabel.hide()
	$RestartButton.hide()
	
	new_order()

func new_order():
	current_order = {
		"noodles": noodles.pick_random(),
		"broth": broths.pick_random(),
		"topping": toppings.pick_random()
	}

	selected_noodles = ""
	selected_broth = ""
	selected_topping = ""
	salvage_available = false

	$Noodlesbutton.text = "NOODLES"
	$Brothbutton.text = "BROTH"
	$Toppingsbutton.text = "TOPPINGS"

	$orderlabel.text = "CUSTOMER ORDER\nNoodles: " + current_order["noodles"] + "\nBroth: " + current_order["broth"] + "\nTopping: " + current_order["topping"]

	update_display()

func _on_noodles_pressed():
	selected_noodles = noodles.pick_random()
	$Noodlesbutton.text = selected_noodles

func _on_broth_pressed():
	selected_broth = broths.pick_random()
	$Brothbutton.text = selected_broth

func _on_toppings_pressed():
	selected_topping = toppings.pick_random()
	$Toppingsbutton.text = selected_topping

func _on_serve_pressed():
	if selected_noodles == "" or selected_broth == "" or selected_topping == "":
		$orderlabel.text = "Choose all ingredients first!"
		
		
		
		
		return

	var correct = (
		selected_noodles == current_order["noodles"]
		and selected_broth == current_order["broth"]
		and selected_topping == current_order["topping"]
	)

	if correct:
		if salvage_available:
			score += 150
			$orderlabel.text = "SALVAGED! +150 POINTS!"
		else:
			score += 100
			$orderlabel.text = "PERFECT RAMEN! +100!"

		update_display()
		await get_tree().create_timer(1.5).timeout
		new_order()

	else:
		if not salvage_available:
			salvage_available = true
			$Salvagebutton.show()
			
			$orderlabel.text = "WRONG ORDER!\nUse your chance again!"
		else:
			lives -= 1
			salvage_available = false
			$Salvagebutton.hide()
			update_display()

			if lives <= 0:
				game_over()
			else:
				$orderlabel.text = "SALVAGE FAILED!\nNext customer coming..."
				await get_tree().create_timer(1.5).timeout
				new_order()

func update_display():
	$Scorelabel.text = "SCORE: " + str(score)
	$Liveslabel.text = "LIVES: " + "❤️".repeat(lives)

func game_over():
	$GameOverLabel.show()
	$FinalScoreLabel.text = "FINAL SCORE: " + str(score)
	$FinalScoreLabel.show()
	$RestartButton.show()

	$Noodlesbutton.disabled = true
	$Brothbutton.disabled = true
	$Toppingsbutton.disabled = true
	$Servebutton.disabled = true
	$Salvagebutton.hide()

func _on_salvage_pressed():
	$Salvagebutton.hide()
	selected_noodles = ""
	selected_broth = ""
	selected_topping = ""

	$Noodlesbutton.text = "NOODLES"
	$Brothbutton.text = "BROTH"
	$Toppingsbutton.text = "TOPPINGS"

	$orderlabel.text = "SALVAGE ACTIVATED!\nTry this order again!"
	
	
func _on_restart_pressed():
	get_tree().reload_current_scene()
