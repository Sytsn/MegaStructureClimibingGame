class_name DialogRes extends Resource

@export_category("Dialog Configuration")
@export var is_repeatable: bool

@export_category("Dialog Info")
@export var dialog_text: Dictionary[int, String]
#dialog_response [dialog_text_id, DialogResponseRes]
@export var dialog_response: Dictionary[int, DialogResponseRes]
