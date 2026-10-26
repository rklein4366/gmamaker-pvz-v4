// The original options dialog freezes gameplay. Escape does not interrupt the defeat cutscene.
if (keyboard_check_pressed(vk_escape) && global.pvz_lawn_lost_state == "" && !global.pvz_lawn_seed_chooser_entered) {
    if (global.pvz_lawn_menu_open) {
        global.pvz_lawn_menu_open = false;
        logic_clock_init();
    } else {
        global.pvz_lawn_menu_open = true;
        global.pvz_lawn_selected = "";
        global.pvz_lawn_shovel_selected = false;
    }
}
var _clock_steps = logic_clock_steps();
// Intro-preview zombie reanimations still advance while the seed chooser pauses gameplay.
global.pvz_lawn_visual_steps = _clock_steps;
// CutScene::Update stops its timeline and board updates while SeedChooserScreen has focus.
var _chooser_pause = variable_global_exists("pvz_lawn_seed_chooser_active") && global.pvz_lawn_seed_chooser_active;
var _controller_steps = (global.pvz_lawn_menu_open || global.pvz_lawn_lost_state == "gameover" || _chooser_pause) ? 0 : _clock_steps;
global.pvz_lawn_steps = (global.pvz_lawn_menu_open || global.pvz_lawn_lost_state != "" || _chooser_pause) ? 0 : _clock_steps;
global.pvz_lawn_tick += global.pvz_lawn_steps;
if (global.pvz_lawn_environment_index == 2 || global.pvz_lawn_environment_index == 3) global.pvz_lawn_pool_counter += global.pvz_lawn_steps;
for (var _ice_tick_row = 0; _ice_tick_row < array_length(global.pvz_lawn_ice_timer); _ice_tick_row++) {
    if (global.pvz_lawn_ice_timer[_ice_tick_row] > 0) global.pvz_lawn_ice_timer[_ice_tick_row] = max(0, global.pvz_lawn_ice_timer[_ice_tick_row] - global.pvz_lawn_steps);
}
if (global.pvz_lawn_message_ticks > 0) global.pvz_lawn_message_ticks -= global.pvz_lawn_steps;

if (global.pvz_lawn_lost_state == "gameover") {
    global.pvz_lawn_steps = 0;
    var _gx = global.pvz_lawn_gameover_x;
    var _gy = global.pvz_lawn_gameover_y;
    if (mouse_check_button_pressed(mb_left)) {
        // The native LawnDialog can be dragged by its header.
        if (point_in_rectangle(mouse_x, mouse_y, _gx, _gy, _gx + 430, _gy + 96)) {
            global.pvz_lawn_gameover_dragging = true;
            global.pvz_lawn_gameover_drag_dx = mouse_x - _gx;
            global.pvz_lawn_gameover_drag_dy = mouse_y - _gy;
        } else if (point_in_rectangle(mouse_x, mouse_y, _gx + 42, _gy + 230, _gx + 207, _gy + 276)) {
            room_restart();
        } else if (point_in_rectangle(mouse_x, mouse_y, _gx + 225, _gy + 230, _gx + 390, _gy + 276)) {
            pvz_lawn_return_to_menu();
        }
    }
    if (global.pvz_lawn_gameover_dragging && mouse_check_button(mb_left)) {
        global.pvz_lawn_gameover_x = clamp(mouse_x - global.pvz_lawn_gameover_drag_dx, 0, room_width - 430);
        global.pvz_lawn_gameover_y = clamp(mouse_y - global.pvz_lawn_gameover_drag_dy, 0, room_height - 300);
    }
    if (!mouse_check_button(mb_left)) global.pvz_lawn_gameover_dragging = false;
    exit;
}

