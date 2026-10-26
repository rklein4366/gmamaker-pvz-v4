/// Original-style PvZ startup/title loader, followed by the animated SelectorScreen reanimation.
logic_clock_init();
reanim_init();
pvz_lawn_load_strings();
boot_state = "popcap";
boot_ticks = 0;
load_ticks = 0;
load_ticks_total = 380; // Determinate local-load stand-in; the actual project assets are already installed.
load_progress = 0;
start_transition_ticks = 0;
start_clicked = false;
menu_initialized = false;
menu_reanim = undefined;
leaf_reanim = undefined;
hand_reanim = undefined;
menu_sign_started = false;
hover_start_prev = false;
hover_minigame_prev = false;
hover_puzzle_prev = false;
hover_vasebreaker_prev = false;
hover_almanac_prev = false;
hover_store_prev = false;
hover_zengarden_prev = false;
hover_change_user_prev = false;
hover_options_prev = false;
hover_help_prev = false;
hover_quit_prev = false;
hover_start_adventure = false;
hover_minigame = false;
hover_puzzle = false;
hover_vasebreaker = false;
hover_almanac = false;
hover_store = false;
hover_zengarden = false;
hover_change_user = false;
hover_options = false;
hover_help = false;
hover_quit = false;

// Button images and hitboxes mirror GameSelector.cpp / NewLawnButton::Draw.
// Install_PvZ_Sounds.bat installs these original assets from the supplied PvZ asset folder.
menu_spr_adventure = reanim_get_part_sprite("reanim/SelectorScreen_Adventure_button.png");
menu_spr_adventure_highlight = reanim_get_part_sprite("reanim/SelectorScreen_Adventure_highlight.png");
menu_spr_start_adventure = reanim_get_part_sprite("reanim/SelectorScreen_StartAdventure_Button1.png");
menu_spr_start_adventure_highlight = reanim_get_part_sprite("reanim/SelectorScreen_StartAdventure_Highlight.png");
menu_spr_minigame = reanim_get_part_sprite("reanim/SelectorScreen_Survival_button.png");
menu_spr_minigame_highlight = reanim_get_part_sprite("reanim/SelectorScreen_Survival_highlight.png");
menu_spr_puzzle = reanim_get_part_sprite("reanim/SelectorScreen_Challenges_button.png");
menu_spr_puzzle_highlight = reanim_get_part_sprite("reanim/SelectorScreen_Challenges_highlight.png");
menu_spr_vasebreaker = reanim_get_part_sprite("reanim/SelectorScreen_Vasebreaker_button.png");
menu_spr_vasebreaker_highlight = reanim_get_part_sprite("reanim/SelectorScreen_vasebreaker_highlight.png");
menu_spr_change_user_pressed = reanim_get_part_sprite("reanim/SelectorScreen_WoodSign2_press.png");
menu_spr_almanac = reanim_get_part_sprite("images/SelectorScreen_Almanac.png");
menu_spr_almanac_highlight = reanim_get_part_sprite("images/SelectorScreen_AlmanacHighlight.png");
menu_spr_store = reanim_get_part_sprite("images/SelectorScreen_Store.png");
menu_spr_store_highlight = reanim_get_part_sprite("images/SelectorScreen_StoreHighlight.png");
menu_spr_zengarden = reanim_get_part_sprite("images/SelectorScreen_ZenGarden.png");
menu_spr_zengarden_highlight = reanim_get_part_sprite("images/SelectorScreen_ZenGardenHighlight.png");
// Original GameSelector::Draw / NewLawnButton images for the lower-right Options, Help, and Quit buttons.
menu_spr_options = reanim_get_part_sprite("images/SelectorScreen_Options1.png");
menu_spr_options_highlight = reanim_get_part_sprite("images/SelectorScreen_Options2.png");
menu_spr_help = reanim_get_part_sprite("images/SelectorScreen_Help1.png");
menu_spr_help_highlight = reanim_get_part_sprite("images/SelectorScreen_Help2.png");
menu_spr_quit = reanim_get_part_sprite("images/SelectorScreen_Quit1.png");
menu_spr_quit_highlight = reanim_get_part_sprite("images/SelectorScreen_Quit2.png");

