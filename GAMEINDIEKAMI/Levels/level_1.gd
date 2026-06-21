extends Node2D

var objek_interaksi_aktif: Node2D = null

# Variabel kontrol alur cerita (Story State)
var udah_lewat_pintu: bool = false
var udah_sampai_pasar: bool = false
var udah_sedih_di_rumah: bool = false
var pas_kena_robot: bool = false
var udah_ambil_baterai: bool = false
var udah_pakai_hoodie: bool = false
var udah_ngobrol_sama_nenek: bool = false
var udah_pindah_zona: bool = false
var udah_pindah_zona1: bool = false
var udah_masuk_zona4: bool = false

# == VARIABEL BARU UNTUK LOKET TARUH BATERAI & KUPON ==

# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# ==# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# ==# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# ==# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# ==# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 
# == Apa jadinya kaalo aku menambahkan paragreaf random yang ada di sini 



var dekat_loket_batrai: bool = false
var baterai_sudah_diberikan: bool = false
var punya_kupon_makanan: bool = false

# == VARIABEL KONTROL PERCAKAPAN ROBOT TUA ==
var sedang_dialog_robot: bool = false
var indeks_dialog_robot: int = 0

# == VARIABEL KONTROL PERCAKAPAN NENEK ==
var sedang_dialog_nenek: bool = false
var indeks_dialog_nenek: int = 0

# == BARU: VARIABEL KONTROL PERCAKAPAN LOKET (PENJAGA OM-OM) ==
var sedang_dialog_loket: bool = false
var indeks_dialog_loket: int = 0
var mode_loket: String = ""

# == VARIABEL KONTROL PERCAKAPAN SATPAM KUSAM ==
var dekat_satpam: bool = false
var sedang_dialog_satpam: bool = false
var indeks_dialog_satpam: int = 0
var udah_ngobrol_sama_satpam: bool = false

# Variabel deteksi jarak interaksi klik / tombol E
var dekat_baterai: bool = false
var dekat_pintu: bool = false
var dekat_masuk_rumah: bool = false
var dekat_nenek_duduk: bool = false
var dekat_robot_tua: bool = false
var dekat_pusat_distrik: bool = false


# Ambil akses ke node Label teks di dalam kontainer prompt
@onready var ui_prompt_label = $UIDialog/InteraksiPrompt/TeksPrompt

# === PASTI KAN DUA BARIS INI ADA DI SINI ===
@onready var ui_misi = $UIDialog/MisiPanel
@onready var ui_prompt = $UIDialog/InteraksiPrompt

# Ambil akses langsung ke kedua karakter kamu
@onready var karakter_kaos = $ZidaneKaosA
@onready var karakter_hoodie = $zidane
@onready var sprite_lemari_jaket = $LemariJaket/LemariJaketSprite2D

# == PERBAIKAN PATH JALUR NODE ==
@onready var icon_batrai = $ZidaneKaosA/icon_batrai
@onready var icon_kupon = $ZidaneKaosA/icon_kupon
@onready var ui_dialog = $UIDialog/KotakDialog
@onready var teks_nama = $UIDialog/KotakDialog/TeksNama
@onready var teks_konten = $UIDialog/KotakDialog/TeksKonten
@onready var foto_karakter = $UIDialog/FotoKarakter
@onready var group_parallax_4 = $GroupParallax4

# ====================================================================
# FUNGSI PROCESS: Update posisi tombol E mengikuti dunia 2D objek
# ====================================================================
func _process(_delta: float) -> void:
	if ui_prompt and ui_prompt.visible and objek_interaksi_aktif and is_instance_valid(objek_interaksi_aktif):
		var marker_posisi = objek_interaksi_aktif.get_node_or_null("PosisiPrompt")
		var posisi_layar = objek_interaksi_aktif.get_global_transform_with_canvas().origin
		
		if marker_posisi:
			posisi_layar += marker_posisi.position * objek_interaksi_aktif.get_global_transform_with_canvas().get_scale()
		else:
			posisi_layar += Vector2(0, -35) 
			
		ui_prompt.global_position = posisi_layar - (ui_prompt.size / 2.0)

func _ready() -> void:
	karakter_kaos.visible = true
	karakter_hoodie.visible = false
	karakter_hoodie.set_physics_process(false)
	if icon_batrai:
		icon_batrai.top_level = false
		icon_batrai.scale = Vector2(0.01, 0.01)
		icon_batrai.position = Vector2(-5, -35)
		icon_batrai.visible = false
	if icon_kupon:
		icon_kupon.top_level = false
		icon_kupon.scale = Vector2(0.01, 0.01)
		icon_kupon.position = Vector2(-5, -35)
		icon_kupon.visible = false
	inisialisasi_visual_ui_prom()
	if ui_prompt:
		ui_prompt.visible = false
	update_misi("Bicara dengan Robot Tua di sudut bengkel.")
	atur_batas_kamera("zona_1_bengkel")

func apply_font(label: Label, size: int):
	var font = load("res://Font/PixelOperator8-Bold.ttf") as FontFile
	if font:
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", size)