if (global.pvz_lawn_menu_open) {
    var _opt_bg = global.pvz_lawn_options_bg_sprite;
    var _opt_w = _opt_bg >= 0 ? sprite_get_width(_opt_bg) : 423;
    var _opt_h = _opt_bg >= 0 ? sprite_get_height(_opt_bg) : 498;
    var _ox = floor((room_width - _opt_w) * 0.5);
    var _oy = floor((room_height - _opt_h) * 0.5);
    var _back_w = global.pvz_lawn_options_back_sprite >= 0 ? sprite_get_width(global.pvz_lawn_options_back_sprite) : 360;
    var _back_h = global.pvz_lawn_options_back_sprite >= 0 ? sprite_get_height(global.pvz_lawn_options_back_sprite) : 100;
    // Slider::Update supports continuously dragging Music and Sound volume.
    if (mouse_check_button(mb_left)) {
        if (point_in_rectangle(mouse_x, mouse_y, _ox + 199, _oy + 116, _ox + 334, _oy + 156)) {
            global.pvz_lawn_music_volume = clamp((mouse_x - (_ox + 207)) / 119, 0, 1);
            global.pvz_lawn_music_enabled = global.pvz_lawn_music_volume > 0.001;
        } else if (point_in_rectangle(mouse_x, mouse_y, _ox + 199, _oy + 148, _ox + 334, _oy + 188)) {
            global.pvz_lawn_sfx_volume = clamp((mouse_x - (_ox + 207)) / 119, 0, 1);
            global.pvz_lawn_sfx_enabled = global.pvz_lawn_sfx_volume > 0.001;
        }
    }
    if (mouse_check_button_pressed(mb_left)) {
        if (point_in_rectangle(mouse_x, mouse_y, _ox + 30, _oy + 381, _ox + 30 + _back_w, _oy + 381 + _back_h)) {
            global.pvz_lawn_menu_open = false;
            logic_clock_init();
        } else if (point_in_rectangle(mouse_x, mouse_y, _ox + 284, _oy + 190, _ox + 330, _oy + 229)) {
            global.pvz_lawn_accel_enabled = !global.pvz_lawn_accel_enabled;
        } else if (point_in_rectangle(mouse_x, mouse_y, _ox + 284, _oy + 226, _ox + 330, _oy + 265)) {
            global.pvz_lawn_fullscreen_enabled = !global.pvz_lawn_fullscreen_enabled;
            window_set_fullscreen(global.pvz_lawn_fullscreen_enabled);
        } else if (point_in_rectangle(mouse_x, mouse_y, _ox + 107, _oy + 241, _ox + 316, _oy + 287)) {
            // This Stage0 build has no full Almanac room; the Reanimation Viewer is its available plant/zombie reference screen.
            var _viewer_room = asset_get_index("rm_reanim_viewer");
            if (_viewer_room >= 0) room_goto(_viewer_room);
        } else if (point_in_rectangle(mouse_x, mouse_y, _ox + 107, _oy + 284, _ox + 316, _oy + 330)) {
            room_restart();
        } else if (point_in_rectangle(mouse_x, mouse_y, _ox + 107, _oy + 327, _ox + 316, _oy + 373)) {
            pvz_lawn_return_to_menu();
        }
    }
    exit;
}
// Board::mMenuButton / SeedChooserScreen::mMenuButton: keep the source button clickable at its animated y.
var _menu_hit_y = -10;
if (global.pvz_lawn_seed_chooser_entered) {
    if (global.pvz_lawn_seed_chooser_completed) {
        var _menu_exit_hit_t = clamp((global.pvz_lawn_camera_pan_tick - PVZ_SEED_CHOOSER_SLIDE_OFF_START)
            / (PVZ_SEED_CHOOSER_SLIDE_OFF_END - PVZ_SEED_CHOOSER_SLIDE_OFF_START), 0, 1);
        _menu_hit_y = lerp(-10, -50, _menu_exit_hit_t);
    } else {
        var _menu_enter_hit_t = clamp((global.pvz_lawn_camera_pan_tick - PVZ_SEED_CHOOSER_SLIDE_ON_START)
            / (PVZ_SEED_CHOOSER_SLIDE_ON_END - PVZ_SEED_CHOOSER_SLIDE_ON_START), 0, 1);
        _menu_hit_y = lerp(-50, -10, _menu_enter_hit_t);
    }
}
if (mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, 681, _menu_hit_y, 798, _menu_hit_y + 46)) {
    global.pvz_lawn_menu_open = true;
    global.pvz_lawn_selected = "";
    global.pvz_lawn_shovel_selected = false;
    global.pvz_lawn_steps = 0;
    exit;
}
// Right click clears a carried packet/tool, like Board::ClearCursor.
if (mouse_check_button_pressed(mb_right)) {
    global.pvz_lawn_selected = "";
    global.pvz_lawn_shovel_selected = false;
}