// Native assets used by NewOptionsDialog, AwardScreen::AWARD_HELP_ZOMBIENOTE, and LawnApp::ConfirmQuit.
// The installer extracts these files from the supplied original PvZ asset archive into datafiles/parts/images.
menu_spr_options_bg = reanim_get_part_sprite("images/options_menuback.jpg");
menu_spr_options_back = reanim_get_part_sprite("images/options_backtogamebutton0.png");
menu_spr_options_back_down = reanim_get_part_sprite("images/options_backtogamebutton2.png");
menu_spr_options_check_off = reanim_get_part_sprite("images/options_checkbox0.png");
menu_spr_options_check_on = reanim_get_part_sprite("images/options_checkbox1.png");
menu_spr_options_slider = reanim_get_part_sprite("images/options_sliderslot.png");
menu_spr_options_knob = reanim_get_part_sprite("images/options_sliderknob2.png");
menu_spr_help_background = reanim_get_part_sprite("images/background1.png");
menu_spr_help_note = reanim_get_part_sprite("images/ZombieNote.jpg");
menu_spr_help_note_inner = reanim_get_part_sprite("images/ZombieNoteHelp_composited.png");
menu_spr_help_button = reanim_get_part_sprite("images/SeedChooser_Button.png");
menu_spr_help_button_glow = reanim_get_part_sprite("images/SeedChooser_Button_Glow.png");
menu_spr_dialog_header = reanim_get_part_sprite("images/dialog_header.png");
menu_spr_dialog_tl = reanim_get_part_sprite("images/dialog_topleft.png");
menu_spr_dialog_tm = reanim_get_part_sprite("images/dialog_topmiddle.png");
menu_spr_dialog_tr = reanim_get_part_sprite("images/dialog_topright.png");
menu_spr_dialog_ml = reanim_get_part_sprite("images/dialog_centerleft.png");
menu_spr_dialog_mm = reanim_get_part_sprite("images/dialog_centermiddle.png");
menu_spr_dialog_mr = reanim_get_part_sprite("images/dialog_centerright.png");
menu_spr_dialog_bl = reanim_get_part_sprite("images/dialog_bottomleft.png");
menu_spr_dialog_bm = reanim_get_part_sprite("images/dialog_bottommiddle.png");
menu_spr_dialog_br = reanim_get_part_sprite("images/dialog_bottomright.png");
menu_spr_dialog_button = pvz_lawn_load_sprite("button_small.png", 1);
menu_spr_dialog_button_down = pvz_lawn_load_sprite("button_down_small.png", 1);

// GameButton::DrawStoneButton images (from the original PvZ pvzfx asset set).
global.pvz_button_left = pvz_lawn_load_sprite("button_left.png", 1);
global.pvz_button_middle = pvz_lawn_load_sprite("button_middle.png", 1);
global.pvz_button_right = pvz_lawn_load_sprite("button_right.png", 1);
global.pvz_button_down_left = pvz_lawn_load_sprite("button_down_left.png", 1);
global.pvz_button_down_middle = pvz_lawn_load_sprite("button_down_middle.png", 1);
global.pvz_button_down_right = pvz_lawn_load_sprite("button_down_right.png", 1);
menu_modal = "";
if (!variable_global_exists("pvz_lawn_sfx_enabled")) global.pvz_lawn_sfx_enabled = true;
if (!variable_global_exists("pvz_lawn_music_enabled")) global.pvz_lawn_music_enabled = true;
if (!variable_global_exists("pvz_lawn_sfx_volume")) global.pvz_lawn_sfx_volume = global.pvz_lawn_sfx_enabled ? 1.0 : 0.0;
if (!variable_global_exists("pvz_lawn_music_volume")) global.pvz_lawn_music_volume = global.pvz_lawn_music_enabled ? 1.0 : 0.0;
if (!variable_global_exists("pvz_lawn_fullscreen_enabled")) global.pvz_lawn_fullscreen_enabled = window_get_fullscreen();
if (!variable_global_exists("pvz_lawn_accel_enabled")) global.pvz_lawn_accel_enabled = true;
if (!variable_global_exists("pvz_lawn_debug_mode")) global.pvz_lawn_debug_mode = false;
if (!variable_global_exists("pvz_lawn_discord_presence")) global.pvz_lawn_discord_presence = true;
if (!variable_global_exists("pvz_lawn_bank_keybinds")) global.pvz_lawn_bank_keybinds = false;
if (!variable_global_exists("pvz_lawn_zero_nine_format")) global.pvz_lawn_zero_nine_format = false;

