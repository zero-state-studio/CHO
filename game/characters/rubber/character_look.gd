class_name CharacterLook
extends Resource
## Aspetto di un personaggio gommoso: proporzioni, colori e accessori. Tutti i
## personaggi condividono lo stesso corpo e lo stesso scheletro; cambiano solo
## questi parametri. I dati stanno in data/characters/.

@export_group("Proporzioni")
## Raggio della testa (tonda e grande, da pupazzo).
@export var head_radius: float = 0.2
## Raggio del corpo a fagiolo; una camicia larga lo fa più grosso.
@export var torso_radius: float = 0.22
## Altezza del busto, dal bacino alla base del collo.
@export var torso_height: float = 0.5
## Quanto il busto scende sotto il bacino (camicia fuori dai pantaloni).
@export var torso_drop: float = 0.08
@export var arm_radius: float = 0.065
@export var upper_arm_length: float = 0.24
@export var lower_arm_length: float = 0.22
## Raggio delle mani a muffola.
@export var hand_radius: float = 0.075
@export var leg_radius: float = 0.075
@export var upper_leg_length: float = 0.28
@export var lower_leg_length: float = 0.26
@export var foot_length: float = 0.2
## Distanza delle gambe dal centro.
@export var hip_width: float = 0.1

@export_group("Colori")
@export var skin_color: Color = Color(0.96, 0.8, 0.66)
## Camicia o giacca: busto e braccia.
@export var torso_color: Color = Color(0.9, 0.92, 0.96)
@export var leg_color: Color = Color(0.25, 0.28, 0.36)
@export var shoe_color: Color = Color(0.18, 0.14, 0.12)
@export var eye_color: Color = Color(0.08, 0.08, 0.1)
## Lucentezza del busto (0 opaco, 1 lucido): la giacca del Manager.
@export_range(0.0, 1.0) var torso_gloss: float = 0.0

@export_group("Viso e capelli")
@export var has_smile: bool = false
@export var smile_color: Color = Color(1.0, 1.0, 1.0)
@export var has_hair: bool = false
@export var hair_color: Color = Color(0.2, 0.14, 0.1)

@export_group("Accessori")
@export var has_tie: bool = false
@export var tie_color: Color = Color(0.85, 0.12, 0.15)
## Lunghezza totale della cravatta: quella del Manager è enorme.
@export var tie_length: float = 0.34
@export var tie_width: float = 0.09
## Parte bianca della camicia sotto la giacca, visibile con la cravatta.
@export var has_shirt_front: bool = false
@export var shirt_front_color: Color = Color(0.97, 0.97, 0.97)
@export var has_badge: bool = false
@export var badge_color: Color = Color(0.25, 0.55, 0.95)
@export var has_backpack: bool = false
@export var backpack_color: Color = Color(0.95, 0.55, 0.2)