// Board::UpdateSunSpawning at the 100 Hz source logic clock.
repeat (_controller_steps) {
    if (global.pvz_lawn_lost_state != "") {
        if (global.pvz_lawn_lost_state == "gameover") break;
        global.pvz_lawn_lost_tick++;
        var _lost_t = global.pvz_lawn_lost_tick;
        pvz_lawn_zombie_step_house_winner(global.pvz_lawn_lost_winner, 1);
        // CutScene.cpp: LostTimePanRightStart=1500ms, End=3500ms. Board.Move shifts the lawn right.
        if (_lost_t > 150 && _lost_t <= 350) {
            var _loss_pan = clamp((_lost_t - 150.0) / 200.0, 0, 1);
            _loss_pan = _loss_pan * _loss_pan * (3 - 2 * _loss_pan);
            global.pvz_lawn_camera_x = -220.0 * _loss_pan;
        } else if (_lost_t > 350) global.pvz_lawn_camera_x = -220.0;

        // CutScene.cpp loads REANIM_ZOMBIES_WON at LostTimeBrainGraphicStart=6000ms and plays at 12fps.
        if (_lost_t >= 600 && is_undefined(global.pvz_lawn_lost_reanim)) {
            global.pvz_lawn_lost_reanim = new Reanim("ZombiesWon", 20, 60);
            global.pvz_lawn_lost_reanim.play("ZombiesWon", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 12.0);
            pvz_lawn_play_sound("scream.ogg");
        }
        if (!is_undefined(global.pvz_lawn_lost_reanim) && _lost_t < 1100) {
            global.pvz_lawn_lost_reanim.update();
        }
        // CutScene.cpp plays two CHOMP Foleys 900ms and 400ms before the brain graphic.
        if (_lost_t == 510 || _lost_t == 560) pvz_lawn_play_sound("chomp.ogg");
        if (_lost_t >= 1100 && global.pvz_lawn_lost_state != "gameover") {
            global.pvz_lawn_lost_state = "gameover";
            if (!is_undefined(global.pvz_lawn_lost_reanim)) {
                global.pvz_lawn_lost_reanim.set_frames_for_layer("anim_screen");
                global.pvz_lawn_lost_reanim.anim_rate = 12.0;
                global.pvz_lawn_lost_reanim.loop_type = ReanimLoop.PLAY_ONCE_AND_HOLD;
            }
        }
        continue;
    }

    if (global.pvz_lawn_camera_pan_tick < PVZ_CAMERA_PAN_LEFT_END && !global.pvz_lawn_seed_chooser_active) {
        global.pvz_lawn_camera_pan_tick++;
        var _pan_t = 0.0;
        if (global.pvz_lawn_camera_pan_tick < PVZ_CAMERA_PAN_RIGHT_START) {
            global.pvz_lawn_camera_x = -PVZ_BOARD_OFFSET_X;
        } else if (global.pvz_lawn_camera_pan_tick <= PVZ_CAMERA_PAN_RIGHT_END) {
            _pan_t = (global.pvz_lawn_camera_pan_tick - PVZ_CAMERA_PAN_RIGHT_START) / (PVZ_CAMERA_PAN_RIGHT_END - PVZ_CAMERA_PAN_RIGHT_START);
            _pan_t = _pan_t * _pan_t * (3 - 2 * _pan_t); // TodAnimateCurve(CURVE_EASE_IN_OUT).
            global.pvz_lawn_camera_x = lerp(-PVZ_BOARD_OFFSET_X, PVZ_CAMERA_STREET_OFFSET, _pan_t);
        } else if (global.pvz_lawn_camera_pan_tick < PVZ_CAMERA_PAN_LEFT_START) {
            global.pvz_lawn_camera_x = PVZ_CAMERA_STREET_OFFSET;
        } else {
            _pan_t = (global.pvz_lawn_camera_pan_tick - PVZ_CAMERA_PAN_LEFT_START) / (PVZ_CAMERA_PAN_LEFT_END - PVZ_CAMERA_PAN_LEFT_START);
            _pan_t = _pan_t * _pan_t * (3 - 2 * _pan_t);
            global.pvz_lawn_camera_x = lerp(PVZ_CAMERA_STREET_OFFSET, 0, _pan_t);
        }
    } else if (!global.pvz_lawn_seed_chooser_active) {
        // Do not reset the camera when the chooser pauses the timeline; this was the source of the jump.
        global.pvz_lawn_camera_x = 0;
    }

    // Exact CutScene.cpp chooser timing: slide from y=720 to y=0 over ticks 400..425,
    // stop cutscene time at 425 until Let's Rock, then slide away over ticks 450..475.
    if (!global.pvz_lawn_seed_chooser_completed) {
        if (global.pvz_lawn_camera_pan_tick >= PVZ_SEED_CHOOSER_SLIDE_ON_START) {
            global.pvz_lawn_seed_chooser_entered = true;
            var _chooser_in_t = clamp((global.pvz_lawn_camera_pan_tick - PVZ_SEED_CHOOSER_SLIDE_ON_START)
                / (PVZ_SEED_CHOOSER_SLIDE_ON_END - PVZ_SEED_CHOOSER_SLIDE_ON_START), 0, 1);
            global.pvz_lawn_seed_chooser_panel_y = lerp(720, 0, _chooser_in_t);
        }
        if (global.pvz_lawn_camera_pan_tick >= PVZ_SEED_CHOOSER_SLIDE_ON_END) {
            global.pvz_lawn_seed_chooser_panel_y = 0;
            global.pvz_lawn_seed_chooser_active = true;
            // CutScene::Update stops immediately when it enters modal seed selection.
            break;
        }
    } else if (global.pvz_lawn_seed_chooser_entered) {
        if (global.pvz_lawn_camera_pan_tick < PVZ_SEED_CHOOSER_SLIDE_OFF_START) {
            global.pvz_lawn_seed_chooser_panel_y = 0;
        } else {
            var _chooser_out_t = clamp((global.pvz_lawn_camera_pan_tick - PVZ_SEED_CHOOSER_SLIDE_OFF_START)
                / (PVZ_SEED_CHOOSER_SLIDE_OFF_END - PVZ_SEED_CHOOSER_SLIDE_OFF_START), 0, 1);
            global.pvz_lawn_seed_chooser_panel_y = lerp(0, 720, _chooser_out_t);
            if (global.pvz_lawn_camera_pan_tick >= PVZ_SEED_CHOOSER_SLIDE_OFF_END) {
                global.pvz_lawn_seed_chooser_entered = false;
                global.pvz_lawn_seed_chooser_panel_y = 720;
            }
        }
    }

    // CutScene.cpp: AddReanimation(REANIM_READYSETPLANT) at 6000ms and keep it for 183 ticks.
    if (global.pvz_lawn_camera_pan_tick >= PVZ_READY_SET_PLANT_START) {
        if (global.pvz_lawn_ready_set_plant_ticks < 0) {
            global.pvz_lawn_ready_set_plant_ticks = 0;
            global.pvz_lawn_ready_set_plant_reanim.play_all(ReanimLoop.PLAY_ONCE_FULL_LAST_FRAME_AND_HOLD);
            global.pvz_lawn_ready_set_plant_reanim.dead = false;
            pvz_lawn_play_sound("readysetplant.ogg");
        } else if (global.pvz_lawn_ready_set_plant_ticks < PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START) {
            global.pvz_lawn_ready_set_plant_reanim.update();
            global.pvz_lawn_ready_set_plant_ticks++;
        }
        if (global.pvz_lawn_ready_set_plant_ticks >= PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START) {
            global.pvz_lawn_ready_set_plant_reanim.dead = true;
        }
    }

    // Board::UpdateZombieSpawning + GameConstants.h. The actual gameplay countdown begins
    // after the source intro pans back to the lawn; Level 1 has four waves and produces 1,1,1,2 basics.
    if (global.pvz_lawn_camera_pan_tick >= PVZ_CAMERA_PAN_LEFT_END && global.pvz_lawn_spawn_wave < global.pvz_lawn_spawn_wave_count) {
        global.pvz_lawn_spawn_countdown--;
        if (global.pvz_lawn_spawn_countdown <= 0) {
            var _source_wave = global.pvz_lawn_spawn_wave;
            var _source_zombie_count = floor(_source_wave / 3) + 1;
            repeat (_source_zombie_count) {
                // With no mowers yet, the source row weights are equal across five rows.
                var _wave_row = irandom(pvz_lawn_active_rows() - 1);
                instance_create_layer(780 + irandom(39), pvz_lawn_row_y(_wave_row, 780, -30), "Instances", obj_zombie_basic, {row: _wave_row});
            }
            global.pvz_lawn_spawn_wave++;
            if (global.pvz_lawn_spawn_wave < global.pvz_lawn_spawn_wave_count) {
                global.pvz_lawn_spawn_countdown = 2500 + irandom(599); // 2500 + Rand(600).
            }
        }
    }

    // Board::UpdateSunSpawning exits on night stages: there is no free sky-falling sun at night.
    // Keep the starting countdown frozen so switching back to day reuses the remaining wait.
    var _night_lawn = (global.pvz_lawn_environment_index == 1 || global.pvz_lawn_environment_index == 3);
    if (!_night_lawn && global.pvz_lawn_ready_set_plant_ticks >= PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START) {
        global.pvz_lawn_sun_countdown--;
        if (global.pvz_lawn_sun_countdown <= 0) {
            global.pvz_lawn_suns_fallen++;
            global.pvz_lawn_sun_countdown = min(950, 425 + global.pvz_lawn_suns_fallen * 10) + irandom(274);
            instance_create_layer(irandom_range(100, 649), -100, "Instances", obj_pvz_sun_pickup, {sun_motion: "sky"});
        }
    }
    // SeedPacket::CanPickUp + FlashIfReady for every selected seed type.
    for (var _packet_tick_i = 0; _packet_tick_i < array_length(global.pvz_lawn_seed_kinds); _packet_tick_i++) {
        if (global.pvz_lawn_seed_packet_flash[_packet_tick_i] > 0) global.pvz_lawn_seed_packet_flash[_packet_tick_i]--;
        if (global.pvz_lawn_seed_packet_refresh[_packet_tick_i] > 0) global.pvz_lawn_seed_packet_refresh[_packet_tick_i]--;
        var _packet_now_ready = global.pvz_lawn_seed_packet_refresh[_packet_tick_i] <= 0 && global.pvz_lawn_sun >= global.pvz_lawn_seed_costs[_packet_tick_i];
        if (_packet_now_ready && !global.pvz_lawn_seed_packet_ready_state[_packet_tick_i]) global.pvz_lawn_seed_packet_flash[_packet_tick_i] = 25;
        global.pvz_lawn_seed_packet_ready_state[_packet_tick_i] = _packet_now_ready;
    }
    // Packet reanimations intentionally do not update; only planted plants animate.
}

