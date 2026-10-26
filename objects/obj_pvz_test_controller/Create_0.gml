logic_clock_init();
reanim_init();
pvz_lawn_load_strings();
global.pvz_lawn_steps = 0;
// Keep the source logic clock available for cutscene zombie idle reanimations while board gameplay is paused.
global.pvz_lawn_visual_steps = 0;
global.pvz_lawn_tick = 0;
// Board::ZombieHitHouse / CutScene::StartZombiesWon state, using original 100Hz timing constants.
global.pvz_lawn_lost_state = "";
global.pvz_lawn_lost_tick = 0;
global.pvz_lawn_lost_winner = noone;
global.pvz_lawn_lost_reanim = undefined;
// CutScene.cpp: StartReadySetPlant runs for 183 source logic ticks (6000..7830ms).
global.pvz_lawn_ready_set_plant_ticks = -1;
global.pvz_lawn_ready_set_plant_reanim = new Reanim("StartReadySetPlant", 400, 324);
global.pvz_lawn_ready_set_plant_reanim.dead = true;
// CutScene.cpp: move the Board from +BOARD_OFFSET_X, across the street, then back to x=0.
// camera_x is the inverse board translation because world sprites draw at world_x - camera_x.
global.pvz_lawn_camera_x = -PVZ_BOARD_OFFSET_X;
global.pvz_lawn_camera_pan_tick = 0; // Original cutscene times advance by 10 per 100Hz logic tick.
global.pvz_lawn_active_rows = 5;
// Original CutScene::Update pauses at mSeedChoosing until the player clicks Let's Rock.
global.pvz_lawn_seed_chooser_entered = false;
global.pvz_lawn_seed_chooser_active = false;
global.pvz_lawn_seed_chooser_completed = false;
global.pvz_lawn_seed_chooser_panel_y = 720;
global.pvz_lawn_seed_chooser_selected = [];
global.pvz_lawn_seed_chooser_frame = 0;
global.pvz_lawn_seed_chooser_flights = array_create(10, undefined);
// Original first-time Adventure Level 1: four waves, first countdown 1800, normal countdown 2500..3099.
global.pvz_lawn_spawn_wave = 0;
global.pvz_lawn_spawn_wave_count = 4; // gZombieWaves[0] from Challenge.cpp.
global.pvz_lawn_spawn_countdown = 1800; // ZOMBIE_COUNTDOWN_FIRST_WAVE in GameConstants.h.
global.pvz_lawn_grid = ds_grid_create(PVZ_COLS, pvz_lawn_active_rows());
ds_grid_clear(global.pvz_lawn_grid, noone);
global.pvz_lawn_sun = 150;
global.pvz_lawn_sun_countdown = 425 + irandom(274); // Board initialization: SUN_COUNTDOWN + Rand(SUN_COUNTDOWN_RANGE).
global.pvz_lawn_suns_fallen = 0;
global.pvz_lawn_selected = "";
global.pvz_lawn_message = "Choose a seed card, then click an empty lawn square.";
global.pvz_lawn_message_ticks = 320;
global.pvz_shadow_sprite = reanim_get_part_sprite("images/plantshadow.png");
global.pvz_shadow2_sprite = reanim_get_part_sprite("images/plantshadow2.png");
global.pvz_lawn_bg_sprite = reanim_get_part_sprite("images/background1.png");
// Numpad 1-6 switch the complete test board to an original PvZ lawn environment.
// Pool environments rebuild to six rows with the original two pool lanes.
global.pvz_lawn_bg_sprites = [
    reanim_get_part_sprite("images/background1.png"),
    reanim_get_part_sprite("images/background2.png"),
    reanim_get_part_sprite("images/background3.jpg"),
    reanim_get_part_sprite("images/background3.jpg"),
    reanim_get_part_sprite("images/background5.png"),
    reanim_get_part_sprite("images/background6boss.jpg")
];
global.pvz_lawn_environment_index = 0;
global.pvz_lawn_environment_labels = ["Day Lawn", "Night Lawn", "Pool Day", "Pool Night", "Roof", "Boss Roof"];
// Board::DrawIce and PoolEffect::PoolEffectUpdate state (one ice strip/timer per lawn row).
global.pvz_lawn_ice_min_x = array_create(pvz_lawn_active_rows(), 800);
global.pvz_lawn_ice_timer = array_create(pvz_lawn_active_rows(), 0);
global.pvz_lawn_pool_counter = 0;
global.pvz_lawn_pool_base_day = reanim_get_part_sprite("images/pool_base.jpg");
global.pvz_lawn_pool_shading_day = reanim_get_part_sprite("images/pool_shading.jpg");
global.pvz_lawn_pool_base_night = reanim_get_part_sprite("images/pool_base_night.jpg");
global.pvz_lawn_pool_shading_night = reanim_get_part_sprite("images/pool_shading_night.jpg");
global.pvz_lawn_pool_caustic = reanim_get_part_sprite("images/pool_caustic_effect.jpg");
global.pvz_lawn_help_open = false;
// Native original parts reused by zombie special mechanics (not replacement artwork).
global.pvz_zombie_ladder_sprite = reanim_get_part_sprite("reanim/Zombie_ladder_5.png");
global.pvz_catapult_ball_sprite = reanim_get_part_sprite("reanim/Zombie_catapult_basketball.png");
global.pvz_fx_pea = pvz_lawn_load_sprite("ProjectilePea.png", 1);
global.pvz_fx_snowpea = pvz_lawn_load_sprite("ProjectileSnowPea.png", 1);
global.pvz_fx_splat = pvz_lawn_load_sprite("pea_splats.png", 4);
global.pvz_fx_zombie_head = pvz_lawn_load_sprite("ZombieHead.png", 1);
global.pvz_fx_zombie_arm = pvz_lawn_load_sprite("ZombieArm.png", 1);
global.pvz_fx_pole_head = pvz_lawn_load_sprite("ZombiePoleVaulterHead.png", 1);
global.pvz_fx_dancer_head = pvz_lawn_load_sprite("ZombieDancerHead.png", 1);
global.pvz_fx_backup_dancer_head = pvz_lawn_load_sprite("ZombieBackupDancerHead.png", 1);
global.pvz_fx_football_head = pvz_lawn_load_sprite("ZombieFootballHead.png", 1);
global.pvz_fx_balloon_head = pvz_lawn_load_sprite("ZombieBalloonHead.png", 1);
global.pvz_fx_digger_head = pvz_lawn_load_sprite("ZombieDiggerHead.png", 1);
global.pvz_fx_dolphin_head = pvz_lawn_load_sprite("ZombieDolphinRiderHead.png", 1);
global.pvz_fx_bobsled_head = pvz_lawn_load_sprite("ZombieBobsledHead.png", 1);
global.pvz_fx_imp_head = pvz_lawn_load_sprite("ZombieImpHead.png", 1);
global.pvz_fx_ladder_head = pvz_lawn_load_sprite("ZombieLadderHead.png", 1);
global.pvz_fx_pogo_head = pvz_lawn_load_sprite("ZombiePogoHead.png", 1);
global.pvz_fx_yeti_head = pvz_lawn_load_sprite("ZombieYetiHead.png", 1);
global.pvz_fx_digger_arm = pvz_lawn_load_sprite("ZombieDiggerArm.png", 1);
global.pvz_fx_jackbox_arm = pvz_lawn_load_sprite("ZombieJackboxArm.png", 1);
global.pvz_fx_dancer_spotlight = reanim_get_part_sprite("reanim/spotlight.png");
global.pvz_fx_dancer_spotlight2 = reanim_get_part_sprite("reanim/spotlight2.png");
global.pvz_fx_cone = pvz_lawn_load_sprite("Zombie_cone3.png", 1);
global.pvz_fx_bucket = pvz_lawn_load_sprite("Zombie_bucket3.png", 1);
global.pvz_fx_cone2 = pvz_lawn_load_sprite("Zombie_cone2.png", 1);
global.pvz_fx_bucket2 = pvz_lawn_load_sprite("Zombie_bucket2.png", 1);
global.pvz_fx_arm_stump = pvz_lawn_load_sprite("Zombie_outerarm_upper2.png", 1);
global.pvz_fx_pole_arm_stump = pvz_lawn_load_sprite("Zombie_polevaulter_outerarm_upper2.png", 1);
global.pvz_fx_pole_arm = pvz_lawn_load_sprite("Zombie_polevaulter_outerarm_lower.png", 1);
global.pvz_seedbank_sprite = pvz_lawn_load_sprite("SeedBank.png", 1);
global.pvz_seeds_atlas = pvz_lawn_load_sprite("seeds.png", 1);
// SeedChooserScreen.cpp uses these original image resources and their native dimensions.
// The extracted project has the original button art but may not include the chooser background PNG;
// only ask the reanimation loader for that optional file when it is actually present, avoiding a
// misleading missing-image console warning. The draw helper has a self-contained visual fallback.
var _chooser_bg_path = working_directory + "datafiles/parts/images/SeedChooser_Background.png";
if (!file_exists(_chooser_bg_path)) _chooser_bg_path = working_directory + "parts/images/SeedChooser_Background.png";
global.pvz_seed_chooser_background_sprite = file_exists(_chooser_bg_path)
    ? reanim_get_part_sprite("images/SeedChooser_Background.png") : -1;
