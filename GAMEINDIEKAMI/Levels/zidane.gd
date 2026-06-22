extends CharacterBody2D

const WALK_SPEED = 185.0
const RUN_SPEED = 370.0 
const JUMP_VELOCITY = -300.0

# --- ENUM STATE (KONDISI KARAKTER) ---
enum State { NORMAL, LEDGE_GRAB }
var kondisi_sekarang: State = State.NORMAL

# --- STATISTIK ZIDANE ---
var darah_zidane: int = 100
var sedang_terluka: bool = false

# --- REFERENSI NODE UTAMA ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# --- REFERENSI NODE SENSOR LEDGE GRAB ---
@onready var ledge_collider: CollisionShape2D = $LedgeCollider
@onready var wall_check: RayCast2D = $WallCheck          
@onready var ledge_air_check: RayCast2D = $LedgeAirCheck  
@onready var floor_check: RayCast2D = $FloorCheck
@onready var top_check: RayCast2D = $TopCheck

# --- VARIABEL BARU: SISTEM MONITORING TIMELINE ---
var sedang_menyerang: bool = false
var combo_count: int = 0
var input_buffer_attack: bool = false
const ATTACK_DASH_SPEED = 120.0 # Kecepatan dorongan maju saat mukul
var sedang_hitstop: bool = false

func _physics_process(delta: float) -> void:
	
	# AMBIL AKSES KE LEVEL UTAMA
	var level_utama = get_parent() # Sesuaikan jika player di dalam node lain, yg penting mengarah ke root level
	
	# --- PERBAIKAN: VALIDASI DIALOG AGAR ANTI-ERROR DI LEVEL LAIN ---
	# Kita cek dulu apakah variabel dialog tersebut memang ada di level yang sedang aktif
	var lagi_dialog = false
	if "sedang_dialog_satpam" in level_utama and level_utama.sedang_dialog_satpam:
		lagi_dialog = true
	elif "sedang_dialog_robot" in level_utama and level_utama.sedang_dialog_robot:
		lagi_dialog = true
	elif "sedang_dialog_nenek" in level_utama and level_utama.sedang_dialog_nenek:
		lagi_dialog = true

	# JIKA LAGI DIALOG (SATPAM/ROBOT/NENEK), KUNCI GERAKAN DAN PAKSA IDLE
	if lagi_dialog:
		velocity = Vector2.ZERO
		move_and_slide()
		if has_node("AnimationPlayer"): # atau pakai nama node animasimu
			$AnimationPlayer.play("idle_normal") # Sesuaikan nama animasi diammu
		return # STOP KODE JALAN DI BAWAHNYA!
		
	atur_kondisi_collider_ledge()

	# JIKA SEDANG MENGGANTUNG (LEDGE GRAB STATE)
	if kondisi_sekarang == State.LEDGE_GRAB:
		logika_state_ledge_grab()
		return

	# --- LOGIKA STATE NORMAL (JALAN, LARI, LOMPAT) ---
	# Jika sedang menyerang, pantau posisi detik animasi secara real-time
	if sedang_menyerang and animation_player.current_animation == "pukul_kunci_inggris":
		kontrol_pembatasan_kombo()

	# Tambahkan gravitasi jika tidak di lantai
	if not is_on_floor():
		velocity += get_gravity() * delta
		# Cek kecocokan ledge grab hanya saat melayang atau jatuh di udara
		periksa_pemicu_ledge_grab()

	# Deteksi input terluka
	if sedang_terluka:
		move_and_slide()
		return

	# DETEKSI INPUT KLIK SERANG
	if Input.is_action_just_pressed("Attack"):
		if not sedang_menyerang:
			mulai_serangan_kombo()
		else:
			input_buffer_attack = true

	# JIKA SEDANG MENYERANG, KUNCI PERGERAKAN
	if sedang_menyerang:
		# Gunakan nilai rem yang lebih kecil (misal: 400.0 * delta) agar dorongannya terasa 
		# Jika ingin jarak majunya lebih jauh, perkecil angka 400.0 di bawah ini.
		velocity.x = move_toward(velocity.x, 0, 400.0 * delta)
		
		# Jangan lupa tambahkan gravitasi saat menyerang, supaya kalau mukul di ujung tebing tidak melayang
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("Loncat") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("Kekiri", "Kekanan")
	
	# DETEKSI SIFAT LARI (SHIFT)
	var sedang_lari = Input.is_action_pressed("Lari") and direction != 0
	var kecepatan_sekarang = RUN_SPEED if sedang_lari else WALK_SPEED
	
	# --- KEBULATAN ARAH HITBOX & SENSOR (FIXED PARALEL HORIZONTAL) ---
	if direction > 0: 
		animated_sprite.flip_h = false
		
		# Pangkal sensor saat hadap kanan
		wall_check.position.x = 10 
		ledge_air_check.position.x = 10
		
		# Tembakan wajib lurus horizontal (y = 0)
		wall_check.target_position = Vector2(15, 0)
		ledge_air_check.target_position = Vector2(15, 0)
		
		if has_node("WrenchHitbox/HitboxShape"):
			$WrenchHitbox/HitboxShape.position.x = 57.5
			
	elif direction < 0:
		animated_sprite.flip_h = true
		
		# Pangkal sensor saat hadap kiri (Simetris)
		wall_check.position.x = -10 
		ledge_air_check.position.x = -10
		
		# Tembakan wajib lurus horizontal ke kiri (y = 0)
		wall_check.target_position = Vector2(-15, 0)
		ledge_air_check.target_position = Vector2(-15, 0)
		
		if has_node("WrenchHitbox/HitboxShape"):
			$WrenchHitbox/HitboxShape.position.x = -57.5
			
	# MOVE VARIATION & ANIMATION SELECTION
	if is_on_floor():
		if direction == 0:
			animation_player.play("idle_normal") 
		else:
			if sedang_lari:
				animation_player.play("new_run")
			else:
				animation_player.play("walk_normal") 
	else:
		animation_player.play("jump_normal") 
	
	if direction:
		velocity.x = direction * kecepatan_sekarang
	else:
		velocity.x = move_toward(velocity.x, 0, kecepatan_sekarang)

	move_and_slide()
	proses_dorong_samsak()