// The original SCENE_ZOMBIES_WON stops board interaction while the camera pan/brain scene plays.
if (global.pvz_lawn_lost_state != "") exit;

// SeedChooserScreen::SeedHitTest / ClickedSeedInChooser / ClickedSeedInBank / OnStartButton.
// This modal takes input only after the panel has fully slid in and holds the cutscene at tick 425.
if (global.pvz_lawn_seed_chooser_entered) {
    global.pvz_lawn_seed_chooser_frame++;
    var _chooser_motion_active = false;
    for (var _motion_i = 0; _motion_i < array_length(global.pvz_lawn_seed_chooser_flights); _motion_i++) {
        var _motion_flight = global.pvz_lawn_seed_chooser_flights[_motion_i];
        if (!is_undefined(_motion_flight)
            && global.pvz_lawn_seed_chooser_frame - _motion_flight.start_age < _motion_flight.duration) {
            _chooser_motion_active = true;
            break;
        }
    }
    if (global.pvz_lawn_seed_chooser_active && !_chooser_motion_active && mouse_check_button_pressed(mb_left)) {
        var _chooser_chosen_count = array_length(global.pvz_lawn_seed_chooser_selected);
        var _chooser_start_hover = point_in_rectangle(mouse_x, mouse_y, 154, 545, 310, 587);
        if (_chooser_start_hover) {
            if (_chooser_chosen_count == PVZ_SEED_CHOOSER_REQUIRED && pvz_lawn_seedchooser_commit()) {
                global.pvz_lawn_seed_chooser_active = false;
                global.pvz_lawn_seed_chooser_completed = true;
                global.pvz_lawn_seed_chooser_panel_y = 0;
                pvz_lawn_play_sound("buttonclick.ogg");
            } else {
                pvz_lawn_play_sound("buzzer.ogg");
            }
        } else {
            // Clicking a chosen bank card returns that plant to the chooser, compacting later packets.
            var _chooser_removed = false;
            if (mouse_y >= 8 && mouse_y <= 78) {
                for (var _chooser_bank_i = 0; _chooser_bank_i < _chooser_chosen_count; _chooser_bank_i++) {
                    var _chooser_bank_x = PVZ_SEED_BANK_PACKET_X + _chooser_bank_i * PVZ_SEED_BANK_PACKET_STEP;
                    if (mouse_x >= _chooser_bank_x && mouse_x < _chooser_bank_x + 50) {
                        var _removed_kind = global.pvz_lawn_seed_chooser_selected[_chooser_bank_i];
                        var _removed_source = pvz_lawn_seedchooser_available_index(_removed_kind);
                        if (_removed_source >= 0) global.pvz_lawn_seed_chooser_flights[_removed_source] = undefined;
                        array_delete(global.pvz_lawn_seed_chooser_selected, _chooser_bank_i, 1);
                        // Later bank packets compact left in 6 frames so their return motion is snappier.
                        for (var _shift_i = _chooser_bank_i; _shift_i < array_length(global.pvz_lawn_seed_chooser_selected); _shift_i++) {
                            var _shift_kind = global.pvz_lawn_seed_chooser_selected[_shift_i];
                            var _shift_source = pvz_lawn_seedchooser_available_index(_shift_kind);
                            if (_shift_source >= 0) {
                                var _old_slot_x = PVZ_SEED_BANK_PACKET_X + (_shift_i + 1) * PVZ_SEED_BANK_PACKET_STEP;
                                var _new_slot_x = PVZ_SEED_BANK_PACKET_X + _shift_i * PVZ_SEED_BANK_PACKET_STEP;
                                global.pvz_lawn_seed_chooser_flights[_shift_source] = {
                                    from_x: _old_slot_x, from_y: 8, to_x: _new_slot_x, to_y: 8,
                                    start_age: global.pvz_lawn_seed_chooser_frame, duration: PVZ_SEED_BANK_COMPACT_FRAMES, mode: "bank_shift"
                                };
                            }
                        }
                        pvz_lawn_play_sound("tap.ogg");
                        _chooser_removed = true;
                        break;
                    }
                }
            }
            if (!_chooser_removed) {
                // Original GetSeedPositionInChooser: x=col*53+22, y=123 for the first row.
                for (var _chooser_i = 0; _chooser_i < array_length(global.pvz_lawn_seed_available_kinds); _chooser_i++) {
                    var _chooser_x = PVZ_SEED_CHOOSER_GRID_X + (_chooser_i mod PVZ_SEED_CHOOSER_GRID_COLS) * PVZ_SEED_CHOOSER_GRID_STEP_X;
                    var _chooser_y = PVZ_SEED_CHOOSER_GRID_Y + floor(_chooser_i / PVZ_SEED_CHOOSER_GRID_COLS) * PVZ_SEED_CHOOSER_GRID_STEP_Y;
                    if (mouse_x >= _chooser_x && mouse_x < _chooser_x + 50
                        && mouse_y >= _chooser_y && mouse_y < _chooser_y + 70) {
                        var _chooser_kind = global.pvz_lawn_seed_available_kinds[_chooser_i];
                        var _chooser_already_picked = false;
                        for (var _chooser_j = 0; _chooser_j < array_length(global.pvz_lawn_seed_chooser_selected); _chooser_j++) {
                            if (global.pvz_lawn_seed_chooser_selected[_chooser_j] == _chooser_kind) { _chooser_already_picked = true; break; }
                        }
                        if (!_chooser_already_picked && array_length(global.pvz_lawn_seed_chooser_selected) < PVZ_SEED_CHOOSER_REQUIRED) {
                            var _chooser_target_slot = array_length(global.pvz_lawn_seed_chooser_selected);
                            array_push(global.pvz_lawn_seed_chooser_selected, _chooser_kind);
                            global.pvz_lawn_seed_chooser_flights[_chooser_i] = {
                                from_x: _chooser_x, from_y: _chooser_y,
                                to_x: PVZ_SEED_BANK_PACKET_X + _chooser_target_slot * PVZ_SEED_BANK_PACKET_STEP, to_y: 8,
                                start_age: global.pvz_lawn_seed_chooser_frame, duration: 15, mode: "to_bank"
                            };
                            pvz_lawn_play_sound("tap.ogg");
                        } else if (!_chooser_already_picked) {
                            pvz_lawn_play_sound("buzzer.ogg");
                        }
                        break;
                    }
                }
            }
        }
    }
    // Do not allow garden input to leak through the chooser during its entrance, pause, or exit.
    exit;
}

