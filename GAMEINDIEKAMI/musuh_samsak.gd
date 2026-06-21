extends CharacterBody2D

# --- STATISTIK & STATE ROBOT ---
var darah_musuh: int = 100
const KECEPATAN_MUSUH = 120.0

enum State { JAHAT, KALAH, BAIK }
var kondisi_sekarang: State = State.JAHAT

# --- REFERENSI NODE ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Jalur mengambil langsung ke Area2D dan RadarPemain
@onready var hitbox_attack: Area2D = $Area2D
@onready var radar_pemain: Area2D = $RadarPemain

# Referensi komponen UI Mandiri di dalam Robot
@onready var ui_prompt_robot: PanelContainer = $UiPromptRobot
@onready var label_prompt_robot: Label = $UiPromptRobot/LabelPromptRobot

var target_player: CharacterBody2D = null
var bisa_diretas: bool = false
var sedang_terluka: bool = false 
var sedang_area_serang: bool = false

# Variabel bantuan untuk mengatur arah bolak-balik animasi idle melayang
var arah_ping_pong: int = 1 

func _ready() -> void:
	var cari_player = get_tree().current_scene.find_child("zidane", true, false)
	if not cari_player:
		cari_player = get_tree().current_scene.find_child("ZidaneKaosA", true, false)
		
	if cari_player is CharacterBody2D:
		target_player = cari_player
	
	# Matikan monitoring hitbox di awal game agar tidak otomatis memukul saat jalan
	hitbox_attack.set_deferred("monitoring", false)
	
	# Setting gaya siber hijau UI Prompt mandiri agar sama seperti level 1
	buat_gaya_ui_siber_hijau()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match kondisi_sekarang:
		State.JAHAT:
			logika_ai_musuh()
		State.KALAH:
			logika_saat_kalah()
		State.BAIK:
			logika_jadi_platform()

	move_and_slide()

# --- 1. LOGIKA AI JAHAT (ANTI-KEJANG & HITBOX AKURAT) ---
func logika_ai_musuh() -> void:
	if target_player == null or sedang_terluka: return
	
	# Jika zidane masuk radar, berhenti total dan putar animasi serang
	if sedang_area_serang:
		velocity.x = 0
		if animation_player.current_animation != "anim_serang":
			hitbox_attack.monitoring = true 
			animation_player.play("anim_serang")
		return
		
	if animation_player.current_animation == "anim_serang" and animation_player.is_playing():
		velocity.x = 0
		return

	var arah_ke_player = target_player.global_position.x - global_position.x
	var jarak_total = abs(arah_ke_player)
	
	if jarak_total < 350.0:
		var arah_jalan = sign(arah_ke_player)
		velocity.x = arah_jalan * KECEPATAN_MUSUH
		animation_player.play("anim_jalan")
		
		if arah_jalan > 0:
			animated_sprite.flip_h = false
			hitbox_attack.get_node("CollisionShape2D").position.x = 58.0
		else:
			animated_sprite.flip_h = true
			hitbox_attack.get_node("CollisionShape2D").position.x = -58.0
	else:
		velocity.x = move_toward(velocity.x, 0, KECEPATAN_MUSUH)
		if animation_player.current_animation != "anim_serang":
			animation_player.play("RESET")

# --- 2. LOGIKA TERKENA DAMAGE ---
# --- UPDATE FUNGSI TERKENA DAMAGE DI SCRIPT MUSUH ---
func terkena_damage(jumlah: int, posisi_pemukul: Vector2) -> void:
	if kondisi_sekarang != State.JAHAT: return
	
	darah_musuh -= jumlah
	sedang_terluka = true
	
	# --- LOGIKA KNOCKBACK (DORONG MUNDUR) ---
	# Tentukan arah: jika Zidane di kanan musuh, dorong ke kiri. Jika di kiri, dorong ke kanan.
	var arah_dorong = 1.0
	if posisi_pemukul.x > global_position.x:
		arah_dorong = -1.0
	
	if jumlah >= 50:
		velocity.x = arah_dorong * 30.0
	else:
		# Jika pukulan biasa, dorongan normal (250.0)
		velocity.x = arah_dorong * 15.0
	
	# Efek kedip putih bawaanmu (JANGAN DIUBAH)
	animated_sprite.modulate = Color(10, 10, 10, 1) 
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.15) 
	
	if darah_musuh <= 0:
		robot_kalah()
	else:
		animation_player.play("kena_serang")
		await animation_player.animation_finished
		sedang_terluka = false

