extends Node

const MainMenuState = preload("res://Scripts/Logic/MainMenu/main_menu_state.gd")

var logic
var main_menu_logic = preload("res://Scenes/MainMenu/Core/main_menu_logic.tscn")

var ui
var main_menu_ui_instance: Node = null
var main_menu_ui = preload("res://Scenes/MainMenu/Core/main_menu_ui.tscn")

var round_config_panel_instance = null
var round_config_panel = preload("res://Scenes/MainMenu/Panels/round_config_panel.tscn")

var round_config_node = preload("res://Scenes/ConfigureRound/round_config.tscn")

#RoundConfigurator
var round_configurator = preload("res://Scenes/ConfigureRound/round_configurator_logic.tscn")

var round_configurator_ui_instance = null
var round_configurator_ui = preload("res://Scenes/ConfigureRound/round_configurator_ui.tscn")

#PlayingRound
var playing_round_logic = preload("res://Scenes/PlayingRound/playing_round_logic.tscn")

var playing_round_ui_instance = null
var playing_round_ui = preload("res://Scenes/PlayingRound/playing_round_ui.tscn")

var world
var board_view_instance = null
var board_view = preload("res://Scenes/PlayingRound/board_view.tscn")

var state_manager
var turn_manager
var phase_manager

#region INITIALZE

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)

func initialize(logic_reference, ui_reference, world_reference):
	logic = logic_reference
	ui = ui_reference
	world = world_reference

	_on_state_changed(GameState.current_state)

#endregion

func _on_state_changed(new_state):
	match new_state:
		GameState.State.MAIN_MENU:
			logic.clear()
			create_main_menu()
			destroy_playing_round()

		GameState.State.CONFIGURE_ROUND:
			destroy_main_menu()
			create_round_configurator()

		GameState.State.PLAYING_ROUND:
			destroy_round_configurator()
			create_playing_round()

#region MAIN MENU
func create_main_menu():
	if logic.get_system("main_menu") != null:
		return

	var menu = main_menu_logic.instantiate()
	logic.add_child(menu)
	logic.register("main_menu", menu)

	main_menu_ui_instance = main_menu_ui.instantiate()
	ui.add_child(main_menu_ui_instance)

	main_menu_ui_instance.initialize(menu)
	menu.menu_state.state_changed.connect(_on_menu_state_changed)

func destroy_main_menu():
	if main_menu_ui_instance == null:
		return

	main_menu_ui_instance.queue_free()
	main_menu_ui_instance = null

	logic.release("main_menu")

	round_config_panel_instance = null

func _on_menu_state_changed(new_state):
	match new_state:
		MainMenuState.State.INTRO_SCREEN:
			destroy_round_config_panel()
		MainMenuState.State.SETTINGS:
			destroy_round_config_panel()
		MainMenuState.State.GAME_SETUP:
			create_round_config_node()
			create_round_config_panel()

func create_round_config_panel():
	if round_config_panel_instance != null:
		return

	round_config_panel_instance = round_config_panel.instantiate()
	main_menu_ui_instance.panels.add_child(round_config_panel_instance)
	round_config_panel_instance.initialize(logic.get_system("round_config"))

func create_round_config_node():
	if logic.get_system("round_config") != null:
		return

	var config = round_config_node.instantiate()
	logic.add_child(config)
	logic.register("round_config", config)

func destroy_round_config_panel():
	if round_config_panel_instance == null:
		return

	round_config_panel_instance.queue_free()
	round_config_panel_instance = null

#endregion

#region ROUND CONFIGURATOR

func create_round_configurator():
	if logic.get_system("round_configurator") != null:
		return

	var configurator = round_configurator.instantiate()
	logic.add_child(configurator)
	logic.register("round_configurator", configurator)

	round_configurator_ui_instance = round_configurator_ui.instantiate()
	ui.add_child(round_configurator_ui_instance)
	round_configurator_ui_instance.initialize(configurator)

func destroy_round_configurator():
	logic.release("round_configurator")

	if round_configurator_ui_instance == null:
		return

	round_configurator_ui_instance.queue_free()
	round_configurator_ui_instance = null

#endregion

#region PLAYING ROUND

func create_playing_round():
	if logic.get_system("playing_round") != null or playing_round_ui_instance != null:
		return

	var playing_round = playing_round_logic.instantiate()
	logic.add_child(playing_round)
	logic.register("playing_round", playing_round)
	playing_round.initialize(logic)

	state_manager = logic.get_system("state_manager")
	turn_manager = state_manager.turn_manager
	phase_manager = state_manager.phase_manager

	playing_round_ui_instance = playing_round_ui.instantiate()
	ui.add_child(playing_round_ui_instance)

	playing_round_ui_instance.initialize(state_manager, phase_manager, turn_manager)

	board_view_instance = board_view.instantiate()
	world.add_child(board_view_instance)
	board_view_instance.initialize(logic.get_system("board_manager"), logic.get_system("selection_manager"), logic.get_system("move_manager"))


func destroy_playing_round():
	if board_view_instance != null:
		board_view_instance.queue_free()
		board_view_instance = null

	if playing_round_ui_instance == null:
		return

	playing_round_ui_instance.queue_free()
	playing_round_ui_instance = null

	state_manager = null
	turn_manager = null
	phase_manager = null
#endregion