// Original CutScene blocks lawn interaction during both camera pans and Ready, Set, Plant.
// Keep debug zombie hotkeys available, but do not let any mouse interaction plant/remove/select.
var _pvz_intro_input_locked = global.pvz_lawn_camera_pan_tick < PVZ_CAMERA_PAN_LEFT_END
    || global.pvz_lawn_ready_set_plant_ticks < (PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START);
if (_pvz_intro_input_locked && mouse_check_button_pressed(mb_left)) {
    var _intro_world_x = mouse_x + global.pvz_lawn_camera_x;
    if (_intro_world_x >= PVZ_GRID_X && _intro_world_x < PVZ_GRID_X + PVZ_COLS * PVZ_CELL_W
        && mouse_y >= PVZ_GRID_Y && mouse_y < PVZ_GRID_Y + pvz_lawn_active_rows() * pvz_lawn_cell_height()) {
        global.pvz_lawn_message = "Wait for the intro to finish before planting.";
        global.pvz_lawn_message_ticks = 90;
    }
    exit;
}

// F1 opens the in-level control card without pausing the board.
if (!_pvz_intro_input_locked && keyboard_check_pressed(vk_f1)) global.pvz_lawn_help_open = !global.pvz_lawn_help_open;

// Numpad 1-6 switch to the selected original lawn and restart the test board.
// The reset rebuilds lane geometry (including the two pool lanes), mowers, camera pan,
// plants/zombies and the seed chooser; it never just swaps background artwork.
var _lawn_choice = -1;
if (keyboard_check_pressed(vk_numpad1)) _lawn_choice = 0;
if (keyboard_check_pressed(vk_numpad2)) _lawn_choice = 1;
if (keyboard_check_pressed(vk_numpad3)) _lawn_choice = 2;
if (keyboard_check_pressed(vk_numpad4)) _lawn_choice = 3;
if (keyboard_check_pressed(vk_numpad5)) _lawn_choice = 4;
if (keyboard_check_pressed(vk_numpad6)) _lawn_choice = 5;
if (_lawn_choice >= 0 && !_pvz_intro_input_locked) {
    var _chosen_bg = global.pvz_lawn_bg_sprites[_lawn_choice];
    if (_chosen_bg >= 0) {
        pvz_lawn_reset_for_environment(_lawn_choice);
        // Do not let another key/mouse action from this same Step leak into the reset board.
        exit;
    } else {
        global.pvz_lawn_message = "That lawn backdrop asset could not be loaded.";
        global.pvz_lawn_message_ticks = 180;
    }
}