// NewOptionsDialog::Resize positions controls relative to its original options background.
// Keep all modal hitboxes and draws on the same coordinates, just like the source widget.
menu_modal_layout = function() {
    var _bgw = menu_spr_options_bg >= 0 ? sprite_get_width(menu_spr_options_bg) : 423;
    var _bgh = menu_spr_options_bg >= 0 ? sprite_get_height(menu_spr_options_bg) : 498;
    var _ox = floor((room_width - _bgw) * 0.5);
    var _oy = floor((room_height - _bgh) * 0.5);
    return {
        ox: _ox, oy: _oy, bgw: _bgw, bgh: _bgh,
        music_x: _ox + 199, music_y: _oy + 121, music_w: 135, music_h: 40,
        sfx_x: _ox + 199, sfx_y: _oy + 153, sfx_w: 135, sfx_h: 40,
        accel_x: _ox + 284, accel_y: _oy + 190, check_w: 46, check_h: 39,
        fullscreen_x: _ox + 284, fullscreen_y: _oy + 226,
        almanac_x: _ox + 107, almanac_y: _oy + 241, button_w: 209, button_h: 46,
        advanced_x: _ox + 107, advanced_y: _oy + 327,
        ok_x: _ox + 30, ok_y: _oy + 381,
        help_button_x: 564, help_button_y: 560, help_button_w: 156, help_button_h: 42,
        quit_x: floor((room_width - 420) * 0.5), quit_y: floor((room_height - 220) * 0.5), quit_w: 420, quit_h: 220
    };
};

// Minimal persisted profile identity for the original "If this is not you" sign.
// The full PopCap user/save-slot dialog is outside this current lawn-test build.
profile_name = "Player";
profile_file_path = working_directory + "datafiles/pvz_menu_profile.txt";
if (file_exists(profile_file_path)) {
    var _profile_file = file_text_open_read(profile_file_path);
    if (!file_text_eof(_profile_file)) {
        var _profile_line = string_trim(file_text_readln(_profile_file));
        if (_profile_line != "") profile_name = string_copy(_profile_line, 1, 24);
    }
    file_text_close(_profile_file);
}
save_profile_name = function() {
    var _profile_file = file_text_open_write(profile_file_path);
    if (_profile_file >= 0) {
        file_text_write_string(_profile_file, profile_name);
        file_text_close(_profile_file);
    }
};
menu_hit_quad = function(_px, _py, _x, _y, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4) {
    // Same four-point polygon regions configured in GameSelector.cpp.
    return point_in_triangle(_px, _py, _x + _x1, _y + _y1, _x + _x2, _y + _y2, _x + _x3, _y + _y3)
        || point_in_triangle(_px, _py, _x + _x1, _y + _y1, _x + _x3, _y + _y3, _x + _x4, _y + _y4);
};
flower_reanim = [];
flower_centers = [[765, 483], [663, 455], [701, 439]];
cloud_reanim = [];
cloud_wait = [];
loadbar_effects = [];

