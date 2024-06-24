extends PanelContainer

@onready var ram_slider: VSlider = $RamSlider
@onready var rotating_label: RotatingLabel = %RotatingLabel

func _ready() -> void:
	ram_slider.scrollable = false
	ram_slider.value = Config.max_ram

func _process(delta: float) -> void:
	rotating_label.args[0] = ram_slider.value
	Config.max_ram = ram_slider.value