// Debug-only roster spawning (not part of ordinary level waves): 1-4 are the original four types.
// Letter bindings keep new zombies directly testable without changing level spawn tables.
var _spawn_kind = "";
if (keyboard_check_pressed(ord("1"))) _spawn_kind = "basic";
if (keyboard_check_pressed(ord("2"))) _spawn_kind = "conehead";
if (keyboard_check_pressed(ord("3"))) _spawn_kind = "buckethead";
if (keyboard_check_pressed(ord("4"))) _spawn_kind = "polevaulter";
if (keyboard_check_pressed(ord("F"))) _spawn_kind = "flag";
if (keyboard_check_pressed(ord("N"))) _spawn_kind = "newspaper";
if (keyboard_check_pressed(ord("S"))) _spawn_kind = "screendoor";
if (keyboard_check_pressed(ord("H"))) _spawn_kind = "football";
if (keyboard_check_pressed(ord("D"))) _spawn_kind = "dancer";
if (keyboard_check_pressed(ord("T"))) _spawn_kind = "ducky_tube";
if (keyboard_check_pressed(ord("U"))) _spawn_kind = "ducky_tube_conehead";
if (keyboard_check_pressed(ord("M"))) _spawn_kind = "ducky_tube_buckethead";
if (keyboard_check_pressed(ord("W"))) _spawn_kind = "snorkel";
if (keyboard_check_pressed(ord("O"))) _spawn_kind = "dolphin_rider";
if (keyboard_check_pressed(ord("Z"))) _spawn_kind = "zomboni";
if (keyboard_check_pressed(ord("X"))) _spawn_kind = "bobsled_team";
if (keyboard_check_pressed(ord("C"))) _spawn_kind = "catapult";
if (keyboard_check_pressed(ord("J"))) _spawn_kind = "jackbox";
if (keyboard_check_pressed(ord("B"))) _spawn_kind = "balloon";
if (keyboard_check_pressed(ord("G"))) _spawn_kind = "digger";
if (keyboard_check_pressed(ord("P"))) _spawn_kind = "pogo";
if (keyboard_check_pressed(ord("V"))) _spawn_kind = "bungee";
if (keyboard_check_pressed(ord("L"))) _spawn_kind = "ladder";
if (keyboard_check_pressed(ord("Y"))) _spawn_kind = "yeti";
if (keyboard_check_pressed(ord("R"))) _spawn_kind = "gargantuar";
if (keyboard_check_pressed(ord("E"))) _spawn_kind = "red_eye_gargantuar";
if (keyboard_check_pressed(ord("I"))) _spawn_kind = "imp";
if (keyboard_check_pressed(ord("K"))) _spawn_kind = "boss";
if (_spawn_kind != "") {
    // Pool-only types must spawn on one of the two water lanes. The original Board
    // rejects these types on grass/roof and maps Pool to rows 2 and 3.
    var _pool_only_spawn = (_spawn_kind == "ducky_tube" || _spawn_kind == "ducky_tube_conehead" ||
        _spawn_kind == "ducky_tube_buckethead" || _spawn_kind == "snorkel" ||
        _spawn_kind == "dolphin_rider" || _spawn_kind == "bobsled_team");
    var _is_pool_lawn = (global.pvz_lawn_environment_index == 2 || global.pvz_lawn_environment_index == 3);
    if (_pool_only_spawn && !_is_pool_lawn) {
        global.pvz_lawn_message = "This zombie needs a Pool lawn. Press Numpad 3 or 4, then spawn it again.";
        global.pvz_lawn_message_ticks = 210;
        exit;
    }
    var _row = _pool_only_spawn ? irandom_range(2, 3) : irandom(pvz_lawn_active_rows() - 1);
    var _sx = (_spawn_kind == "polevaulter") ? 870 + irandom(9) : 780 + irandom(39);
    var _sy = pvz_lawn_row_y(_row, _sx, -30);
    var _obj = obj_zombie_basic;
    switch (_spawn_kind) {
        case "conehead": _obj = obj_zombie_conehead; break;
        case "buckethead": _obj = obj_zombie_buckethead; break;
        case "polevaulter": _obj = obj_zombie_polevaulter; break;
        case "flag": _obj = obj_zombie_flag; break;
        case "newspaper": _obj = obj_zombie_newspaper; break;
        case "screendoor": _obj = obj_zombie_screendoor; break;
        case "football": _obj = obj_zombie_football; break;
        case "dancer": _obj = obj_zombie_dancer; break;
        case "ducky_tube": _obj = obj_zombie_ducky_tube; break;
        case "ducky_tube_conehead": _obj = obj_zombie_ducky_tube_conehead; break;
        case "ducky_tube_buckethead": _obj = obj_zombie_ducky_tube_buckethead; break;
        case "snorkel": _obj = obj_zombie_snorkel; break;
        case "dolphin_rider": _obj = obj_zombie_dolphin_rider; break;
        case "zomboni": _obj = obj_zombie_zomboni; break;
        case "bobsled_team": _obj = obj_zombie_bobsled_team; break;
        case "catapult": _obj = obj_zombie_catapult; break;
        case "jackbox": _obj = obj_zombie_jack_in_the_box; break;
        case "balloon": _obj = obj_zombie_balloon; break;
        case "digger": _obj = obj_zombie_digger; break;
        case "pogo": _obj = obj_zombie_pogo; break;
        case "bungee": _obj = obj_zombie_bungee; break;
        case "ladder": _obj = obj_zombie_ladder; break;
        case "yeti": _obj = obj_zombie_yeti; break;
        case "gargantuar": _obj = obj_zombie_gargantuar; break;
        case "red_eye_gargantuar": _obj = obj_zombie_red_eye_gargantuar; break;
        case "imp": _obj = obj_zombie_imp; break;
        case "boss": _obj = obj_zombie_boss; _sx = 0; _sy = 0; _row = 0; break;
    }
    instance_create_layer(_sx, _sy, "Instances", _obj, {row: _row});
    global.pvz_lawn_message = "Spawned " + string_upper(_spawn_kind) + " (debug only).";
    global.pvz_lawn_message_ticks = 150;
}