# --- FUNGSI UTAMA CEK LEDGE GRAB (VERSI AMAN COORD DAN ANTI-MELAYANG) ---
# --- FUNGSI UTAMA CEK LEDGE GRAB (FIXED ANTI-LOCK JUMP) ---
func periksa_pemicu_ledge_grab() -> void:
	# KUNCI UTAMA: Hanya boleh nempel jika sedang jatuh/diam (velocity.y >= 0)
	# Ini mencegah Zidane langsung nempel lagi saat kita pencet loncat ke atas
	if velocity.y >= 0 and not is_on_floor() and not top_check.is_colliding():
		
		# Pemicu dasar horizontal sejajar
		if wall_check.is_colliding() and not ledge_air_check.is_colliding():
			var normal_dinding = wall_check.get_collision_normal()
			
			if abs(normal_dinding.x) > 0.8:
				# 1. AMBIL TITIK KOORDINAT Y DARI UJUNG TEBING AKTUAL
				var titik_tebing_y = wall_check.get_collision_point().y
				
				# 2. GUNAKAN OFFSET 14 YANG SUDAH KAMU SESUAIKAN
				var target_posisi_y_karakter = titik_tebing_y + 14.0
				
				# 3. AUTO-SNAP GRAVITASI
				global_position.y = target_posisi_y_karakter
				
				# 4. AKTIFKAN STATE GANGTUNG
				velocity = Vector2.ZERO
				kondisi_sekarang = State.LEDGE_GRAB
				
				# Kunci arah hadap
				if normal_dinding.x > 0:
					animated_sprite.flip_h = true
				else:
					animated_sprite.flip_h = false