# --- 3. SERANGAN BALIK ROBOT ---
func _on_area_2d_body_entered(body: Node2D) -> void:
	if kondisi_sekarang == State.JAHAT:
		if body.has_method("terkena_damage_zidane"):
			body.terkena_damage_zidane(15)
			hitbox_attack.set_deferred("monitoring", false)

# --- 4. LOGIKA KALAH & INTERAKSI PROMPT "E" MANDIRI ---
func robot_kalah() -> void:
	kondisi_sekarang = State.KALAH
	velocity.x = 0
	sedang_terluka = false
	hitbox_attack.set_deferred("monitoring", false)
	animation_player.play("anim_kalah")

func logika_saat_kalah() -> void:
	if target_player != null:
		var jarak = global_position.distance_to(target_player.global_position)
		bisa_diretas = jarak < 60.0 
		
		if bisa_diretas:
			ui_prompt_robot.visible = true
		else:
			ui_prompt_robot.visible = false

	if bisa_diretas and Input.is_action_just_pressed("interaksi"):
		perbaiki_robot()

func perbaiki_robot() -> void:
	kondisi_sekarang = State.BAIK
	bisa_diretas = false
	ui_prompt_robot.visible = false
	
	# Pindahkan posisi fisik tabrakan ke atas
	$CollisionShape2D.position.y = -55.0
	
	# KEMBALIKAN INI: Biarkan AnimationPlayer yang mengontrol perbaikan agar fisik tidak jatuh
	animation_player.play("anim_baik") 
	
	collision_layer = 1
	collision_mask = 1

# --- PERBAIKAN 2: LOGIKA KUNCI ANIMASI IDLE PING-PONG JADI PLATFORM ---
func logika_jadi_platform() -> void:
	# --- FIX UTAMA: Jalankan simulasi gravitasi tipis saat jadi platform agar tetap menapak tanah ---
	if not is_on_floor():
		velocity.y += get_gravity().y * get_process_delta_time()
	else:
		velocity.y = 0

	# Kurangi kecepatan dorong secara perlahan (friksi lantai) agar tidak meluncur tanpa henti
	velocity.x = move_toward(velocity.x, 0, 10.0)
	
	# --- WAJIB: Panggil move_and_slide() agar nilai velocity.x dari dorongan Zidane bisa menggerakkan robot ---
	move_and_slide()
	
	# --- LOGIKA ANIMASI PING-PONG (JANGAN DIUBAH) ---
	if not animation_player.is_playing() or animation_player.current_animation != "anim_baik":
		animated_sprite.animation = "JadiBaik"
		if animated_sprite.is_playing():
			animated_sprite.stop()
			
		if animated_sprite.frame < 6:
			animated_sprite.frame = 6
		
		if Engine.get_frames_drawn() % 8 == 0: 
			var frame_sekarang = animated_sprite.frame
			if frame_sekarang >= 9:
				arah_ping_pong = -1
			elif frame_sekarang <= 6:
				arah_ping_pong = 1
			animated_sprite.frame = frame_sekarang + arah_ping_pong

# --- FUNGSI MERAPIKAN VISUAL (STYLE KOTAK SIBER HIJAU NEON) ---
func buat_gaya_ui_siber_hijau() -> void:
	var gaya_kotak = StyleBoxFlat.new()
	gaya_kotak.bg_color = Color(0.05, 0.05, 0.05, 0.85) 
	gaya_kotak.set_corner_radius_all(4)                 
	gaya_kotak.set_border_width_all(1)                  
	gaya_kotak.border_color = Color(0.0, 1.0, 0.2)      
	gaya_kotak.shadow_color = Color(0.0, 1.0, 0.2, 0.3) 
	gaya_kotak.shadow_size = 4                         
	
	gaya_kotak.content_margin_left = 8
	gaya_kotak.content_margin_top = 4
	gaya_kotak.content_margin_right = 8
	gaya_kotak.content_margin_bottom = 4
	
	ui_prompt_robot.add_theme_stylebox_override("panel", gaya_kotak)
	label_prompt_robot.add_theme_color_override("font_color", Color(0.0, 1.0, 0.2))

# --- RADAR DETEKSI KELAKUAN JAHAT ---
func _on_radar_pemain_body_entered(body: Node2D) -> void:
	if body.has_method("terkena_damage_zidane"):
		sedang_area_serang = true

func _on_radar_pemain_body_exited(body: Node2D) -> void:
	if body.has_method("terkena_damage_zidane"):
		sedang_area_serang = false
