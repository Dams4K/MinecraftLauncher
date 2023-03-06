extends VBoxContainer

signal _switch_to_play_container

@onready var accounts_container: VBoxContainer = %AccountsContainer

func _ready() -> void:
	connect_account_config()

func _on_back_button_pressed() -> void:
	emit_signal("_switch_to_play_container")

func connect_account_config() -> void:
	for account in accounts_container.get_children():
		account.connect("selected", new_account_selected)

func new_account_selected(who) -> void:
	for account in accounts_container.get_children():
		if account != who:
			account.is_selected = false
