extends PanelContainer

@onready var ram_slider: VSlider = $RamSlider
@onready var rotating_label: RotatingLabel = %RotatingLabel

func _process(delta: float) -> void:
	rotating_label.args[0] = ram_slider.value