# ====================================================================
# INISIALISASI VISUAL UI
# ====================================================================
func inisialisasi_visual_ui_prom() -> void:
	if ui_misi:
		# 1. BUAT KOTAK LATAR BELAKANG OTOMATIS
		var bg_panel = PanelContainer.new()
		bg_panel.name = "MisiBackgroundPanel"
		
		ui_misi.get_parent().add_child(bg_panel)
		ui_misi.get_parent().remove_child(ui_misi)
		bg_panel.add_child(ui_misi)
		
		bg_panel.position = Vector2(24, 24) 
		bg_panel.custom_minimum_size = Vector2(500, 0) 
		
		ui_misi.autowrap_mode = TextServer.AUTOWRAP_WORD
		
		# 2. DESIGN STYLEBOX (TEMA TERMINAL MILITER SIBER)
		var style_misi = StyleBoxFlat.new()
		style_misi.bg_color = Color(0.01, 0.04, 0.02, 0.75) 
		
		style_misi.set_corner_radius_all(3) 
		style_misi.set_border_width_all(1) 
		style_misi.border_color = Color(0.0, 0.8, 0.2, 0.9) 
		
		# Efek Glow / Pendaran Cahaya Hijau di pinggiran panel
		style_misi.shadow_color = Color(0.0, 1.0, 0.2, 0.12)
		style_misi.shadow_size = 8
		
		# Padding bagian dalam kotak (jarak teks ke dinding kotak)
		style_misi.content_margin_left = 14
		style_misi.content_margin_right = 14
		style_misi.content_margin_top = 10
		style_misi.content_margin_bottom = 10
		
		bg_panel.add_theme_stylebox_override("panel", style_misi)
		
		# 3. KUSTOMISASI TEKS DI DALAMNYA
		ui_misi.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9)) 
		ui_misi.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6)) 
		ui_misi.add_theme_constant_override("outline_size", 3)
		
		apply_font(ui_misi, 10) 
		
	if ui_prompt:
		var style_prompt = StyleBoxFlat.new()
		style_prompt.bg_color = Color(0.2, 0.2, 0.2, 0.85)
		style_prompt.set_corner_radius_all(4)
		style_prompt.set_border_width_all(2)
		style_prompt.border_color = Color(0.0, 1.0, 0.2)
		style_prompt.shadow_color = Color(0.0, 1.0, 0.2, 0.35)
		style_prompt.shadow_size = 6
		style_prompt.content_margin_left = 10
		style_prompt.content_margin_right = 10
		style_prompt.content_margin_top = 6
		style_prompt.content_margin_bottom = 6
		ui_prompt.add_theme_stylebox_override("panel", style_prompt)
		if ui_prompt_label:
			ui_prompt_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
			ui_prompt_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
			ui_prompt_label.add_theme_constant_override("outline_size", 2)
			ui_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ui_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			apply_font(ui_prompt_label, 20)

func update_misi(teks_baru: String) -> void:
	if ui_misi:
		ui_misi.text = "■ SYSTEM OBJECTIVE\n> " + teks_baru

func tampilkan_prompt_interaksi(objek: Node2D) -> void:
	if ui_prompt and not ui_dialog.visible:
		objek_interaksi_aktif = objek
		if ui_prompt_label:
			ui_prompt_label.text = "E"
		ui_prompt.visible = true
		ui_prompt.reset_size()
		animasi_prompt()

func sembunyikan_prompt_interaksi() -> void:
	if ui_prompt and ui_prompt.visible:
		var tween = create_tween()
		tween.tween_property(ui_prompt, "modulate:a", 0.0, 0.15)
		tween.tween_callback(Callable(self, "_hide_prompt_final"))

func _hide_prompt_final():
	if ui_prompt:
		ui_prompt.visible = false
		objek_interaksi_aktif = null

func animasi_prompt():
	ui_prompt.modulate.a = 0.0
	ui_prompt.scale = Vector2(0.95, 0.95)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(ui_prompt, "modulate:a", 1.0, 0.2)
	tween.tween_property(ui_prompt, "scale", Vector2(1, 1), 0.2)

# ====================================================================
# PUSAT INPUT (MENDENGARKAN TOMBOL E & KLIK DIALOG NEXT)
# ====================================================================
func _input(event: InputEvent) -> void:
	if ui_dialog and ui_dialog.visible:
		var tombol_next = Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interaksi")
		var klik_next = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false
		if tombol_next or klik_next:
			get_viewport().set_input_as_handled()
			if sedang_dialog_robot:
				indeks_dialog_robot += 1
				jalankan_alur_dialog_robot()
			elif sedang_dialog_nenek:
				indeks_dialog_nenek += 1
				jalankan_alur_dialog_nenek()
			elif sedang_dialog_loket:
				indeks_dialog_loket += 1
				jalankan_alur_dialog_loket()
			elif sedang_dialog_satpam:
				indeks_dialog_satpam += 1
				jalankan_alur_dialog_satpam()
			else:
				ui_dialog.visible = false
				if foto_karakter:
					foto_karakter.visible = false
				set_player_movement(true)
			return
			
	if Input.is_action_just_pressed("interaksi"):
		if dekat_robot_tua and not pas_kena_robot:
			picu_interaksi_robot()
		elif dekat_baterai and not udah_ambil_baterai:
			picu_interaksi_baterai()
		elif dekat_pintu and not udah_lewat_pintu:
			picu_interaksi_pintu()
		elif dekat_loket_batrai and not udah_sampai_pasar:
			picu_interaksi_loket()
		elif dekat_pusat_distrik and not udah_sampai_pasar:
			picu_interaksi_pasar()
		elif dekat_masuk_rumah:
			picu_interaksi_masuk_rumah()
		elif dekat_nenek_duduk and not udah_ngobrol_sama_nenek:
			picu_interaksi_nenek()
# ====================================================================
# 1. INTERAKSI ROBOT TUA
# ====================================================================
func _on_robot_tua_body_entered(body: Node2D) -> void:
	if (body.name == "ZidaneKaosA" or body.name == "zidane") and not pas_kena_robot:
		dekat_robot_tua = true
		# Gunakan find_child agar terbaca meskipun nodenya tersimpan di dalam folder lain
		var node_robot = find_child("RobotTua", true, false) as Node2D
		tampilkan_prompt_interaksi(node_robot if node_robot else self)

func _on_robot_tua_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_robot_tua = false
		sembunyikan_prompt_interaksi()

func _on_robot_tua_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_robot_tua and not pas_kena_robot:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_robot()

func picu_interaksi_robot() -> void:
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	if sedang_dialog_robot == false:
		sedang_dialog_robot = true
		indeks_dialog_robot = 0
		set_player_movement(false)
		jalankan_alur_dialog_robot()
		