global.pvz_seed_chooser_button_sprite = reanim_get_part_sprite("images/SeedChooser_Button.png");
global.pvz_seed_chooser_button_glow_sprite = reanim_get_part_sprite("images/SeedChooser_Button_Glow.png");
var _chooser_disabled_button_path = working_directory + "datafiles/parts/images/SeedChooser_Button_Disabled.png";
if (!file_exists(_chooser_disabled_button_path)) _chooser_disabled_button_path = working_directory + "parts/images/SeedChooser_Button_Disabled.png";
global.pvz_seed_chooser_button_disabled_sprite = file_exists(_chooser_disabled_button_path)
    ? reanim_get_part_sprite("images/SeedChooser_Button_Disabled.png") : -1;
var _seed_silhouette_path = working_directory + "datafiles/parts/images/SeedPacketSilhouette.png";
if (!file_exists(_seed_silhouette_path)) _seed_silhouette_path = working_directory + "parts/images/SeedPacketSilhouette.png";
global.pvz_seed_packet_silhouette_sprite = file_exists(_seed_silhouette_path)
    ? reanim_get_part_sprite("images/SeedPacketSilhouette.png") : -1;
global.pvz_shovel_bank_sprite = pvz_lawn_load_sprite("ShovelBank.png", 1);
global.pvz_shovel_sprite = pvz_lawn_load_sprite("Shovel.png", 1);
global.pvz_menu_button_sprite = pvz_lawn_load_sprite("button_small.png", 1);
global.pvz_menu_button_down_sprite = pvz_lawn_load_sprite("button_down_small.png", 1);
// Original GameButton::DrawStoneButton images for the top-right MENU control.
global.pvz_button_left = pvz_lawn_load_sprite("button_left.png", 1);
global.pvz_button_middle = pvz_lawn_load_sprite("button_middle.png", 1);
global.pvz_button_right = pvz_lawn_load_sprite("button_right.png", 1);
global.pvz_button_down_left = pvz_lawn_load_sprite("button_down_left.png", 1);
global.pvz_button_down_middle = pvz_lawn_load_sprite("button_down_middle.png", 1);
global.pvz_button_down_right = pvz_lawn_load_sprite("button_down_right.png", 1);
global.pvz_pause_panel_sprite = pvz_lawn_load_sprite("options_menuback_.png", 1);
global.pvz_resume_button_sprite = pvz_lawn_load_sprite("options_backtogamebutton0.png", 1);
global.pvz_resume_button_hover_sprite = pvz_lawn_load_sprite("options_backtogamebutton2.png", 1);
global.pvz_main_menu_button_sprite = pvz_lawn_load_sprite("Store_MainMenuButton.png", 1);
global.pvz_main_menu_button_hover_sprite = pvz_lawn_load_sprite("Store_MainMenuButtonHighlight.png", 1);
global.pvz_main_menu_button_down_sprite = pvz_lawn_load_sprite("Store_MainMenuButtonDown.png", 1);
// Original PvZ game-over doorway layers (Board::DrawHouseDoorBottom/Top).
global.pvz_lawn_door_mask_sprite = pvz_lawn_load_sprite("background1_gameover_mask.png", 1);
global.pvz_lawn_door_interior_sprite = pvz_lawn_load_sprite("background1_gameover_interior_overlay.png", 1);
// The original NewOptionsDialog and LawnDialog assets are included in datafiles/parts/images.
global.pvz_lawn_options_bg_sprite = reanim_get_part_sprite("images/options_menuback.jpg");
global.pvz_lawn_options_back_sprite = reanim_get_part_sprite("images/options_backtogamebutton0.png");
global.pvz_lawn_options_back_down_sprite = reanim_get_part_sprite("images/options_backtogamebutton2.png");
global.pvz_lawn_options_check_off_sprite = reanim_get_part_sprite("images/options_checkbox0.png");
global.pvz_lawn_options_check_on_sprite = reanim_get_part_sprite("images/options_checkbox1.png");
global.pvz_lawn_options_slider_sprite = reanim_get_part_sprite("images/options_sliderslot.png");
global.pvz_lawn_options_knob_sprite = reanim_get_part_sprite("images/options_sliderknob2.png");
global.pvz_lawn_dialog_header_sprite = reanim_get_part_sprite("images/dialog_header.png");
global.pvz_lawn_dialog_tl_sprite = reanim_get_part_sprite("images/dialog_topleft.png");
global.pvz_lawn_dialog_tm_sprite = reanim_get_part_sprite("images/dialog_topmiddle.png");
global.pvz_lawn_dialog_tr_sprite = reanim_get_part_sprite("images/dialog_topright.png");
global.pvz_lawn_dialog_ml_sprite = reanim_get_part_sprite("images/dialog_centerleft.png");
global.pvz_lawn_dialog_mm_sprite = reanim_get_part_sprite("images/dialog_centermiddle.png");
global.pvz_lawn_dialog_mr_sprite = reanim_get_part_sprite("images/dialog_centerright.png");
global.pvz_lawn_dialog_bl_sprite = reanim_get_part_sprite("images/dialog_bottomleft.png");
global.pvz_lawn_dialog_bm_sprite = reanim_get_part_sprite("images/dialog_bottommiddle.png");
global.pvz_lawn_dialog_br_sprite = reanim_get_part_sprite("images/dialog_bottomright.png");
// Options values are also initialized when gameplay starts without first opening the title menu.
if (!variable_global_exists("pvz_lawn_sfx_enabled")) global.pvz_lawn_sfx_enabled = true;
if (!variable_global_exists("pvz_lawn_music_enabled")) global.pvz_lawn_music_enabled = true;
if (!variable_global_exists("pvz_lawn_sfx_volume")) global.pvz_lawn_sfx_volume = global.pvz_lawn_sfx_enabled ? 1.0 : 0.0;
if (!variable_global_exists("pvz_lawn_music_volume")) global.pvz_lawn_music_volume = global.pvz_lawn_music_enabled ? 1.0 : 0.0;
if (!variable_global_exists("pvz_lawn_fullscreen_enabled")) global.pvz_lawn_fullscreen_enabled = window_get_fullscreen();
if (!variable_global_exists("pvz_lawn_accel_enabled")) global.pvz_lawn_accel_enabled = true;
global.pvz_lawn_gameover_x = 185;
global.pvz_lawn_gameover_y = 150;
global.pvz_lawn_gameover_dragging = false;
global.pvz_lawn_gameover_drag_dx = 0;
global.pvz_lawn_gameover_drag_dy = 0;
global.pvz_lawn_menu_open = false;
global.pvz_lawn_shovel_selected = false;
global.pvz_packet_flash_sprite = pvz_lawn_load_sprite("SeedPacketFlash.png", 1);
global.pvz_packet_glow_sprite = pvz_lawn_load_sprite("SeedPacketGlow.png", 1);
global.pvz_lawn_packet_sunflower_refresh = 0;
global.pvz_lawn_packet_peashooter_refresh = 0;
global.pvz_lawn_packet_sunflower_flash = 0;
global.pvz_lawn_packet_peashooter_flash = 0;
// Track CanPickUp transitions so a packet that recharges while unaffordable still flashes when sun arrives.
global.pvz_lawn_packet_sunflower_ready_state = true;
global.pvz_lawn_packet_peashooter_ready_state = true;
// Bush::BushInitialize uses these exact rows/positions; subtract BOARD_ADDITIONAL_WIDTH (240)
// to convert the wide edition's world coordinates to this 800px board.
// The native PC lawn background carries its own scenery; do not spawn Xbox/QEWide bush overlays.
// The runtime draws board objects directly in lawn coordinates (the background alone is cropped
// by PVZ_BOARD_OFFSET_X), so the original source x=-160 would be entirely off-screen at camera_x=0.
// Translate that source position into this project's visible left edge; keep the source row Y formula.
// CutScene keeps lawn items hidden until Ready, Set, Plant finishes.
for (var _pvz_mower_row = 0; _pvz_mower_row < pvz_lawn_active_rows(); _pvz_mower_row++) {
    if (pvz_lawn_is_pool_row(_pvz_mower_row)) continue;
    var _pvz_mower_y = pvz_lawn_row_y(_pvz_mower_row, -45, 23);
    instance_create_layer(-45, _pvz_mower_y, "Instances", obj_pvz_lawn_mower, {row: _pvz_mower_row});
}
// CutScene::PlaceStreetZombies for the original first adventure level: its four waves
// contain five normal zombies total, so the source preview capacity (10) displays all five.
// FindPlaceForStreetZombies chooses five unique cells from a 5x5 street grid (except cell 4,0).
var _pvz_street_taken = array_create(25, false);
for (var _pvz_preview_i = 0; _pvz_preview_i < 5; _pvz_preview_i++) {
    var _pvz_street_col = 0;
    var _pvz_street_row = 0;
    var _pvz_street_cell = 20;
    while (_pvz_street_cell == 20 || _pvz_street_taken[_pvz_street_cell]) {
        _pvz_street_col = irandom(4);
        _pvz_street_row = irandom(4);
        _pvz_street_cell = _pvz_street_col * 5 + _pvz_street_row;
    }
    _pvz_street_taken[_pvz_street_cell] = true;
    var _pvz_street_x = PVZ_STREET_ZOMBIE_START_X + _pvz_street_col * PVZ_STREET_ZOMBIE_GRID_X + irandom(14);
    var _pvz_street_y = PVZ_STREET_ZOMBIE_START_Y + _pvz_street_row * PVZ_STREET_ZOMBIE_GRID_Y + ((_pvz_street_col mod 2) * 30) + irandom(14);
    var _pvz_street_preview = instance_create_layer(_pvz_street_x, _pvz_street_y, "Instances", obj_zombie_basic, {row: _pvz_street_row, intro_preview: true});
    _pvz_street_preview.intro_preview = true;
    _pvz_street_preview.x = _pvz_street_x;
    _pvz_street_preview.y = _pvz_street_y;
    _pvz_street_preview.depth = -_pvz_street_y - 31;
}
// The six added packet definitions follow Lawn/Plant.cpp gPlantDefs in the linked OG source.
// The values are source Sun costs and refresh counters (100 Hz logic ticks).
global.pvz_lawn_seed_kinds = ["sunflower", "peashooter", "cherry_bomb", "wallnut", "potato_mine", "snow_pea", "chomper", "repeater", "lily_pad", "flower_pot"];
global.pvz_lawn_seed_costs = [50, 100, 150, 50, 25, 175, 150, 200, 25, 25];
global.pvz_lawn_seed_recharges = [750, 750, 5000, 3000, 3000, 750, 750, 750, 750, 750];
global.pvz_lawn_seed_labels = ["Sunflower", "Peashooter", "Cherry Bomb", "Wall-nut", "Potato Mine", "Snow Pea", "Chomper", "Repeater", "Lily Pad", "Flower Pot"];
global.pvz_lawn_seed_tooltip_keys = ["SUNFLOWER", "PEASHOOTER", "CHERRY_BOMB", "WALL_NUT", "POTATO_MINE", "SNOW_PEA", "CHOMPER", "REPEATER", "LILY_PAD", "FLOWER_POT"];
// Stable chooser inventory, kept separate from the user's selected bank.
global.pvz_lawn_seed_available_kinds = global.pvz_lawn_seed_kinds;
global.pvz_lawn_seed_available_costs = global.pvz_lawn_seed_costs;
global.pvz_lawn_seed_available_recharges = global.pvz_lawn_seed_recharges;
global.pvz_lawn_seed_available_labels = global.pvz_lawn_seed_labels;
global.pvz_lawn_seed_available_tooltip_keys = global.pvz_lawn_seed_tooltip_keys;
global.pvz_lawn_seed_chooser_icons = array_create(array_length(global.pvz_lawn_seed_available_kinds), undefined);
for (var _seed_chooser_i = 0; _seed_chooser_i < array_length(global.pvz_lawn_seed_available_kinds); _seed_chooser_i++) {
    global.pvz_lawn_seed_chooser_icons[_seed_chooser_i] = pvz_lawn_create_plant_ui_icon(global.pvz_lawn_seed_available_kinds[_seed_chooser_i]);
}
global.pvz_lawn_seed_packet_refresh = array_create(10, 0);
global.pvz_lawn_seed_packet_flash = array_create(10, 0);
global.pvz_lawn_seed_packet_ready_state = array_create(10, true);
global.pvz_lawn_seed_packet_icons = array_create(10, undefined);
global.pvz_lawn_seed_ghost_icons = array_create(10, undefined);
global.pvz_lawn_seed_cursor_icons = array_create(10, undefined);
for (var _seed_ui_i = 0; _seed_ui_i < array_length(global.pvz_lawn_seed_kinds); _seed_ui_i++) {
    var _seed_ui_kind = global.pvz_lawn_seed_kinds[_seed_ui_i];
    global.pvz_lawn_seed_packet_icons[_seed_ui_i] = pvz_lawn_create_plant_ui_icon(_seed_ui_kind);
    global.pvz_lawn_seed_ghost_icons[_seed_ui_i] = pvz_lawn_create_plant_ui_icon(_seed_ui_kind);
    global.pvz_lawn_seed_cursor_icons[_seed_ui_i] = pvz_lawn_create_plant_ui_icon(_seed_ui_kind);
}
window_set_size(800, 600);
depth = 100000;