# --- FUNGSI MENGATUR KELAKUAN SAAT MENGGANTUNG (FIXED ANTI-MELAYANG) ---
func logika_state_ledge_grab() -> void:
	# 1. JALANKAN ANIMASI & KUNCI GRAVITASI
	animation_player.play("anim_gantung")
	velocity = Vector2.ZERO
	
	# 2. FITUR SAFETY BRK: Cek apakah dinding di depan kita MASIH ADA?
	if not wall_check.is_colliding():
		# Jika dinding tiba-tiba hilang (karena balik badan/hancur), JATOHKAN ZIDANE!
		kondisi_sekarang = State.NORMAL
		return
		
	# 3. GAYA TARIK (SNAP) KE DINDING
	var titik_tabrakan = wall_check.get_collision_point()
	if not animated_sprite.flip_h:
		global_position.x = titik_tabrakan.x - 8 
	else:
		global_position.x = titik_tabrakan.x + 8

	# 4. TOMBOL KELUAR (MANUAL)
	if Input.is_action_just_pressed("Loncat"):
		velocity.y = JUMP_VELOCITY * 1.1 
		kondisi_sekarang = State.NORMAL
	
	if Input.is_action_just_pressed("Bawah"):
		kondisi_sekarang = State.NORMAL

	move_and_slide()

# --- FUNGSI PENCEGAH BUG COLLIDER ---
func atur_kondisi_collider_ledge() -> void:
	if kondisi_sekarang == State.LEDGE_GRAB:
		ledge_collider.disabled = false
	else:
		# Matikan collider jika di lantai, sedang melompat naik, atau kepala mentok langit-langit
		if is_on_floor() or velocity.y < 0 or top_check.is_colliding():
			ledge_collider.disabled = true
		else:
			ledge_collider.disabled = false

# --- FUNGSI PEMBANTU: DORONG MAJU DI TIAP HIT ---
func beri_dorongan_serang() -> void:
	var arah_dorong = -1.0 if animated_sprite.flip_h else 1.0
	# Kamu bisa menaikkan angka ATTACK_DASH_SPEED di atas skrip jika ingin dorongannya lebih berasa
	velocity.x = arah_dorong * ATTACK_DASH_SPEED

func mulai_serangan_kombo() -> void:
	sedang_menyerang = true
	combo_count = 1
	input_buffer_attack = false
	
	beri_dorongan_serang() # Dorongan pukulan ke-1
	animation_player.play("pukul_kunci_inggris")

func kontrol_pembatasan_kombo() -> void:
	var waktu_sekarang = animation_player.current_animation_position
	if combo_count == 1 and waktu_sekarang >= 0.60:
		if input_buffer_attack:
			combo_count = 2
			input_buffer_attack = false
			beri_dorongan_serang() # Dorongan pukulan ke-2
		else:
			hentikan_serangan_paksa()
	elif combo_count == 2 and waktu_sekarang >= 1.10:
		if input_buffer_attack:
			combo_count = 3
			input_buffer_attack = false
			beri_dorongan_serang() # Dorongan pukulan ke-3
		else:
			hentikan_serangan_paksa()
	elif combo_count == 3 and waktu_sekarang >= 2.00:
		if input_buffer_attack:
			combo_count = 4
			input_buffer_attack = false
			beri_dorongan_serang() # Dorongan pukulan ke-4 (Final)
		else:
			hentikan_serangan_paksa()
	elif combo_count == 4 and waktu_sekarang >= 2.40:
		hentikan_serangan_paksa()

func hentikan_serangan_paksa() -> void:
	animation_player.stop()
	sedang_menyerang = false
	combo_count = 0
	input_buffer_attack = false
	animation_player.play("idle_normal")

func proses_dorong_samsak() -> void:
	for i in get_slide_collision_count():
		var tabrakan = get_slide_collision(i)
		var objek = tabrakan.get_collider()
		if objek and (objek.name == "MusuhSamsak" or objek.has_method("logika_jadi_platform")):
			if "kondisi_sekarang" in objek and objek.kondisi_sekarang == objek.State.BAIK:
				if abs(tabrakan.get_normal().x) > 0.5:
					objek.velocity.x = -tabrakan.get_normal().x * 100.0

func _on_wrench_hitbox_body_entered(body: Node2D) -> void:
	if sedang_menyerang and body.has_method("terkena_damage"):
		var damage_sekarang = 20 
		var durasi_freeze = 0.08 # Nilai standard hitstop (sekitar 5 frame)
		
		if combo_count == 4:
			damage_sekarang = 50
			durasi_freeze = 0.15 # Pukulan terakhir kombo efeknya lebih dramatis/lama
			
		# Berikan damage ke musuh
		body.terkena_damage(damage_sekarang, global_position)
		
		# PICU HITSTOP DI SINI! (Kirim node tubuh musuh sebagai argumen)
		picu_hitstop(durasi_freeze, body)