// Real PvZ title/loading art. Install_PvZ_Sounds.bat also installs these five original images.
title_background = pvz_lawn_load_sprite("titlescreen.jpg", 1);
popcap_logo = pvz_lawn_load_sprite("PopCap_Logo.jpg", 1);
title_logo = pvz_lawn_load_sprite("PvZ_Logo_.png", 1);
loadbar_dirt = pvz_lawn_load_sprite("LoadBar_dirt.png", 1);
loadbar_grass = pvz_lawn_load_sprite("LoadBar_grass.png", 1);
loadbar_cap = reanim_get_part_sprite("reanim/SodRollCap.png");
loadbar_width = 314.0;
title_logo_y = -100;

// Create the selector only after the click-to-start phase, just as TitleScreen::LoadingCompleted
// transitions into the original GameSelector widget.
init_main_menu = function() {
    if (menu_initialized) return;
    menu_initialized = true;
    boot_state = "menu";
    boot_ticks = 0;
    menu_reanim = new Reanim("SelectorScreen", 0.5, 0.5);
    menu_reanim.play("anim_open", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 30.0);

    // GameSelector sets this reanimation's base pose to the final sign frame before attaching
    // flowers; use the original anim_sign range rather than attaching them to the opening pose.
    var _anims = reanim_anim_list(menu_reanim.def);
    for (var _ai = 0; _ai < array_length(_anims); _ai++) {
        if (string_lower(_anims[_ai].name) == "anim_sign") {
            menu_reanim.frame_base_pose = _anims[_ai].start + _anims[_ai].count - 1;
            break;
        }
    }
    // The source keeps these elements on separate effect reanimations to avoid double drawing.
    menu_reanim.set_tracks_hidden_by_prefix("flower", true);
    menu_reanim.set_tracks_hidden_by_prefix("leaf", true);
    menu_reanim.set_tracks_hidden_by_prefix("Cloud", true);
    var _bg_track = menu_reanim.find_track("SelectorScreen_BG");
    if (_bg_track >= 0) menu_reanim.track_render_group[_bg_track] = 1;

    // The original selector has six independent clouds, each using the relevant SelectorScreen animation.
    var _cloud_names = ["anim_cloud1", "anim_cloud2", "anim_cloud4", "anim_cloud5", "anim_cloud6", "anim_cloud7"];
    for (var _i = 0; _i < array_length(_cloud_names); _i++) {
        var _cr = new Reanim("SelectorScreen", 0.5, 0.5);
        _cr.play(_cloud_names[_i], ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 0.5);
        var _wait = irandom_range(-6000, 2000);
        if (_wait < 0) {
            _cr.anim_time = clamp(-_wait / 6000.0, 0, 0.999);
            _cr.anim_rate = 0.5;
            _wait = 0;
        } else {
            _cr.anim_rate = 0;
        }
        array_push(cloud_reanim, _cr);
        array_push(cloud_wait, _wait);
    }

    // Source has three attached, initially dormant flower animations that pop with limbs_pop.ogg on click.
    for (var _f = 1; _f <= 3; _f++) {
        var _fr = new Reanim("SelectorScreen", 0.5, 0.5);
        _fr.play("anim_flower" + string(_f), ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 0.0);
        _fr.anim_rate = 0.0;
        _fr.attach_to(menu_reanim, "SelectorScreen_BG_Right");
        array_push(flower_reanim, _fr);
    }

    leaf_reanim = new Reanim("SelectorScreen", 0.5, 0.5);
    leaf_reanim.play("anim_grass", ReanimLoop.LOOP, 0, 6.0);
    leaf_reanim.anim_rate = 0.0;
    leaf_ticks = 50;
    pvz_lawn_play_sound("roll_in.ogg"); // GameSelector constructor: SOUND_ROLL_IN.
};