func jalankan_alur_dialog_robot() -> void:
	match indeks_dialog_robot:
		0: tampilkan_dialog("Zidane", "Selamat pagi robot karat!")
		1: tampilkan_dialog("Robot Tua", "[Suara kipas internal berderit]... Pagi, Pendek...")
		2: tampilkan_dialog("Zidane", "....")
		3: tampilkan_dialog("Zidane", "Oke... sebagai manusia yg memiliki perasaan itu aga ngena di aku", "tenang")
		4: tampilkan_dialog("Robot Tua", "Kau pikir itu respon yg muncul tanpa alasan...", "tenang2")
		5: tampilkan_dialog("Robot Tua", "Pengingat: Baterai plasma di yg kamu buat sudah selesai ku kalibrasi")
		6: tampilkan_dialog("Zidane", "Setidaknya kamu masih berfungsi...", "tenang")
		7: tampilkan_dialog("Zidane", "oke! makasih bantuanya... sekarang aku bisa ngantar batari ini dan menukarnya dg jatah konsumsi minggu ini")
		8: tampilkan_dialog("Robot Tua", "Ya hati2.. aku dah mau mati ini...")
		_:
			ui_dialog.visible = false
			if foto_karakter: foto_karakter.visible = false
			sedang_dialog_robot = false
			pas_kena_robot = true
			set_player_movement(true)
			update_misi("Ambil Baterai Plasma di meja kerja.")

# ====================================================================
# 2. MEKANIK INTERAKSI KLIK BATERAI PLASMA
# ====================================================================
func _on_batrai_body_entered(body: Node2D) -> void:
	if (body.name == "ZidaneKaosA" or body.name == "zidane") and not udah_ambil_baterai:
		dekat_baterai = true
		var node_baterai = find_child("Batrai", true, false) as Node2D
		tampilkan_prompt_interaksi(node_baterai if node_baterai else self)

func _on_batrai_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_baterai = false
		sembunyikan_prompt_interaksi()

func _on_batrai_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_baterai and not udah_ambil_baterai:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_baterai()
			
func picu_interaksi_baterai() -> void:
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	udah_ambil_baterai = true
	if icon_batrai: icon_batrai.visible = true
	if has_node("Batrai"):
		$Batrai.queue_free()
	update_misi("Keluar rumah, bawa baterai ke loket penukaran di luar.")
	set_player_movement(false)
	tampilkan_dialog("Zidane", "Baterai plasma hasil rakitan gua udah siap. Sip, bawa ini ke luar buat ditukar makanan.", "tenang")

