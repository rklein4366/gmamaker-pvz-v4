// Gameplay's Main Menu action uses GameSelector directly; skip PopCap/title/loading if flagged.
if (variable_global_exists("pvz_open_main_menu_direct") && global.pvz_open_main_menu_direct) {
    global.pvz_open_main_menu_direct = false;
    if (boot_state != "menu") init_main_menu();
}
/// Update title timers and all source Reanim animations on the original 100 Hz logic clock.
var _steps = logic_clock_steps();
repeat (_steps) {
    boot_ticks++;
    if (boot_state == "popcap") {
        if (boot_ticks >= 200) { boot_state = "title"; boot_ticks = 0; }
        continue;
    }
    if (boot_state == "title") {
        if (boot_ticks >= 100) { boot_state = "loading"; boot_ticks = 0; load_ticks = 0; }
        continue;
    }
    if (boot_state == "loading") {
        if (boot_ticks > 100) {
            load_ticks = min(load_ticks_total, load_ticks + 1);
            load_progress = load_ticks / load_ticks_total;
            var _triggers = [0.11, 0.32, 0.54, 0.72, 0.91];
            for (var _ti = 0; _ti < array_length(_triggers); _ti++) {
                var _threshold = _triggers[_ti] * loadbar_width;
                if (load_ticks == max(1, floor(_triggers[_ti] * load_ticks_total))) {
                    var _er = new Reanim(_ti == 4 ? "LoadBar_Zombiehead" : "LoadBar_sprout", 0, 0);
                    _er.play(_ti == 4 ? "anim_zombie" : "anim_sprout", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 18.0);
                    var _bx = floor((room_width - (loadbar_dirt >= 0 ? sprite_get_width(loadbar_dirt) : 354)) * 0.5);
                    var _ex = _bx + _threshold;
                    var _ey = 511;
                    var _sx = 1.0;
                    var _sy = 1.0;
                    if (_ti == 1 || _ti == 3) _sx = -1.0;
                    if (_ti == 2) { _sx = 1.1; _sy = 1.3; _ey -= 5; }
                    if (_ti == 4) _ex -= 20;
                    _er.scale_x = _sx; _er.scale_y = _sy;
                    _er.x = _ex; _er.y = _ey;
                    array_push(loadbar_effects, _er);
                    if (_ti == 4) {
                        pvz_lawn_play_sound("loadingbar_flower.ogg");
                        pvz_lawn_play_sound("loadingbar_zombie.ogg");
                    } else pvz_lawn_play_sound("loadingbar_flower.ogg");
                }
            }
        }
        for (var _ei = 0; _ei < array_length(loadbar_effects); _ei++) loadbar_effects[_ei].update();
        if (load_ticks >= load_ticks_total) boot_state = "click_to_start";
        continue;
    }
    if (boot_state == "click_to_start") {
        // TitleScreen::MouseDown permits a click anywhere once LoadingCompleted is true.
        if (mouse_check_button_pressed(mb_left)) {
            pvz_lawn_play_sound("buttonclick.ogg");
            init_main_menu();
        }
        continue;
    }
    if (boot_state == "menu") {
        menu_reanim.update();
        // Original GameSelector transitions from anim_open to the wooden-sign idle pose.
        if (menu_reanim.loop_count > 0 && !menu_sign_started) {
            menu_reanim.play("anim_sign", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 30.0);
            menu_sign_started = true;
        }
        // Show the custom button overlays as soon as anim_sign starts. Waiting for loop_count > 0
        // here left the whole menu without its interactive overlays for one full sign animation.
        var _menu_controls_visible = menu_sign_started && menu_reanim != undefined;
        var _menu_sign_done = _menu_controls_visible && menu_reanim.loop_count > 0;
        if (_menu_sign_done) menu_reanim.anim_rate = 0;
        if (_menu_controls_visible) {
            // GameSelector::Update hides only the button tracks, keeping the shadows/wooden art.
            // We draw their native button sprites separately while the sign itself finishes moving.
            menu_reanim.set_track_hidden("SelectorScreen_Adventure_button", true);
            menu_reanim.set_track_hidden("SelectorScreen_StartAdventure_button", true);
            menu_reanim.set_track_hidden("SelectorScreen_Survival_button", true);
            menu_reanim.set_track_hidden("SelectorScreen_Challenges_button", true);
            menu_reanim.set_track_hidden("SelectorScreen_ZenGarden_button", true);
        }

        for (var _ci = 0; _ci < array_length(cloud_reanim); _ci++) {
            var _cloud = cloud_reanim[_ci];
            if (cloud_wait[_ci] > 0) {
                cloud_wait[_ci]--;
                if (cloud_wait[_ci] == 0) { _cloud.loop_count = 0; _cloud.anim_time = 0; _cloud.anim_rate = 0.5; }
            } else {
                _cloud.update();
                if (_cloud.loop_count > 0) cloud_wait[_ci] = irandom_range(2000, 4000);
            }
        }
        leaf_reanim.update();
        var _leaf_track = menu_reanim.find_track("SelectorScreen_BG_Right");
        if (_leaf_track >= 0) {
            var _lf = menu_reanim.get_current_transform(_leaf_track);
            leaf_reanim.x = _lf[RT_X] - 71.0;
            leaf_reanim.y = _lf[RT_Y] - 41.0;
        }
        leaf_ticks--;
        if (leaf_ticks <= 0) { leaf_reanim.anim_rate = random_range(3.0, 12.0); leaf_ticks = irandom_range(200, 400); }

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

        if (_menu_controls_visible && menu_modal == "") {
            // Main button hit polygons and transforms follow GameSelector::TrackButton + constructor.
            var _start_idx = menu_reanim.find_track("SelectorScreen_StartAdventure_button");
            var _start_xf = menu_reanim.get_current_transform(_start_idx);
            var _start_x = menu_reanim.x + _start_xf[RT_X];
            var _start_y = menu_reanim.y + _start_xf[RT_Y];
            hover_start_adventure = menu_hit_quad(mouse_x, mouse_y, _start_x, _start_y,
                7, 1, 328, 30, 314, 125, 1, 78);

            var _mini_idx = menu_reanim.find_track("SelectorScreen_Survival_button");
            var _mini_xf = menu_reanim.get_current_transform(_mini_idx);
            var _mini_x = menu_reanim.x + _mini_xf[RT_X];
            var _mini_y = menu_reanim.y + _mini_xf[RT_Y];
            hover_minigame = menu_hit_quad(mouse_x, mouse_y, _mini_x, _mini_y,
                4, 2, 312, 51, 296, 130, 7, 77);

            var _puzzle_idx = menu_reanim.find_track("SelectorScreen_Challenges_button");
            var _puzzle_xf = menu_reanim.get_current_transform(_puzzle_idx);
            var _puzzle_x = menu_reanim.x + _puzzle_xf[RT_X];
            var _puzzle_y = menu_reanim.y + _puzzle_xf[RT_Y];
            hover_puzzle = menu_hit_quad(mouse_x, mouse_y, _puzzle_x, _puzzle_y,
                2, 0, 281, 55, 268, 121, 3, 60);

            var _vase_idx = menu_reanim.find_track("SelectorScreen_ZenGarden_button");
            var _vase_xf = menu_reanim.get_current_transform(_vase_idx);
            var _vase_x = menu_reanim.x + _vase_xf[RT_X];
            var _vase_y = menu_reanim.y + _vase_xf[RT_Y];
            hover_vasebreaker = menu_hit_quad(mouse_x, mouse_y, _vase_x, _vase_y,
                7, 1, 267, 62, 257, 124, 7, 57);

            // The original three pot buttons are tracked relative to SelectorScreen_BG_Right.
            var _pot_bg_idx = menu_reanim.find_track("SelectorScreen_BG_Right");
            var _pot_bg_xf = menu_reanim.get_current_transform(_pot_bg_idx);
            var _pot_bg_x = menu_reanim.x + _pot_bg_xf[RT_X];
            var _pot_bg_y = menu_reanim.y + _pot_bg_xf[RT_Y];
            var _almanac_x = _pot_bg_x + 256 + 111;
            var _almanac_y = _pot_bg_y + 387 + 80;
            var _store_x = _pot_bg_x + 334 + 111;
            var _store_y = _pot_bg_y + 441 + 80;
            var _zen_x = _pot_bg_x + 100 + 111;
            var _zen_y = _pot_bg_y + 360 + 80;

            if (menu_spr_almanac >= 0) {
                hover_almanac = point_in_rectangle(mouse_x, mouse_y, _almanac_x, _almanac_y,
                    _almanac_x + sprite_get_width(menu_spr_almanac), _almanac_y + sprite_get_height(menu_spr_almanac));
            }
            if (menu_spr_store >= 0) {
                hover_store = point_in_rectangle(mouse_x, mouse_y, _store_x, _store_y,
                    _store_x + sprite_get_width(menu_spr_store), _store_y + sprite_get_height(menu_spr_store));
            }
            // Original GameSelector constructor explicitly resizes ZenGardenButton to 130x130.
            if (menu_spr_zengarden >= 0) {
                hover_zengarden = point_in_rectangle(mouse_x, mouse_y, _zen_x, _zen_y, _zen_x + 130, _zen_y + 130);
            }

            // Exact TrackButton positions and resized hit areas from GameSelector.cpp.
            var _options_x = _pot_bg_x + 494 + 111;
            var _options_y = _pot_bg_y + 434 + 80;
            var _help_x = _pot_bg_x + 576 + 111;
            var _help_y = _pot_bg_y + 458 + 80;
            var _quit_x = _pot_bg_x + 644 + 111;
            var _quit_y = _pot_bg_y + 469 + 80;
            if (menu_spr_options >= 0) hover_options = point_in_rectangle(mouse_x, mouse_y,
                _options_x, _options_y, _options_x + sprite_get_width(menu_spr_options), _options_y + sprite_get_height(menu_spr_options) + 23);
            if (menu_spr_help >= 0) hover_help = point_in_rectangle(mouse_x, mouse_y,
                _help_x, _help_y, _help_x + sprite_get_width(menu_spr_help), _help_y + sprite_get_height(menu_spr_help) + 33);
            if (menu_spr_quit >= 0) hover_quit = point_in_rectangle(mouse_x, mouse_y,
                _quit_x, _quit_y, _quit_x + sprite_get_width(menu_spr_quit) + 10, _quit_y + sprite_get_height(menu_spr_quit) + 10);

            // GameSelector::TrackButton(mChangeUserButton, "woodsign2", 24, 10), size 250x30.
            var _user_idx = menu_reanim.find_track("woodsign2");
            var _user_xf = menu_reanim.get_current_transform(_user_idx);
            var _user_x = menu_reanim.x + _user_xf[RT_X] + 24;
            var _user_y = menu_reanim.y + _user_xf[RT_Y] + 10;
            hover_change_user = point_in_rectangle(mouse_x, mouse_y, _user_x, _user_y, _user_x + 250, _user_y + 30);
            if (_user_idx >= 0 && menu_spr_change_user_pressed >= 0) {
                menu_reanim.track_sprite_override[_user_idx] = (hover_change_user || (mouse_check_button(mb_left) && hover_change_user))
                    ? menu_spr_change_user_pressed : -1;
            }
        } else {
            var _user_idx_reset = menu_reanim.find_track("woodsign2");
            if (_user_idx_reset >= 0) menu_reanim.track_sprite_override[_user_idx_reset] = -1;
        }

        // Original GameSelector::ButtonMouseEnter emits BLEEP only for the usable Adventure and pot buttons.
        if (hover_start_adventure && !hover_start_prev) pvz_lawn_play_sound("bleep.ogg");
        if ((hover_almanac && !hover_almanac_prev) || (hover_store && !hover_store_prev) ||
            (hover_zengarden && !hover_zengarden_prev) || (hover_change_user && !hover_change_user_prev) ||
            (hover_options && !hover_options_prev) || (hover_help && !hover_help_prev) || (hover_quit && !hover_quit_prev)) {
            pvz_lawn_play_sound("bleep.ogg");
        }
        hover_start_prev = hover_start_adventure;
        hover_almanac_prev = hover_almanac;
        hover_store_prev = hover_store;
        hover_zengarden_prev = hover_zengarden;
        hover_change_user_prev = hover_change_user;
        hover_options_prev = hover_options;
        hover_help_prev = hover_help;
        hover_quit_prev = hover_quit;

        // Native Slider::Update supports dragging continuously; mirror that behavior while a slider is held.
        if (menu_modal == "options" && mouse_check_button(mb_left)) {
            var _ol = menu_modal_layout();
            if (point_in_rectangle(mouse_x, mouse_y, _ol.music_x, _ol.music_y, _ol.music_x + _ol.music_w, _ol.music_y + _ol.music_h)) {
                global.pvz_lawn_music_volume = clamp((mouse_x - (_ol.music_x + 8)) / max(1, _ol.music_w - 16), 0, 1);
                global.pvz_lawn_music_enabled = global.pvz_lawn_music_volume > 0.001;
            } else if (point_in_rectangle(mouse_x, mouse_y, _ol.sfx_x, _ol.sfx_y, _ol.sfx_x + _ol.sfx_w, _ol.sfx_y + _ol.sfx_h)) {
                global.pvz_lawn_sfx_volume = clamp((mouse_x - (_ol.sfx_x + 8)) / max(1, _ol.sfx_w - 16), 0, 1);
                global.pvz_lawn_sfx_enabled = global.pvz_lawn_sfx_volume > 0.001;
            }
        }

        if (mouse_check_button_pressed(mb_left)) {
            // Original GameSelector::MouseDown pops the three flowers before button callbacks.
            var _flower_hit = false;
            if (menu_modal == "") {
                for (var _fi = 0; _fi < array_length(flower_reanim); _fi++) {
                    if (flower_reanim[_fi].anim_rate <= 0 && point_distance(mouse_x, mouse_y, flower_centers[_fi][0], flower_centers[_fi][1]) < 20) {
                        flower_reanim[_fi].anim_rate = 24.0;
                        pvz_lawn_play_sound("limbs_pop.ogg");
                        _flower_hit = true;
                        break;
                    }
                }
            }
            if (menu_modal != "") {
                // Source equivalents: NewOptionsDialog controls, AwardScreen::AWARD_HELP_ZOMBIENOTE,
                // and LawnApp::ConfirmQuit. The visuals and widget geometry use the original art below.
                var _ml = menu_modal_layout();
                if (menu_modal == "options") {
                    if (point_in_rectangle(mouse_x, mouse_y, _ml.ok_x, _ml.ok_y,
                        _ml.ok_x + max(1, (menu_spr_options_back >= 0 ? sprite_get_width(menu_spr_options_back) : 360)),
                        _ml.ok_y + max(1, (menu_spr_options_back >= 0 ? sprite_get_height(menu_spr_options_back) : 100)))) {
                        pvz_lawn_play_sound("buttonclick.ogg");
                        menu_modal = "";
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.almanac_x, _ml.almanac_y,
                        _ml.almanac_x + _ml.button_w, _ml.almanac_y + _ml.button_h)) {
                        pvz_lawn_play_sound("gravebutton.ogg");
                        show_message("The Almanac screen is not part of this lawn-test build yet.");
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.advanced_x, _ml.advanced_y,
                        _ml.advanced_x + _ml.button_w, _ml.advanced_y + _ml.button_h)) {
                        pvz_lawn_play_sound("gravebutton.ogg");
                        menu_modal = "options_advanced";
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.accel_x, _ml.accel_y,
                        _ml.accel_x + _ml.check_w, _ml.accel_y + _ml.check_h)) {
                        pvz_lawn_play_sound("tap.ogg");
                        global.pvz_lawn_accel_enabled = !global.pvz_lawn_accel_enabled;
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.fullscreen_x, _ml.fullscreen_y,
                        _ml.fullscreen_x + _ml.check_w, _ml.fullscreen_y + _ml.check_h)) {
                        pvz_lawn_play_sound("tap.ogg");
                        global.pvz_lawn_fullscreen_enabled = !global.pvz_lawn_fullscreen_enabled;
                        window_set_fullscreen(global.pvz_lawn_fullscreen_enabled);
                    }
                } else if (menu_modal == "options_advanced") {
                    if (point_in_rectangle(mouse_x, mouse_y, _ml.ok_x, _ml.ok_y,
                        _ml.ok_x + max(1, (menu_spr_options_back >= 0 ? sprite_get_width(menu_spr_options_back) : 360)),
                        _ml.ok_y + max(1, (menu_spr_options_back >= 0 ? sprite_get_height(menu_spr_options_back) : 100)))) {
                        pvz_lawn_play_sound("buttonclick.ogg");
                        menu_modal = "options";
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.ox + 284, _ml.oy + 148, _ml.ox + 330, _ml.oy + 187)) {
                        pvz_lawn_play_sound("tap.ogg"); global.pvz_lawn_debug_mode = !global.pvz_lawn_debug_mode;
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.ox + 284, _ml.oy + 188, _ml.ox + 330, _ml.oy + 227)) {
                        pvz_lawn_play_sound("tap.ogg"); global.pvz_lawn_discord_presence = !global.pvz_lawn_discord_presence;
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.ox + 284, _ml.oy + 228, _ml.ox + 330, _ml.oy + 267)) {
                        pvz_lawn_play_sound("tap.ogg"); global.pvz_lawn_bank_keybinds = !global.pvz_lawn_bank_keybinds;
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.ox + 284, _ml.oy + 268, _ml.ox + 330, _ml.oy + 307)) {
                        pvz_lawn_play_sound("tap.ogg"); global.pvz_lawn_zero_nine_format = !global.pvz_lawn_zero_nine_format;
                    }
                } else if (menu_modal == "help") {
                    var _hb = _ml.help_button_x; var _hby = _ml.help_button_y;
                    if (point_in_rectangle(mouse_x, mouse_y, _hb, _hby, _hb + _ml.help_button_w, _hby + _ml.help_button_h)) {
                        pvz_lawn_play_sound("tap.ogg");
                        menu_modal = "";
                    }
                } else if (menu_modal == "quit") {
                    var _qy = _ml.quit_y + 157;
                    if (point_in_rectangle(mouse_x, mouse_y, _ml.quit_x + 42, _qy, _ml.quit_x + 174, _qy + 42)) {
                        pvz_lawn_play_sound("tap.ogg");
                        game_end();
                    } else if (point_in_rectangle(mouse_x, mouse_y, _ml.quit_x + 246, _qy, _ml.quit_x + 378, _qy + 42)) {
                        pvz_lawn_play_sound("tap.ogg");
                        menu_modal = "";
                    }
                }
            } else if (!_flower_hit && _menu_controls_visible) {
                if (hover_start_adventure) {
                    // GameSelector::ClickedAdventure: hand reanimation uses its native 30fps rate.
                    pvz_lawn_play_sound("gravebutton.ogg");
                    pvz_lawn_play_sound("losemusic.ogg");
                    boot_state = "starting_adventure";
                    start_transition_ticks = 0;
                    hand_reanim = new Reanim("Zombie_hand", 170.0, 70.0);
                    hand_reanim.play_all(ReanimLoop.PLAY_ONCE_AND_HOLD);
                    hand_reanim.anim_rate = 30.0;
                    pvz_lawn_play_sound("dirt_rise.ogg");
                } else if (hover_minigame) {
                    pvz_lawn_play_sound("gravebutton.ogg");
                    show_message("Mini-games are locked. Complete more Adventure levels to unlock this mode.");
                } else if (hover_puzzle) {
                    pvz_lawn_play_sound("gravebutton.ogg");
                    show_message("Puzzle mode is locked. Complete more Adventure levels to unlock this mode.");
                } else if (hover_vasebreaker) {
                    pvz_lawn_play_sound("gravebutton.ogg");
                    show_message("Vasebreaker is locked. Complete more Adventure levels to unlock this mode.");
                } else if (hover_almanac) {
                    pvz_lawn_play_sound("tap.ogg");
                    show_message("The Almanac screen is not implemented in this GameMaker lawn-test build yet.");
                } else if (hover_store) {
                    pvz_lawn_play_sound("tap.ogg");
                    show_message("The Shop screen is not implemented in this GameMaker lawn-test build yet.");
                } else if (hover_zengarden) {
                    pvz_lawn_play_sound("tap.ogg");
                    show_message("The Zen Garden screen is not implemented in this GameMaker lawn-test build yet.");
                } else if (hover_options) {
                    pvz_lawn_play_sound("tap.ogg");
                    menu_modal = "options";
                } else if (hover_help) {
                    pvz_lawn_play_sound("tap.ogg");
                    menu_modal = "help";
                } else if (hover_quit) {
                    pvz_lawn_play_sound("tap.ogg");
                    menu_modal = "quit";
                } else if (hover_change_user) {
                    // The original ButtonDepress calls LawnApp::DoUserDialog. This build has no save-slot UI,
                    // so let the player change the welcome-sign identity and persist it for the next launch.
                    pvz_lawn_play_sound("tap.ogg");
                    var _new_profile_name = string_trim(get_string("Enter the player name to show on the welcome sign:", profile_name));
                    if (_new_profile_name != "") {
                        profile_name = string_copy(_new_profile_name, 1, 24);
                        save_profile_name();
                    }
                }
            }
        }
        continue;
    }
    if (boot_state == "starting_adventure") {
        start_transition_ticks++;
        if (is_struct(hand_reanim)) hand_reanim.update();

        // GameSelector.cpp: GameSelector::Update plays EVILLAUGH at counter 125.
        if (start_transition_ticks == 125) pvz_lawn_play_sound("evillaugh.ogg");

        // The original selector waits until its counter passes 450 before entering Adventure.
        if (start_transition_ticks > 450) {
            boot_state = "leaving_room";
            room_goto(rm_pvz_lawn_game);
        }
    }
}