if (mouse_check_button_pressed(mb_left)) {
    var _world_mouse_x = mouse_x + global.pvz_lawn_camera_x;
    global.pvz_lawn_click_collected_sun = false;
    with (obj_pvz_sun_pickup) {
        if (!picked && !collecting && point_in_rectangle(mouse_x + global.pvz_lawn_camera_x, mouse_y, x - 15, y - 15, x + 75, y + 75)) {
            collecting = true;
            pvz_lawn_play_sound("points.ogg");
            global.pvz_lawn_click_collected_sun = true;
        }
    }
    if (!global.pvz_lawn_click_collected_sun) {
        var _shovel_w = global.pvz_shovel_bank_sprite >= 0 ? sprite_get_width(global.pvz_shovel_bank_sprite) : 70;
        var _shovel_h = global.pvz_shovel_bank_sprite >= 0 ? sprite_get_height(global.pvz_shovel_bank_sprite) : 86;
        var _packet_clicked = -1;
        if (mouse_y >= 8 && mouse_y <= 78) {
            for (var _click_packet_i = 0; _click_packet_i < array_length(global.pvz_lawn_seed_kinds); _click_packet_i++) {
                var _click_packet_x = PVZ_SEED_BANK_PACKET_X + _click_packet_i * PVZ_SEED_BANK_PACKET_STEP;
                if (mouse_x >= _click_packet_x && mouse_x < _click_packet_x + 50) _packet_clicked = _click_packet_i;
            }
        }
        if (point_in_rectangle(mouse_x, mouse_y, 456, 0, 456 + _shovel_w, _shovel_h)) {
            global.pvz_lawn_selected = "";
            global.pvz_lawn_shovel_selected = true;
            pvz_lawn_play_sound("shovel.ogg");
            global.pvz_lawn_message = "Shovel selected. Click a planted tile to remove that plant.";
            global.pvz_lawn_message_ticks = 180;
        } else if (_packet_clicked >= 0) {
            global.pvz_lawn_shovel_selected = false;
            var _clicked_kind = global.pvz_lawn_seed_kinds[_packet_clicked];
            var _clicked_label = global.pvz_lawn_seed_labels[_packet_clicked];
            var _clicked_cost = global.pvz_lawn_seed_costs[_packet_clicked];
            if (global.pvz_lawn_seed_packet_refresh[_packet_clicked] > 0) {
                pvz_lawn_play_sound("buzzer.ogg");
                global.pvz_lawn_message = _clicked_label + " packet is recharging.";
                global.pvz_lawn_message_ticks = 140;
            } else if (global.pvz_lawn_sun < _clicked_cost) {
                pvz_lawn_play_sound("buzzer.ogg");
                global.pvz_lawn_message = _clicked_label + " costs " + string(_clicked_cost) + " sun. Collect more sun first.";
                global.pvz_lawn_message_ticks = 140;
            } else {
                global.pvz_lawn_selected = _clicked_kind;
                pvz_lawn_play_sound("seedlift.ogg");
            }
        } else if (_world_mouse_x >= PVZ_GRID_X && _world_mouse_x < PVZ_GRID_X + PVZ_COLS * PVZ_CELL_W && mouse_y >= PVZ_GRID_Y && mouse_y < PVZ_GRID_Y + pvz_lawn_active_rows() * pvz_lawn_cell_height()) {
            var _col = floor((_world_mouse_x - PVZ_GRID_X) / PVZ_CELL_W);
            var _row = floor((mouse_y - PVZ_GRID_Y) / pvz_lawn_cell_height());
            var _old = global.pvz_lawn_grid[# _col, _row];
            var _support = pvz_lawn_support_at(_col, _row);
            if (global.pvz_lawn_shovel_selected) {
                var _shovel_plant = instance_exists(_old) ? _old : _support;
                if (instance_exists(_shovel_plant)) {
                    pvz_lawn_play_sound("plant2.ogg");
                    pvz_lawn_plant_clear_cell_reference(_shovel_plant);
                    instance_destroy(_shovel_plant);
                    global.pvz_lawn_selected = "";
                    global.pvz_lawn_shovel_selected = false;
                    global.pvz_lawn_message = "Plant removed.";
                    global.pvz_lawn_message_ticks = 120;
                } else {
                    global.pvz_lawn_message = "There is no plant on that tile to shovel.";
                    global.pvz_lawn_message_ticks = 120;
                }
            } else if (instance_exists(_old)) {
                global.pvz_lawn_message = "That square is already occupied. Zombies can eat plants to clear it.";
                global.pvz_lawn_message_ticks = 180;
            } else if (global.pvz_lawn_selected == "") {
                global.pvz_lawn_message = "Choose a seed packet first.";
                global.pvz_lawn_message_ticks = 140;
            } else {
                var _planted_kind = global.pvz_lawn_selected;
                var _seed_idx = pvz_lawn_seed_index(_planted_kind);
                if (_seed_idx < 0) {
                    global.pvz_lawn_message = "That seed is not available.";
                    global.pvz_lawn_message_ticks = 120;
                } else {
                    var _place_error = pvz_lawn_plant_placement_error(_planted_kind, _col, _row);
                    if (_place_error != "") {
                        global.pvz_lawn_message = _place_error;
                        global.pvz_lawn_message_ticks = 180;
                    } else {
                        var _cost = global.pvz_lawn_seed_costs[_seed_idx];
                        var _recharge = global.pvz_lawn_seed_packet_refresh[_seed_idx];
                        if (_recharge > 0) {
                            global.pvz_lawn_message = "That seed packet is still recharging.";
                            global.pvz_lawn_message_ticks = 160;
                        } else if (global.pvz_lawn_sun < _cost) {
                            global.pvz_lawn_message = "Not enough sun. Collect falling sun drops or plant Sunflowers.";
                            global.pvz_lawn_message_ticks = 180;
                        } else {
                            global.pvz_lawn_sun -= _cost;
                            global.pvz_lawn_seed_packet_refresh[_seed_idx] = global.pvz_lawn_seed_recharges[_seed_idx];
                            global.pvz_lawn_seed_packet_flash[_seed_idx] = 0;
                            global.pvz_lawn_seed_packet_ready_state[_seed_idx] = false;
                            var _px = PVZ_GRID_X + _col * PVZ_CELL_W;
                            var _py = pvz_lawn_row_y(_row, _px, 0);
                            var _po = pvz_lawn_plant_object(_planted_kind);
                            var _pi = instance_create_layer(_px, _py, "Instances", _po, {});
                            if (_planted_kind == "lily_pad" || _planted_kind == "flower_pot") {
                                global.pvz_lawn_support_grid[# _col, _row] = _pi;
                            } else {
                                global.pvz_lawn_grid[# _col, _row] = _pi;
                            }
                            pvz_lawn_play_random_sound(["plant.ogg", "plant2.ogg"]);
                            pvz_lawn_spawn_planting_dirt(_px, _py);
                            global.pvz_lawn_selected = "";
                            global.pvz_lawn_shovel_selected = false;
                            global.pvz_lawn_message = global.pvz_lawn_seed_labels[_seed_idx] + " planted.";
                            global.pvz_lawn_message_ticks = 160;
                        }
                    }
                }
                    }
                }
            }
        }
    }
}