# ====================================================================
# 3. MEKANIK INTERAKSI KLIK PINTU KELUAR & TELEPORTASI
# ====================================================================
func _on_pintu_keluar_body_entered(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_pintu = true
		var node_pintu = find_child("PintuKeluar", true, false) as Node2D
		tampilkan_prompt_interaksi(node_pintu if node_pintu else self)

func _on_pintu_keluar_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_pintu = false
		sembunyikan_prompt_interaksi()

func _on_pintu_keluar_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_pintu and not udah_lewat_pintu:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_pintu()

func picu_interaksi_pintu() -> void:
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	var karakter_aktif = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
	if karakter_aktif == karakter_kaos and udah_ambil_baterai == false:
		set_player_movement(false)
		sedang_dialog_loket = true
		mode_loket = "pintu_terkunci"
		indeks_dialog_loket = 0
		jalankan_alur_dialog_loket()
		return
	set_player_movement(false)
	sedang_dialog_loket = true
	mode_loket = "pintu_keluar"
	indeks_dialog_loket = 0
	jalankan_alur_dialog_loket()

# ====================================================================
# 4. PUSAT DISTRIK / PASAR
# ====================================================================
func _on_pusat_distrik_body_entered(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" and udah_sampai_pasar == false and udah_lewat_pintu == true:
		if baterai_sudah_diberikan == false:
			return
		dekat_pusat_distrik = true
		var node_pasar = find_child("PusatDistrik", true, false) as Node2D
		tampilkan_prompt_interaksi(node_pasar if node_pasar else self)

func _on_pusat_distrik_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA":
		dekat_pusat_distrik = false
		sembunyikan_prompt_interaksi()

func _on_pusat_distrik_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_pusat_distrik and not udah_sampai_pasar:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_pasar()

func picu_interaksi_pasar() -> void:
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	if sedang_dialog_loket == false:
		sedang_dialog_loket = true
		mode_loket = "alur_pasar_eko"
		indeks_dialog_loket = 0
		set_player_movement(false)
		jalankan_alur_dialog_loket()

# ====================================================================
# 4B. MEKANIK LOKET: TARUH BATERAI
# ====================================================================
func _on_taruh_batrai_body_entered(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" and not udah_sampai_pasar:
		dekat_loket_batrai = true
		if baterai_sudah_diberikan == false:
			var node_loket = find_child("TaruhBatrai", true, false) as Node2D
			tampilkan_prompt_interaksi(node_loket if node_loket else self)

func _on_taruh_batrai_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA":
		dekat_loket_batrai = false
		sembunyikan_prompt_interaksi()

func _on_taruh_batrai_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_loket_batrai:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_loket()

func picu_interaksi_loket() -> void:
	if udah_sampai_pasar: return
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	if udah_ambil_baterai == true and baterai_sudah_diberikan == false:
		if sedang_dialog_loket == false:
			sedang_dialog_loket = true
			mode_loket = "serah_baterai"
			indeks_dialog_loket = 0
			set_player_movement(false)
			jalankan_alur_dialog_loket()

func jalankan_alur_dialog_loket() -> void:
	match mode_loket:
		"pintu_terkunci":
			match indeks_dialog_loket:
				0: tampilkan_dialog("Zidane", "Oh iya, batrainya kan masih di meja kerja...", "tenang")
				_: tutup_dialog_loket()
		"pintu_keluar":
			match indeks_dialog_loket:
				0: tampilkan_dialog("Zidane", "Oke, mending gua buruan keluar...", "tenang")
				_:
					tutup_dialog_loket()
					var karakter_aktif = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
					if is_instance_valid(karakter_aktif):
						karakter_aktif.global_position = Vector2(-650, -125)
						atur_batas_kamera("zona_luar_bebas")
						if karakter_aktif.has_node("Camera2D"):
							karakter_aktif.get_node("Camera2D").reset_smoothing()
						if is_instance_valid(icon_batrai): icon_batrai.position = Vector2(0, -35)
						if is_instance_valid(icon_kupon): icon_kupon.position = Vector2(0, -35)
					udah_lewat_pintu = true
					if not baterai_sudah_diberikan:
						update_misi("Cari Loket Pengumpulan Baterai di zona luar.")
		"serah_baterai":
			match indeks_dialog_loket:
				0: tampilkan_dialog("Zidane", "Ini baterai rakitan pesanan kemarin, Om...", "tenang")
				1: tampilkan_dialog("Zidane", "Mana jatah Konsumsi ku?")
				2: tampilkan_dialog("Loket", "Sip, energinya stabil. Ini kupon jatah makananmu, simpan baik-baik.")
				_:
					baterai_sudah_diberikan = true
					punya_kupon_makanan = true
					if is_instance_valid(icon_batrai): icon_batrai.visible = false
					if is_instance_valid(icon_kupon):
						icon_kupon.visible = true
						icon_kupon.z_index = 10
					tutup_dialog_loket()
					update_misi("Pergi ke Pusat Distrik dan temui Eko untuk menukar kupon makanan.")
		"alur_pasar_eko":
			match indeks_dialog_loket:
				0: tampilkan_dialog("Speaker Kota", "[SUARA PENGUMUMAN BERDENGUNG DARI LANGIT]\nPerhatian warga Distrik Bawah. Mulai hari ini, pasokan air bersih dan energi akan dialihkan sebesar 50% ke Distrik Atas.")
				1: tampilkan_dialog("Zidane", "...Hah? Dipotong lagi? Pipa airnya beneran langsung mati total.", "sedih")
				2: tampilkan_dialog("Zidane", "Halo ko, mau tukar kupon ini sama jatah makanan harian gua.", "tenang")
				3: tampilkan_dialog("Eko", "Waduh nak, jatah makananmu terpaksa dikurangi setengah karna instruksi pengalihan energi barusan.")
				4: tampilkan_dialog("Zidane", "...Sialan, dikurangi setengah? Ini namanya disuruh mati pelan-pelan!", "sedih")
				_:
					if is_instance_valid(icon_kupon): icon_kupon.visible = false
					punya_kupon_makanan = false
					udah_sampai_pasar = true
					dekat_pusat_distrik = false
					tutup_dialog_loket()
					update_misi("Kembali pulang ke rumah bengkelmu.")
		"pulang_bengkel":
			match indeks_dialog_loket:
				0: tampilkan_dialog("Zidane", "...aku pulang...")
				1: tampilkan_dialog("Zidane", "Tumben Kamu diam aja bot", "tenang")
				2: tampilkan_dialog("Zidane", "Oy, Bot? kenapa lu? Kok diem aja?")
				3: tampilkan_dialog("Zidane", "[Zidane memeriksa robot tua di sudut ruangan. Layar robot itu gelap gulita.]", "tenang")
				4: tampilkan_dialog("Zidane", "...Inti energinya abis total... aku bisa aja ngasih setengah jatah makana ini ke dia", "merenung")
				5: tampilkan_dialog("Zidane", "kalo aku mau mati..", "tenang")
				6: tampilkan_dialog("Zidane", "[Hening lama] ...Gak ada yang lucu lagi kalau kita dipaksa mati pelan-pelan di sini.", "merenung")
				7: tampilkan_dialog("System", "👉 MISI: Dekati lemari pakaian untuk mengambil Jaket Hoodie Hijau andalanmu! 👈")
				_:
					udah_sedih_di_rumah = true
					tutup_dialog_loket()
					update_misi("Ambil Jaket Hoodie Hijau di lemari pakaian!")

func tutup_dialog_loket() -> void:
	ui_dialog.visible = false
	if foto_karakter: foto_karakter.visible = false
	sedang_dialog_loket = false
	set_player_movement(true)

# ====================================================================
# 5. KEMBALI KE RUMAH
# ====================================================================
func _on_rumah_kembali_body_entered(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" and udah_sampai_pasar == true and udah_sedih_di_rumah == false:
		set_player_movement(false)
		sedang_dialog_loket = true
		mode_loket = "pulang_bengkel"
		indeks_dialog_loket = 0
		jalankan_alur_dialog_loket()

# ====================================================================
# 6. INTERAKSI LEMARI PAKAIAN
# ====================================================================

func _on_lemari_jaket_body_entered(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" and udah_sedih_di_rumah == true and udah_pakai_hoodie == false:
		set_player_movement(false) # Kunci pergerakan pemain
		
		$CutsceneUI.visible = true
		
		$CutsceneUI/ContainerUI/AnimPlayer.play("MainkanCutscene")
		
		tampilkan_dialog("Zidane", "[Zidane membuka lemari, mengambil dan mengenakan jaket hoodie hijaunya.]", "tenang")
		
		await $CutsceneUI/ContainerUI/AnimPlayer.animation_finished
		
		tampilkan_dialog("Zidane", "Gua bakal naik ke atas. Dan gua bakal bawa matahari itu turun!", "tenang")
		
		$CutsceneUI.visible = false
		
		# 6. LOGIKA PERGANTIAN SPRITE ZIDANE KE HOODIE (YANG SUDAH DIPERBAIKI KAMU)
		
		var posisi_terakhir = karakter_kaos.global_position
		karakter_hoodie.global_position = posisi_terakhir
		if karakter_kaos.has_node("Camera2D"):
			var kamera = karakter_kaos.get_node("Camera2D")
			kamera.top_level = false
			karakter_kaos.remove_child(kamera)
			karakter_hoodie.add_child(kamera)
			kamera.position = Vector2.ZERO
			kamera.offset = Vector2.ZERO
			kamera.reset_smoothing()
		karakter_kaos.queue_free()
		karakter_hoodie.visible = true
		karakter_hoodie.set_physics_process(true)
		if sprite_lemari_jaket: sprite_lemari_jaket.visible = false
		udah_pakai_hoodie = true
		atur_batas_kamera("zona_1_bengkel")
		set_player_movement(true)
		update_misi("Keluar rumah, lalu panjat pipa pembuangan di sebelah kanan pasar menuju Level 2!")


func _on_masuk_rumah_body_entered(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_masuk_rumah = true
		var node_masuk = find_child("MasukRumah", true, false) as Node2D
		tampilkan_prompt_interaksi(node_masuk if node_masuk else self)

func _on_masuk_rumah_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_masuk_rumah = false
		sembunyikan_prompt_interaksi()

func _on_masuk_rumah_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_masuk_rumah:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_masuk_rumah()

func picu_interaksi_masuk_rumah() -> void:
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	var karakter_aktif = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
	if is_instance_valid(karakter_aktif):
		karakter_aktif.global_position = Vector2(-1340, -30)
		atur_batas_kamera("zona_1_bengkel")
		if karakter_aktif.has_node("Camera2D"):
			karakter_aktif.get_node("Camera2D").reset_smoothing()
	karakter_batrai_reset()
	udah_lewat_pintu = false

func karakter_batrai_reset():
	if is_instance_valid(icon_batrai): icon_batrai.position = Vector2(0, -35)
	if is_instance_valid(icon_kupon): icon_kupon.position = Vector2(0, -35)

# ====================================================================
# NENEK INTERACTION INTERFACE
# ====================================================================
func _on_nenek_body_entered(body: Node2D) -> void:
	if (body.name == "ZidaneKaosA" or body.name == "zidane") and not udah_ngobrol_sama_nenek:
		dekat_nenek_duduk = true
		var node_nenek = find_child("Nenek", true, false) as Node2D
		tampilkan_prompt_interaksi(node_nenek if node_nenek else self)

func _on_nenek_body_exited(body: Node2D) -> void:
	if body.name == "ZidaneKaosA" or body.name == "zidane":
		dekat_nenek_duduk = false
		sembunyikan_prompt_interaksi()

func _on_nenek_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if dekat_nenek_duduk and not udah_ngobrol_sama_nenek:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			picu_interaksi_nenek()

func picu_interaksi_nenek() -> void:
	get_viewport().set_input_as_handled()
	sembunyikan_prompt_interaksi()
	if sedang_dialog_nenek == false:
		sedang_dialog_nenek = true
		indeks_dialog_nenek = 0
		set_player_movement(false)
		jalankan_alur_dialog_nenek()

func jalankan_alur_dialog_nenek() -> void:
	match indeks_dialog_nenek:
		0: tampilkan_dialog("Zidane", "Hi nenek apa kabar?")
		1: tampilkan_dialog("Nenek", "...... eh ada tetangga... nama mu siapa ya nak... kayanya nenek pernah ngeliat kamu...")
		2: tampilkan_dialog("Zidane", "Aku Zidane nek... aku memang jarang keluar 😅")
		3: tampilkan_dialog("Nenek", "Oh zidane... tak kira udah pindah dari distrik ini...", "tenang3")
		4: tampilkan_dialog("Zidane", "Iya... pengenya 😅")
		5: tampilkan_dialog("Zidane", "....")
		6: tampilkan_dialog("Zidane", "Amm kakek di mana ya nek, biasanya dia duduk di sebelah... tumben kursinya kosong pagi begini...")
		7: tampilkan_dialog("Nenek", "Dia udah meninggal Nak... kena kanker paru-paru 4 hari yang lalu...", "tenang3")
		8: tampilkan_dialog("Zidane", "Innalillahi, turut berduka nek...", "sedih")
		9: tampilkan_dialog("Nenek", "Sebentar lagi kayanya nenek akan kesana juga...", "batuk")
		10: tampilkan_dialog("Nenek", "Sehat-sehat ya naak...")
		11: tampilkan_dialog("Zidane", "Neneek...", "sedih")
		_:
			ui_dialog.visible = false
			if foto_karakter: foto_karakter.visible = false
			sedang_dialog_nenek = false
			udah_ngobrol_sama_nenek = true
			set_player_movement(true)

# ====================================================================
# SENSOR MASUK & KELUAR AREA SATPAM KUSAM
# ====================================================================
func _on_satpam_kusam_body_entered(body: Node2D) -> void:
	if body.name == "zidane" or body.name == "ZidaneKaosA":
		dekat_satpam = true
		# === PERBAIKAN DI SINI ===
		# Tambahkan pengecekan agar tidak pemicu berulang-ulang saat menempel
		if not udah_ngobrol_sama_satpam and not sedang_dialog_satpam:
			sedang_dialog_satpam = true # Kunci di sini dulu agar tidak kepanggil berkali-kali
			picu_interaksi_satpam()

func _on_satpam_kusam_body_exited(body: Node2D) -> void:
	if body.name == "zidane" or body.name == "ZidaneKaosA":
		dekat_satpam = false
		sembunyikan_prompt_interaksi()

func picu_interaksi_satpam() -> void:
	get_viewport().set_input_as_handled()
	
	# Hapus kondisi "if sedang_dialog_satpam == false:" karena sudah kita set true di atas
	indeks_dialog_satpam = 0
	
	# 1. Matikan movement via fungsi utama (ini bakal bekerja 100% sekarang)
	set_player_movement(false) 
	
	# 2. Paksa stop fisikanya secara instan
	var player = karakter_hoodie if udah_pakai_hoodie else karakter_kaos
	if is_instance_valid(player) and "velocity" in player:
		player.velocity = Vector2.ZERO
		if player.has_method("play_anim_idle"): 
			player.call("play_anim_idle")
			
	jalankan_alur_dialog_satpam()

func jalankan_alur_dialog_satpam() -> void:
	match indeks_dialog_satpam:
		0: 
			tampilkan_dialog("Satpam Kusam", "h-Heh!", "Panik")
		1: 
			tampilkan_dialog("Satpam Kusam", "m-mau ngapain kamu kesini", "MarahS")
		2: 
			tampilkan_dialog("Zidaneh", "Huhh...","menghela")
		3: 
			tampilkan_dialog("Zidaneh", "Sorry kalo aku akan ngerepotkan mu paman","tenangz")
		4: 
			tampilkan_dialog("Zidaneh", "tapi keputusan ku dah buat, kalo aku harus pergi ke atas!", "marahz")
		5: 
			tampilkan_dialog("Zidaneh", "APAPUN CARANYA!!", "gila")
		6: 
			tampilkan_dialog("Satpam Kusam", "W-wow, s-santai nak... kalo kamu mau naik ya.. y-yaudah...", "Panik")
		7: 
			tampilkan_dialog("Zidaneh", "Hah?", "hah?")
		8: 
			tampilkan_dialog("Zidaneh", "...amm... paman gak bakal ngelaporin atau ngehadangku?", "huuh...")
		9: 
			tampilkan_dialog("Satpam Kusam", "Kaga...")
		10: 
			tampilkan_dialog("Satpam Kusam", "Dah ga ada artinya kerjaan ini...", "Tutup")
		11: 
			tampilkan_dialog("Satpam Kusam", "Aku dah ga sudi kerja sama kapitalis atas sana", "MarahS")
		12: 
			tampilkan_dialog("Zidaneh", "amm... kalo gitu...", "huuh...")
		13: 
			tampilkan_dialog("Zidaneh", "Ayo temanin aku keatas dan hidup lebih baik di sana atau mungkin melawan para kapitalis2 itu", "ngomongz")
		14: 
			tampilkan_dialog("Satpam Kusam", "Aduuh itu dah ga mungkin untuk ku naak...", "PanikMingkam")
		15: 
			tampilkan_dialog("Satpam Kusam", "Jatuh dari tangga aja udah mati kayanya aku", "Tutup")
		16: 
			tampilkan_dialog("Satpam Kusam", "Aku juga dah terima kalo akan mati di sini...", "Tutup")
		17: 
			tampilkan_dialog("Satpam Kusam", "Tapi kalo kamu kemungkinan bisa ke atas sana anak muda...")
		18: 
			tampilkan_dialog("Satpam Kusam", "Jadi ya coba aja lah...")
		19: 
			tampilkan_dialog("Zidaneh", "hemmh... makasih paman, moga hidupmu bisa jadi lebih baik", "huuh...")
		20: 
			tampilkan_dialog("Satpam Kusam", "Oh iya, Sebelumnya dah banyak sebenarnya orang yg pernah mencoba naik ke atas... Tapi hampir semuanya kembali ke sini dalam keadaat sekarat dan Pasrah... bahkan banyak yg mati di jalan...")
		21: 
			tampilkan_dialog("Satpam Kusam", "Kuperingatkan kamu kalo kesana itu hampir mustahil anak muda... Jalan disana pada hancur, banyak robot rusak yg bisa meyerang kapana aja seperti yg tadi kamu lawan di bawah. Bahkan aku tadi baru lihat ada makhluk mutasi yg terlihat ganas dan sangat berbahya", "MarahS")
		22: 
			tampilkan_dialog("Zidaneh", "hemmh... tentu ini ga akan mudah...", "menghela")
		23: 
			tampilkan_dialog("Satpam Kusam", "Tapi beberapa bulan lalu ada 2 orang seumuranmu yg kelihatnya meyakinkan tuk naik ke atas sana... Ga tau mareka berhasil apa kaga")
		24: 
			tampilkan_dialog("Satpam Kusam", "kalo kamu mau keatas itu ga akan mudah... kamu harus punya tekat yg kuat nak, dan sadar kalo kamu akan lebih cepat mati kalo mencoba ke atas sana...", "MarahS")
		25: 
			tampilkan_dialog("Zidaneh", "Sebelumnya aku dah bilang kalo keputusan ku dah bulat", "menghela")
		26: 
			tampilkan_dialog("Zidaneh", "Jadi akukan kesana apapun rintangannya", "tenangz")
		27: 
			tampilkan_dialog("Zidaneh", "Kalaupun aku mati...", "huuh...")
		28: 
			tampilkan_dialog("Zidaneh", "Setidaknya aku mati dengan Gaya", "canda")
		29: 
			tampilkan_dialog("Satpam Kusam", "Yah semuga kamu berhasil Nak muda")
		30: 
			tampilkan_dialog("Zidaneh", "Makasih Paman...")
		_:
			ui_dialog.visible = false
			if foto_karakter: foto_karakter.visible = false
			sedang_dialog_satpam = false
			
			# === KUNCI DIALOG ===
			udah_ngobrol_sama_satpam = true 
			
			set_player_movement(true) # Bebaskan kembali pergerakan Zidane
			update_misi("Gunakan pipa dan rantai untuk memanjat ke langit-langit Distrik Bawah!")

# ====================================================================
# ZONE TELEPORTATION
# ====================================================================
func _on_tpzona_3_body_entered(body: Node2D) -> void:
	var target = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
	if (body.name == "ZidaneKaosA" or body.name == "zidane") and udah_pindah_zona == false:
		if is_instance_valid(target):
			target.global_position = Vector2(760, -220)
			atur_batas_kamera("zona_3_pasar")
			if target.has_node("Camera2D"):
				target.get_node("Camera2D").reset_smoothing()

func _on_tpzona_4_body_entered(body: Node2D) -> void:
	var target = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
	if (body.name == "ZidaneKaosA" or body.name == "zidane") and udah_pindah_zona1 == false:
		if is_instance_valid(target):
			target.global_position = Vector2(-115, -100)
			atur_batas_kamera("zona_luar_bebas")
			if target.has_node("Camera2D"):
				target.get_node("Camera2D").reset_smoothing()
				
func _on_tpzona_5_body_entered(body: Node2D) -> void:
	if body.name == "zidane" and udah_pakai_hoodie == true and udah_masuk_zona4 == false:
		if is_instance_valid(karakter_hoodie):
	
			karakter_hoodie.global_position = Vector2(2045, 95) 
			
			# Mengubah pembatasan kamera mengikuti area vertikal masif
			atur_batas_kamera("zona_4_parallax")
			
			if karakter_hoodie.has_node("Camera2D"):
				karakter_hoodie.get_node("Camera2D").reset_smoothing()
			
			# Perbarui HUD misi di layar siber game
			update_misi("Gunakan pipa dan rantai untuk memanjat ke langit-langit Distrik Bawah!")

# ====================================================================
# SISTEM DINAMIS BATAS KAMERA
# ====================================================================
func atur_batas_kamera(zona: String) -> void:
	var karakter_aktif = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
	if is_instance_valid(karakter_aktif) and karakter_aktif.has_node("Camera2D"):
		var kamera = karakter_aktif.get_node("Camera2D")
		
		if group_parallax_4:
			group_parallax_4.visible = (zona == "zona_4_parallax")
		
		match zona:
			"zona_1_bengkel":
				kamera.limit_left = -1521
				kamera.limit_top = -127
				kamera.limit_right = -1306
				kamera.limit_bottom = -9
				kamera.zoom = Vector2(5.380, 5.380)
				kamera.offset = Vector2.ZERO
				kamera.global_position = Vector2(-1413, -68)
			"zona_luar_bebas":
				kamera.top_level = false
				kamera.position = Vector2.ZERO
				kamera.offset = Vector2(-10, 0)
				kamera.zoom = Vector2(3.0, 3.0)
				kamera.limit_left = -850
				kamera.limit_top = -550
				kamera.limit_right = -105
				kamera.limit_bottom = 0
			"zona_3_pasar":
				kamera.top_level = false
				kamera.position = Vector2.ZERO
				kamera.offset = Vector2(0, -25)
				kamera.zoom = Vector2(3.0, 3.0)
				kamera.limit_left = 750
				kamera.limit_top = -450
				kamera.limit_right = 1750
				kamera.limit_bottom = -100
			"zona_4_parallax":
				kamera.top_level = false
				kamera.position = Vector2.ZERO
				kamera.offset = Vector2.ZERO
				kamera.zoom = Vector2(3.0, 3.0) 
				kamera.limit_left = 1900     
				kamera.limit_right = 8000     
				kamera.limit_bottom = 1050     
				kamera.limit_top = -3000      

# ====================================================================
# PUSAT LOGIKA DIALOG (MENAMPILKAN, ANIMASI)
# ====================================================================
func tampilkan_dialog(nama_pembicara: String, isi_dialog: String, ekspresi: String = "Biasa") -> void:
	if ui_dialog and teks_nama and teks_konten:
		if is_instance_valid(foto_karakter):
			match nama_pembicara:
				"Zidane":
					match ekspresi:
						"sedih": foto_karakter.texture = load("res://Character Image/avatar_zidane_sedih.png")
						"tenang": foto_karakter.texture = load("res://Character Image/avatar_zidane_biasa.png")
						"merenung": foto_karakter.texture = load("res://Character Image/avatar_zidane_merenung.png")
						_: foto_karakter.texture = load("res://Character Image/avatar_zidane.png")
					foto_karakter.visible = true
					foto_karakter.global_position = Vector2(-40, 145)
					foto_karakter.flip_h = false
				"Zidaneh":
					match ekspresi:
						"sedihz": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Sedihe")
						"tenangz": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Tenang.png")
						"huuh...": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Huuh.png")
						"awkward": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_awkward.png")
						"awkwardMalu": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_awkward_malu.png")
						"gila": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Gila.png")
						"canda": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Becuanda.png")
						"hohoo": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Hohoo.png")
						"hah?": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Huh.png")
						"kaget2": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Kaget2.png")
						"kaget": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Kaget.png")
						"malusenang": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Malu_Dengan_Kongklusi.png")
						"malusadar": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Malu_Sadar.png")
						"ngerayu": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_ZIdane_")
						"seyum": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Senyum.png")
						"takut": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Takut.png")
						"teriak": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Teriak.png")
						"turu": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Turu.png")
						"marahz": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_marah.png")
						"ngomongz": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Ngomong_Buka_mata.png")
						"menghela": foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_Menghela_Tutup.png")
						_: foto_karakter.texture = load("res://Character Image/Eksperesi Zidane H/Avatar_Zidane_ Gomong_Ceria.png")
					foto_karakter.visible = true
					foto_karakter.global_position = Vector2(-40, 145)
					foto_karakter.flip_h = false
				"Satpam Kusam":
					match ekspresi:
						"Tutup": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_Tutup.png")
						"Apa?": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_Apatu.png")
						"Panik": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_PanikBuka.png")
						"PanikMingkam": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_PanikTutup (4).png")
						"MarahS": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_Marah.png")
						"BingungS": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_Bingung.png")
						"KagetS": foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam_Kagetlah.png")
						_: foto_karakter.texture = load("res://Character Image/Penjaga Gerbang/avatar_satpam_kusam.png")
					foto_karakter.visible = true
					foto_karakter.global_position.x = 840
					foto_karakter.global_position.y = 140
					foto_karakter.flip_h = true
				"Loket":
					foto_karakter.texture = load("res://Character Image/avatar_loket.png")
					foto_karakter.visible = true
					foto_karakter.global_position.x = 840
					foto_karakter.flip_h = true
				"Eko":
					foto_karakter.texture = load("res://Character Image/avatar_eko.png")
					foto_karakter.visible = true
					foto_karakter.global_position.x = 840
					foto_karakter.flip_h = true
				"Robot Tua":
					match ekspresi:
						"tenang2": foto_karakter.texture = load("res://Character Image/avatar_robot_tenang.png")
						_: foto_karakter.texture = load("res://Character Image/avatar_robot.png")
					foto_karakter.visible = true
					foto_karakter.global_position.x = 840
					foto_karakter.flip_h = true
				"Nenek":
					match ekspresi:
						"batuk": foto_karakter.texture = load("res://Character Image/avatar_nenek_batuk.png")
						"tenang3": foto_karakter.texture = load("res://Character Image/avatar_nenek_tanang3.png")
						_: foto_karakter.texture = load("res://Character Image/avatar_nenek.png")
					foto_karakter.visible = true
					foto_karakter.global_position.x = 840
					foto_karakter.flip_h = true
				_:
					foto_karakter.visible = false
					
		var gaya_kotak = StyleBoxFlat.new()
		gaya_kotak.bg_color = Color(0.05, 0.05, 0.05, 0.75)
		gaya_kotak.set_corner_radius_all(6)
		gaya_kotak.set_border_width_all(2)
		gaya_kotak.border_color = Color(0.0, 1.0, 0.2)
		gaya_kotak.shadow_color = Color(0.0, 1.0, 0.2, 0.35)
		gaya_kotak.shadow_size = 6
		gaya_kotak.content_margin_left = 16
		gaya_kotak.content_margin_top = 12
		gaya_kotak.content_margin_right = 16
		gaya_kotak.content_margin_bottom = 12
		ui_dialog.add_theme_stylebox_override("panel", gaya_kotak)
		
		teks_nama.text = nama_pembicara
		teks_konten.text = isi_dialog
		teks_konten.visible_ratio = 0.0
		ui_dialog.visible = true
		ui_dialog.modulate.a = 0.0
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(ui_dialog, "modulate:a", 1.0, 0.2)
		tween.tween_property(teks_konten, "visible_ratio", 1.0, isi_dialog.length() * 0.03).set_trans(Tween.TRANS_LINEAR)

func set_player_movement(_bisa_gerak: bool) -> void:
	var karakter_aktif = karakter_kaos if is_instance_valid(karakter_kaos) else karakter_hoodie
	if is_instance_valid(karakter_aktif):
		# Jangan pakai set_physics_process karena sering konflik dengan animasi
		if "velocity" in karakter_aktif:
			karakter_aktif.velocity = Vector2.ZERO

# ====================================================================
# 🛠️ TOMBOL SAKTI UNTUK TESTING INSTAN ZONA 4 (PAKSA POSISI KAMERA RESET)
# ====================================================================

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		print("Memicu Lompatan Debugger Siber ke Zona 4...")
		
		# 1. Paksa status alur cerita dan NYALAKAN PARALLAX ZONA 4 SEJAK AWAL
		udah_pakai_hoodie = true
		udah_masuk_zona4 = true
		
		if group_parallax_4:
			group_parallax_4.visible = true
		
		var kamera_utama: Camera2D = null
		if is_instance_valid(karakter_kaos) and karakter_kaos.has_node("Camera2D"):
			kamera_utama = karakter_kaos.get_node("Camera2D")
		
		if is_instance_valid(karakter_kaos):
			karakter_kaos.visible = false
			karakter_kaos.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
			
		if is_instance_valid(karakter_hoodie):
			karakter_hoodie.visible = true
			karakter_hoodie.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
			karakter_hoodie.set_physics_process(true)
			karakter_hoodie.set_process(true)
			
			if karakter_hoodie.has_node("CollisionShape2D"):
				karakter_hoodie.get_node("CollisionShape2D").set_deferred("disabled", false)
			
			karakter_hoodie.global_position = Vector2(2930, -360) 
			
			if kamera_utama and is_instance_valid(kamera_utama):
				kamera_utama.limit_left = -100000
				kamera_utama.limit_right = 100000
				kamera_utama.limit_top = -100000
				kamera_utama.limit_bottom = 100000
				
				kamera_utama.top_level = false
				
				if kamera_utama.get_parent():
					kamera_utama.get_parent().remove_child(kamera_utama)
				karakter_hoodie.add_child(kamera_utama)
				
				kamera_utama.position = Vector2.ZERO
				kamera_utama.global_position = karakter_hoodie.global_position
				kamera_utama.offset = Vector2.ZERO
				kamera_utama.make_current() 
				kamera_utama.reset_smoothing() 
			
			# Jalankan batas kamera Zona 4 bawaanmu
			atur_batas_kamera("zona_4_parallax")
			
			# Paksa ukuran zoom & reset smoothing kembali
			if is_instance_valid(kamera_utama):
				kamera_utama.position = Vector2.ZERO
				kamera_utama.zoom = Vector2(3.0, 3.0) # Sesuaikan dengan zoom idealmu kemarin (misal 2.5 atau 2.0)
				kamera_utama.reset_smoothing()
		
		if has_node("CutsceneUI"):
			$CutsceneUI.visible = false
		if ui_dialog:
			ui_dialog.visible = false
			
		update_misi("DEBUG KEY ACTIVATED: Parallax 4 Aktif & Siap Diuji!")
