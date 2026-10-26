
// Original SeedBank is drawn at native 446x87 pixels. Six packets use the source 59px spacing.
if (global.pvz_lawn_seed_chooser_entered) {
    pvz_lawn_draw_seed_chooser();
    exit;
}
if (global.pvz_seedbank_sprite >= 0) draw_sprite(global.pvz_seedbank_sprite, 0, 0, 0);
else {
    draw_set_color(make_color_rgb(45, 75, 43));
    draw_rectangle(0, 0, 446, 87, false);
}
var _card_y = 8;
var _packet_xs = array_create(array_length(global.pvz_lawn_seed_kinds), 0);
for (var _card_i = 0; _card_i < array_length(global.pvz_lawn_seed_kinds); _card_i++) {
    var _card_x = PVZ_SEED_BANK_PACKET_X + _card_i * PVZ_SEED_BANK_PACKET_STEP;
    _packet_xs[_card_i] = _card_x;
    if (global.pvz_seeds_atlas >= 0) {
        draw_sprite_part_ext(global.pvz_seeds_atlas, 0, 100, 0, 50, 70, _card_x, _card_y, 1, 1, c_white, 1);
    } else {
        draw_set_color(make_color_rgb(227, 210, 156));
        draw_rectangle(_card_x, _card_y, _card_x + 50, _card_y + 70, false);
    }
    pvz_lawn_draw_plant_ui_icon(global.pvz_lawn_seed_packet_icons[_card_i], _card_x + 5, _card_y + 8, 0.5, 1.0);
}
// SeedPacket::Draw: independent recharge curtain and affordability tint for each card.
for (var _packet_i = 0; _packet_i < array_length(_packet_xs); _packet_i++) {
    var _packet_x = _packet_xs[_packet_i];
    var _packet_cost = global.pvz_lawn_seed_costs[_packet_i];
    var _packet_refresh = max(global.pvz_lawn_seed_packet_refresh[_packet_i], 0);
    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    if (_packet_refresh > 0) {
        draw_set_alpha(1 - 128 / 255);
        draw_rectangle(_packet_x, _card_y, _packet_x + 49, _card_y + 69, false);
        var _dark_h = clamp(round(68 * _packet_refresh / global.pvz_lawn_seed_recharges[_packet_i]) + 2, 2, 70);
        draw_set_alpha(1 - 64 / 255);
        draw_rectangle(_packet_x, _card_y, _packet_x + 49, _card_y + _dark_h - 1, false);
    } else if (global.pvz_lawn_sun < _packet_cost) {
        draw_set_alpha(1 - 128 / 255);
        draw_rectangle(_packet_x, _card_y, _packet_x + 49, _card_y + 69, false);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    if (global.pvz_packet_flash_sprite >= 0 && global.pvz_lawn_seed_packet_flash[_packet_i] > 0 && _packet_refresh <= 0 && global.pvz_lawn_sun >= _packet_cost) {
        var _flash_age = 25 - global.pvz_lawn_seed_packet_flash[_packet_i];
        var _flash_alpha = _flash_age <= 10 ? _flash_age / 10 : max(0, (25 - _flash_age) / 15);
        var _flash_w = sprite_get_width(global.pvz_packet_flash_sprite);
        var _flash_h = sprite_get_height(global.pvz_packet_flash_sprite);
        draw_sprite_ext(global.pvz_packet_flash_sprite, 0, _packet_x + 25 - _flash_w * 0.5, _card_y + 35 - _flash_h * 0.5, 1, 1, 0, c_white, _flash_alpha);
    }
    draw_set_color(c_black);
    var _cost_text = string(_packet_cost);
    var _packet_cost_x = _packet_x + 32 - pvz_lawn_native_font_text_width("Pico129", _cost_text, 1.0);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    pvz_lawn_draw_text_native(_packet_cost_x, _card_y + 54, _cost_text, "Pico129", 1.0);
}
// SeedBank::Draw aligns the sun count at x=34, baseline y=78.
var _sun_counter_color = c_black;
if (global.pvz_lawn_sun < 50 && global.pvz_lawn_message_ticks > 0 && string_pos("Not enough sun", global.pvz_lawn_message) > 0) {
    _sun_counter_color = (global.pvz_lawn_tick mod 20 < 10) ? c_red : c_black;
}
draw_set_color(_sun_counter_color);
draw_set_halign(fa_center); draw_set_valign(fa_top);
pvz_lawn_draw_text_native(34, 64, string(max(global.pvz_lawn_sun, 0)), "ContinuumBold14", 1.0);
draw_set_halign(fa_left); draw_set_valign(fa_top);
// Plant::DrawSeedType previews use the same authentic source Reanimations as the seed packets.
var _camera_x = global.pvz_lawn_camera_x;
var _world_mouse_x = mouse_x + _camera_x;
var _selected_seed_i = pvz_lawn_seed_index(global.pvz_lawn_selected);
if (!global.pvz_lawn_menu_open && _selected_seed_i >= 0 && !global.pvz_lawn_shovel_selected
    && _world_mouse_x >= PVZ_GRID_X && _world_mouse_x < PVZ_GRID_X + PVZ_COLS * PVZ_CELL_W
    && mouse_y >= PVZ_GRID_Y && mouse_y < PVZ_GRID_Y + pvz_lawn_active_rows() * pvz_lawn_cell_height()) {
    var _ghost_col = floor((_world_mouse_x - PVZ_GRID_X) / PVZ_CELL_W);
    var _ghost_row = floor((mouse_y - PVZ_GRID_Y) / pvz_lawn_cell_height());
    if (_ghost_row >= 0 && _ghost_row < pvz_lawn_active_rows() && !instance_exists(global.pvz_lawn_grid[# _ghost_col, _ghost_row])) {
        var _ghost_x = PVZ_GRID_X + _ghost_col * PVZ_CELL_W - _camera_x;
        var _ghost_y = pvz_lawn_row_y(_ghost_row, PVZ_GRID_X + _ghost_col * PVZ_CELL_W, 0);
        pvz_lawn_draw_plant_ui_icon(global.pvz_lawn_seed_ghost_icons[_selected_seed_i], _ghost_x, _ghost_y, 1.0, 0.55);
    }
}
// Original Board::GetShovelButtonRect places the shovel immediately after six seed slots (x=456).
if (global.pvz_shovel_bank_sprite >= 0) draw_sprite(global.pvz_shovel_bank_sprite, 0, 456, 0);
else {
    draw_set_color(make_color_rgb(51, 82, 44));
    draw_rectangle(456, 0, 526, 86, false);
}
if (!global.pvz_lawn_shovel_selected) {
    if (global.pvz_shovel_sprite >= 0) draw_sprite(global.pvz_shovel_sprite, 0, 449, -3);
    else {
        draw_set_color(make_color_rgb(190, 185, 167));
        draw_set_halign(fa_center); draw_set_valign(fa_middle); draw_set_color(c_black);
        pvz_lawn_draw_text_native(491, 28, pvz_lawn_string("SHOVEL", "SHOVEL"), "DwarvenTodcraft12", 0.75);
        draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
    }
} else if (!global.pvz_lawn_menu_open) {
    if (global.pvz_shovel_sprite >= 0) draw_sprite(global.pvz_shovel_sprite, 0, mouse_x - 15, mouse_y - 65);
}
// Board::mMenuButton is a stone GameButton at (681,-10), size 117x46.
var _menu_hover = point_in_rectangle(mouse_x, mouse_y, 681, -10, 798, 36) && !global.pvz_lawn_menu_open;
var _menu_down = _menu_hover && mouse_check_button(mb_left);
pvz_lawn_draw_stone_button(681, -10, 117, 46, pvz_lawn_string("MENU_BUTTON", "MENU"), _menu_hover, _menu_down);
if (global.pvz_lawn_menu_open) pvz_lawn_draw_options_overlay();

// CursorObject::Draw: the selected plant's authentic idle pose follows the pointer.
if (!global.pvz_lawn_menu_open && _selected_seed_i >= 0 && !global.pvz_lawn_shovel_selected) {
    pvz_lawn_draw_plant_ui_icon(global.pvz_lawn_seed_cursor_icons[_selected_seed_i], mouse_x - 35, mouse_y - 60, 1.0, 1.0);
}
// CutScene.cpp's REANIM_READYSETPLANT is screen-space (not translated by the lawn camera).
if (!global.pvz_lawn_menu_open && global.pvz_lawn_ready_set_plant_ticks >= 0 && global.pvz_lawn_ready_set_plant_ticks < PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START) {
    var _ready_set_plant = global.pvz_lawn_ready_set_plant_reanim;
    if (!is_undefined(_ready_set_plant) && _ready_set_plant != noone) {
        _ready_set_plant.x = 400;
        _ready_set_plant.y = 324;
        _ready_set_plant.alpha = 1.0;
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1.0);
        draw_set_color(c_white);
        _ready_set_plant.draw();
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1.0);
        draw_set_color(c_white);
    }
}

// Board::UpdateToolTip + ToolTipWidget::Draw from the original PvZ source.
// It is a square pale-yellow box with a one-pixel black border. Warning text comes first in red,
// then the localized plant name in black; the box anchors below and centered on the packet.
var _tooltip_enabled = !global.pvz_lawn_menu_open
    && global.pvz_lawn_camera_pan_tick >= PVZ_CAMERA_PAN_LEFT_END
    && global.pvz_lawn_ready_set_plant_ticks >= (PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START);
if (_tooltip_enabled) {
    var _tooltip_packet_x = -1;
    var _tooltip_name = "";
    var _tooltip_warning = "";
    for (var _tooltip_i = 0; _tooltip_i < array_length(_packet_xs); _tooltip_i++) {
        var _tooltip_px = _packet_xs[_tooltip_i];
        if (point_in_rectangle(mouse_x, mouse_y, _tooltip_px, _card_y, _tooltip_px + 50, _card_y + 70)) {
            _tooltip_packet_x = _tooltip_px;
            _tooltip_name = pvz_lawn_string(global.pvz_lawn_seed_tooltip_keys[_tooltip_i], global.pvz_lawn_seed_labels[_tooltip_i]);
            if (global.pvz_lawn_seed_packet_refresh[_tooltip_i] > 0) _tooltip_warning = pvz_lawn_string("WAITING_FOR_SEED", "recharging...");
            else if (global.pvz_lawn_sun < global.pvz_lawn_seed_costs[_tooltip_i]) _tooltip_warning = pvz_lawn_string("NOT_ENOUGH_SUN", "not enough sun");
            break;
        }
    }

    if (_tooltip_packet_x >= 0 && _tooltip_name != "") {
        // Original BrianneTod12 is a 12-point bitmap font. Keep it slightly reduced per feedback,
        // while preserving its genuine per-character advances and atlas glyph shapes.
        var _tooltip_text_scale = 0.60;
        var _label_width = pvz_lawn_bitmap_text_width(_tooltip_name, _tooltip_text_scale);
        var _warning_width = _tooltip_warning == "" ? 0 : pvz_lawn_bitmap_text_width(_tooltip_warning, _tooltip_text_scale);
        // Measure actual bitmap advances and add generous side padding: the real atlas has
        // glyph bearings that can extend slightly past the advance width on some strings.
        var _tooltip_w = ceil(max(_label_width, _warning_width)) + 34;
        var _tooltip_font_info = pvz_lawn_native_font_info("BrianneTod12");
        var _tooltip_line_h = _tooltip_font_info.glyph_height * _tooltip_text_scale;
        var _label_h = _tooltip_line_h;
        var _warning_h = _tooltip_warning == "" ? 0 : _tooltip_line_h + 2 * _tooltip_text_scale;
        var _tooltip_h = ceil(8 + _label_h + _warning_h);
        var _tooltip_x = clamp(_tooltip_packet_x + 23 - _tooltip_w * 0.5, 0, room_width - _tooltip_w);
        var _tooltip_y = clamp(_card_y + 70, 0, room_height - _tooltip_h);

        draw_set_alpha(1);
        draw_set_color(make_color_rgb(255, 255, 200)); // ToolTipWidget::Draw: Color(255,255,200,255).
        draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_w - 1, _tooltip_y + _tooltip_h - 1, false);
        draw_set_color(c_black);
        draw_rectangle(_tooltip_x, _tooltip_y, _tooltip_x + _tooltip_w - 1, _tooltip_y + _tooltip_h - 1, true);

        gpu_set_blendmode(bm_normal);
        var _tooltip_text_y = _tooltip_y + 4;
        if (_tooltip_warning != "") {
            // ToolTipWidget::Draw paints waiting/affordability warnings red first.
            pvz_lawn_bitmap_draw_text(_tooltip_warning, _tooltip_x + _tooltip_w * 0.5, _tooltip_text_y, c_red, _tooltip_text_scale);
            _tooltip_text_y += _warning_h;
        }
        pvz_lawn_bitmap_draw_text(_tooltip_name, _tooltip_x + _tooltip_w * 0.5, _tooltip_text_y, c_black, _tooltip_text_scale);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}


// Board::ZombieHitHouse / CutScene::UpdateZombiesWon. Original source pans the board right
// (1500..3500ms), plays REANIM_ZOMBIES_WON at 6000ms, and ends the cutscene at 11000ms.
// Board::DrawHouseDoorTop: front mask is drawn after zombies so the winning body passes behind the open door.
if (global.pvz_lawn_lost_state != "" && global.pvz_lawn_door_mask_sprite >= 0) {
    draw_sprite(global.pvz_lawn_door_mask_sprite, 0, 110 - global.pvz_lawn_camera_x, 262);
}
if (global.pvz_lawn_lost_state != "" && !is_undefined(global.pvz_lawn_lost_reanim)) {
    // CutScene::UpdateZombiesWon adds and cancels the native 1px shake at 7000..8000ms.
    var _loss_shake = global.pvz_lawn_lost_tick >= 700 && global.pvz_lawn_lost_tick < 800;
    global.pvz_lawn_lost_reanim.x = 20 + (_loss_shake ? sin(global.pvz_lawn_lost_tick * 17.0) * 2.0 : 0);
    global.pvz_lawn_lost_reanim.y = 60 + (_loss_shake ? cos(global.pvz_lawn_lost_tick * 19.0) * 2.0 : 0);
    global.pvz_lawn_lost_reanim.draw();
}

// GameOverDialog / LawnDialog: the original 9-slice frame, draggable header and two source-style buttons.
if (global.pvz_lawn_lost_state == "gameover") {
    draw_set_alpha(0.48); draw_set_color(c_black); draw_rectangle(0, 0, room_width, room_height, false); draw_set_alpha(1);
    var _gx = global.pvz_lawn_gameover_x;
    var _gy = global.pvz_lawn_gameover_y;
    var _gw = 430;
    var _gh = 300;
    var _dlg_tl = global.pvz_lawn_dialog_tl_sprite;
    var _dlg_tm = global.pvz_lawn_dialog_tm_sprite;
    var _dlg_tr = global.pvz_lawn_dialog_tr_sprite;
    var _dlg_ml = global.pvz_lawn_dialog_ml_sprite;
    var _dlg_mm = global.pvz_lawn_dialog_mm_sprite;
    var _dlg_mr = global.pvz_lawn_dialog_mr_sprite;
    var _dlg_bl = global.pvz_lawn_dialog_bl_sprite;
    var _dlg_bm = global.pvz_lawn_dialog_bm_sprite;
    var _dlg_br = global.pvz_lawn_dialog_br_sprite;
    var _dlg_header = global.pvz_lawn_dialog_header_sprite;
    if (_dlg_tl >= 0 && _dlg_tm >= 0 && _dlg_tr >= 0 && _dlg_ml >= 0 && _dlg_mm >= 0 && _dlg_mr >= 0 && _dlg_bl >= 0 && _dlg_bm >= 0 && _dlg_br >= 0) {
        var _tlw = sprite_get_width(_dlg_tl); var _trw = sprite_get_width(_dlg_tr);
        var _tmw = max(1, sprite_get_width(_dlg_tm)); var _tmh = sprite_get_height(_dlg_tm);
        var _left_h = sprite_get_height(_dlg_tl); var _bottom_h = sprite_get_height(_dlg_bl);
        var _mid_h = max(1, sprite_get_height(_dlg_ml));
        var _repeat_x = max(0, floor((_gw - _tlw - _trw) / _tmw));
        var _repeat_y = max(0, floor((_gh - 99 - _left_h - _bottom_h) / _mid_h));
        var _panel_w = _tlw + _trw + _repeat_x * _tmw;
        draw_sprite(_dlg_tl, 0, _gx, _gy + 99);
        var _px = _gx + _tlw;
        for (var _tx = 0; _tx < _repeat_x; _tx++) { draw_sprite(_dlg_tm, 0, _px, _gy + 99); _px += _tmw; }
        draw_sprite(_dlg_tr, 0, _px, _gy + 99);
        var _py = _gy + 99 + sprite_get_height(_dlg_tr);
        for (var _ry = 0; _ry < _repeat_y; _ry++) {
            draw_sprite(_dlg_ml, 0, _gx, _py);
            var _mx = _gx + sprite_get_width(_dlg_ml);
            for (var _rx = 0; _rx < _repeat_x; _rx++) { draw_sprite(_dlg_mm, 0, _mx, _py); _mx += sprite_get_width(_dlg_mm); }
            draw_sprite(_dlg_mr, 0, _mx, _py);
            _py += _mid_h;
        }
        draw_sprite(_dlg_bl, 0, _gx, _py);
        _px = _gx + sprite_get_width(_dlg_bl);
        for (var _bx = 0; _bx < _repeat_x; _bx++) { draw_sprite(_dlg_bm, 0, _px, _py); _px += sprite_get_width(_dlg_bm); }
        draw_sprite(_dlg_br, 0, _px, _py);
        if (_dlg_header >= 0) draw_sprite(_dlg_header, 0, _gx + (_gw - sprite_get_width(_dlg_header)) * 0.5 - 5, _gy);
    } else {
        draw_set_color(make_color_rgb(75, 56, 36)); draw_rectangle(_gx, _gy + 60, _gx + _gw, _gy + _gh, false);
        draw_set_color(make_color_rgb(224, 187, 98)); draw_rectangle(_gx, _gy + 60, _gx + _gw, _gy + _gh, true);
    }
    // Native dialog header text and the ZombiesWon scene's game-over message.
    draw_set_color(make_color_rgb(213, 159, 43)); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    pvz_lawn_draw_text_native(_gx + _gw * 0.5, _gy + 125, pvz_lawn_string("GAME_OVER", "GAME OVER"), "DwarvenTodcraft24", 0.90);
    draw_set_color(make_color_rgb(107, 109, 145));
    pvz_lawn_draw_text_native(_gx + _gw * 0.5, _gy + 164, "THE ZOMBIES ATE YOUR BRAINS!", "DwarvenTodcraft15", 0.82);
    var _try_hover = point_in_rectangle(mouse_x, mouse_y, _gx + 42, _gy + 230, _gx + 207, _gy + 276);
    var _main_hover = point_in_rectangle(mouse_x, mouse_y, _gx + 225, _gy + 230, _gx + 390, _gy + 276);
    pvz_lawn_draw_stone_button(_gx + 42, _gy + 230, 165, 46, pvz_lawn_string("TRY_AGAIN", "Try Again"), _try_hover, _try_hover && mouse_check_button(mb_left));
    pvz_lawn_draw_stone_button(_gx + 225, _gy + 230, 165, 46, pvz_lawn_string("MAIN_MENU_BUTTON", "Main Menu"), _main_hover, _main_hover && mouse_check_button(mb_left));
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
}

// F1 debug sheet: expose the already-existing direct-spawn keys so the full roster is discoverable.
if (global.pvz_lawn_help_open && global.pvz_lawn_lost_state == ""
    && !global.pvz_lawn_menu_open && !global.pvz_lawn_seed_chooser_entered) {
    var _help_x = 78;
    var _help_y = 38;
    var _help_w = 644;
    var _help_h = 520;
    draw_set_alpha(0.94);
    draw_set_color(make_color_rgb(35, 53, 35));
    draw_rectangle(_help_x, _help_y, _help_x + _help_w, _help_y + _help_h, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(230, 196, 111));
    draw_rectangle(_help_x, _help_y, _help_x + _help_w, _help_y + _help_h, true);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    pvz_lawn_draw_text_native(_help_x + _help_w * 0.5, _help_y + 10, "DEBUG CONTROLS - PRESS F1 TO CLOSE", "DwarvenTodcraft15", 0.86);
    pvz_lawn_draw_text_native(_help_x + _help_w * 0.5, _help_y + 32,
        "NUMPAD 1 Day | 2 Night | 3 Pool | 4 Pool Night | 5 Roof | 6 Boss Roof",
        "DwarvenTodcraft12", 0.63);
    draw_set_halign(fa_left);
    var _help_left = [
        "1   Basic Zombie", "2   Conehead Zombie", "3   Buckethead Zombie", "4   Pole Vaulting Zombie",
        "F   Flag Zombie", "N   Newspaper Zombie", "S   Screen Door Zombie", "H   Football Zombie",
        "D   Dancing Zombie", "T   Ducky Tube Zombie", "U   Conehead Ducky Tube", "M   Buckethead Ducky Tube",
        "W   Snorkel Zombie", "O   Dolphin Rider Zombie"
    ];
    var _help_right = [
        "Z   Zomboni", "X   Bobsled Team", "C   Catapult Zombie", "J   Jack-in-the-Box Zombie",
        "B   Balloon Zombie", "G   Digger Zombie", "P   Pogo Zombie", "V   Bungee Zombie",
        "L   Ladder Zombie", "Y   Yeti Zombie", "R   Gargantuar", "E   Red-Eye Gargantuar",
        "I   Imp", "K   Dr. Zomboss"
    ];
    for (var _help_i = 0; _help_i < array_length(_help_left); _help_i++) {
        var _help_line_y = _help_y + 67 + _help_i * 27;
        pvz_lawn_draw_text_native(_help_x + 20, _help_line_y, _help_left[_help_i], "DwarvenTodcraft12", 0.72);
        pvz_lawn_draw_text_native(_help_x + 330, _help_line_y, _help_right[_help_i], "DwarvenTodcraft12", 0.72);
    }
    draw_set_color(make_color_rgb(221, 213, 167));
    pvz_lawn_draw_text_native(_help_x + 20, _help_y + _help_h - 37,
        "Numpad resets the board. Pool uses 6 rows; water zombies need Pool Day/Night.",
        "DwarvenTodcraft12", 0.62);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}