func terkena_damage_zidane(jumlah_damage: int) -> void:
	if sedang_terluka or darah_zidane <= 0: return
	darah_zidane -= jumlah_damage
	sedang_terluka = true
	velocity.x = 0 
	sedang_menyerang = false
	combo_count = 0
	animated_sprite.modulate = Color(5, 0.5, 0.5, 1)
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.2)
	
	if animation_player.has_animation("kena_serang"):
		animation_player.play("kena_serang")
		await animation_player.animation_finished
	else:
		await get_tree().create_timer(0.2).timeout
		
	sedang_terluka = false
	
	# --- FUNGSI UTAMA HITSTOP (FREEZE GAMEPLAY) ---
# --- FUNGSI UTAMA HITSTOP (GLOBAL ENGINE SCALE) ---
# --- FUNGSI UTAMA HITSTOP + SCREEN SHAKE GLOBAL ---
func picu_hitstop(durasi: float, objek_musuh: Node2D) -> void:
	if sedang_hitstop: return
	sedang_hitstop = true
	
	# 1. EFEK GETAR (SHAKE) PADA SPRITE MUSUH
	if objek_musuh.has_node("AnimatedSprite2D"):
		var sprite_musuh = objek_musuh.get_node("AnimatedSprite2D")
		var posisi_asli_sprite = sprite_musuh.position
		
		var tween_shake_musuh = create_tween()
		tween_shake_musuh.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		tween_shake_musuh.tween_property(sprite_musuh, "position", posisi_asli_sprite + Vector2(5, 0), durasi / 4.0)
		tween_shake_musuh.tween_property(sprite_musuh, "position", posisi_asli_sprite + Vector2(-5, 0), durasi / 4.0)
		tween_shake_musuh.tween_property(sprite_musuh, "position", posisi_asli_sprite + Vector2(3, 0), durasi / 4.0)
		tween_shake_musuh.tween_property(sprite_musuh, "position", posisi_asli_sprite, durasi / 4.0)

	# 2. EFEK GETAR SATU LAYAR (SCREEN SHAKE VIA CAMERA2D)
	# Mengambil kamera aktif saat ini yang ada di dalam Scene Tree
	var kamera_utama = get_viewport().get_camera_2d()
	if kamera_utama:
		# Simpan offset asli kamera (biasanya Vector2(0,0))
		var offset_asli_kamera = kamera_utama.offset
		
		# Tentukan kekuatan getaran layar (semakin besar angkanya, semakin heboh guncangannya)
		# Pukulan kombo terakhir (combo_count == 4) dibuat lebih bergetar
		var kekuatan_getar = 6.0 if combo_count == 4 else 3.0
		
		var tween_shake_layar = create_tween()
		tween_shake_layar.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		# Mengguncang offset kamera secara acak/diagonal dengan cepat selama hitstop
		tween_shake_layar.tween_property(kamera_utama, "offset", offset_asli_kamera + Vector2(kekuatan_getar, -kekuatan_getar), durasi / 4.0)
		tween_shake_layar.tween_property(kamera_utama, "offset", offset_asli_kamera + Vector2(-kekuatan_getar, kekuatan_getar), durasi / 4.0)
		tween_shake_layar.tween_property(kamera_utama, "offset", offset_asli_kamera + Vector2(-kekuatan_getar / 2.0, -kekuatan_getar / 2.0), durasi / 4.0)
		tween_shake_layar.tween_property(kamera_utama, "offset", offset_asli_kamera, durasi / 4.0)

	# 3. BEKUKAN WAKTU DUNIA
	Engine.time_scale = 0.01 
	
	# 4. TUNGGU BERDASARKAN WAKTU NYATA LINGKUNGAN
	await get_tree().create_timer(durasi, true, false, true).timeout
	
	# 5. KEMBALIKAN WAKTU NORMAL
	Engine.time_scale = 1.0
	sedang_hitstop = false

# Fungsi pembantu mengembalikan sisa kecepatan dorong
func kecepatan_sekarang_di_air_atau_tanah(kecepatan_lama: Vector2) -> Vector2:
	if is_on_floor():
		return Vector2(kecepatan_lama.x, 0)
	else:
		return kecepatan_lama
