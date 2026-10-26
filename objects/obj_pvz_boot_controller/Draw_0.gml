gpu_set_texfilter(true);
draw_clear(c_black);
if (boot_state == "popcap") {
    var _a = 255;
    if (boot_ticks < 50) _a = round(255 * clamp(boot_ticks / 50.0, 0, 1));
    else if (boot_ticks > 150) _a = round(255 * clamp((200 - boot_ticks) / 50.0, 0, 1));
    if (popcap_logo >= 0) {
        draw_set_alpha(_a / 255.0);
        draw_sprite(popcap_logo, 0, (room_width - sprite_get_width(popcap_logo)) * 0.5, (room_height - sprite_get_height(popcap_logo)) * 0.5);
        draw_set_alpha(1);
    }
    gpu_set_texfilter(false);
    exit;
}
if (boot_state == "title" || boot_state == "loading" || boot_state == "click_to_start") {
    if (title_background >= 0) draw_sprite(title_background, 0, 0, 0);
    else {
        draw_set_color(make_color_rgb(30, 100, 25)); draw_rectangle(0,0,room_width,room_height,false); draw_set_color(c_white);
        pvz_lawn_draw_text_native(20, 20, "Plants vs. Zombies", "DwarvenTodcraft24", 1.0);
    }
    if (title_logo >= 0) {
        var _lw = sprite_get_width(title_logo);
        var _lh = sprite_get_height(title_logo);
        // TitleScreen.cpp source y positions include BOARD_OFFSET_Y = 60.
        var _logo_y = 75;
        if (boot_state == "title") {
            var _ty = clamp(boot_ticks / 40.0, 0, 1);
            if (boot_ticks < 40) _logo_y = lerp(-_lh, 70, _ty * _ty);
            else if (boot_ticks < 50) { var _bt = clamp((boot_ticks - 40) / 10.0,0,1); _logo_y = lerp(70,75,_bt * (1 - (1-_bt)*(1-_bt))); }
        }
        draw_sprite(title_logo, 0, (room_width - _lw) * 0.5, _logo_y);
    }
    if (boot_state != "title" || boot_ticks >= 30) {
        var _dw = loadbar_dirt >= 0 ? sprite_get_width(loadbar_dirt) : 354;
        var _dh = loadbar_dirt >= 0 ? sprite_get_height(loadbar_dirt) : 30;
        var _gx = (room_width - _dw) * 0.5;
        var _gy = 511;
        var _entry = clamp((boot_state == "title" ? (boot_ticks - 30) / 30.0 : 1),0,1);
        _gy = lerp(room_height + 10, 511, _entry);
        if (loadbar_dirt >= 0) draw_sprite(loadbar_dirt,0,_gx,_gy+18);
        var _w = boot_state == "title" ? 0 : loadbar_width * load_progress;
        if (loadbar_grass >= 0 && _w > 0) {
            // TitleScreen::Draw clips the original grass texture to mCurBarWidth; leave its 15px left inset.
            var _sw = sprite_get_width(loadbar_grass);
            var _sh = sprite_get_height(loadbar_grass);
            var _srcw = clamp(floor(_w), 0, max(0, _sw - 15));
            if (_srcw > 0) draw_sprite_part(loadbar_grass,0,15,0,_srcw,_sh,_gx+15,_gy);
        }
        if (loadbar_cap >= 0 && boot_state != "title" && load_progress < 1) {
            var _roll = loadbar_width * load_progress * 0.94;
            var _scale = lerp(1.0,0.5,load_progress);
            var _cw = sprite_get_width(loadbar_cap); var _ch = sprite_get_height(loadbar_cap);
            var _cx = _gx + 11 + _roll; var _cy = _gy - 3 - 35 * _scale + 35;
            draw_sprite_ext(loadbar_cap,0,_cx-_cw*_scale*0.5,_cy-_ch*_scale*0.5,_scale,_scale,-_roll*2,c_white,1);
        }
        for (var _i = 0; _i < array_length(loadbar_effects); _i++) loadbar_effects[_i].draw();
        draw_set_color(c_white);
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        if (boot_state == "click_to_start") {
            draw_set_color(make_color_rgb(218, 184, 33));
            pvz_lawn_draw_text_native(room_width*0.5, _gy + 43, "CLICK TO START!", "BrianneTod16", 1.0);
            draw_set_color(c_white);
        } else if (boot_state == "loading") {
            draw_set_color(make_color_rgb(218, 184, 33));
            pvz_lawn_draw_text_native(room_width*0.5, _gy + 43, "LOADING...", "BrianneTod16", 1.0);
            draw_set_color(c_white);
        }
        draw_set_halign(fa_left); draw_set_valign(fa_top);
    }
    gpu_set_texfilter(false);
    exit;
}
if (boot_state == "menu" || boot_state == "starting_adventure") {
    // Match GameSelector::Draw: background group, six independent clouds, then foreground.
    if (menu_reanim != undefined) menu_reanim.draw(1);
    for (var _ci = 0; _ci < array_length(cloud_reanim); _ci++) cloud_reanim[_ci].draw();
    if (menu_reanim != undefined) menu_reanim.draw(0);
    if (leaf_reanim != undefined) leaf_reanim.draw();

    // Never leave a blank control strip while anim_sign runs: the real source animates the sign
    // independently from its button widgets, so these overlays remain drawn over the moving art.
    var _menu_controls_visible = menu_sign_started && menu_reanim != undefined;
    if (_menu_controls_visible) {
        // GameSelector draws interactive widgets over the hidden Reanim button tracks.
        var _start_idx = menu_reanim.find_track("SelectorScreen_StartAdventure_button");
        var _start_xf = menu_reanim.get_current_transform(_start_idx);
        var _start_spr = (hover_start_adventure && menu_spr_start_adventure_highlight >= 0)
            ? menu_spr_start_adventure_highlight : menu_spr_start_adventure;
        if (_start_spr >= 0) draw_sprite_ext(_start_spr, 0, menu_reanim.x + _start_xf[RT_X], menu_reanim.y + _start_xf[RT_Y], 1, 1, 0, c_white, 1);

        // OG GameSelector::SyncButtons keeps these modes visually locked until progression unlocks them.
        // The original normal images are tinted gray (128,128,128), and they do not highlight on hover.
        var _mini_idx = menu_reanim.find_track("SelectorScreen_Survival_button");
        var _mini_xf = menu_reanim.get_current_transform(_mini_idx);
        if (menu_spr_minigame >= 0) draw_sprite_ext(menu_spr_minigame, 0, menu_reanim.x + _mini_xf[RT_X], menu_reanim.y + _mini_xf[RT_Y], 1, 1, 0, make_color_rgb(128,128,128), 1);

        var _puzzle_idx = menu_reanim.find_track("SelectorScreen_Challenges_button");
        var _puzzle_xf = menu_reanim.get_current_transform(_puzzle_idx);
        if (menu_spr_puzzle >= 0) draw_sprite_ext(menu_spr_puzzle, 0, menu_reanim.x + _puzzle_xf[RT_X], menu_reanim.y + _puzzle_xf[RT_Y], 1, 1, 0, make_color_rgb(128,128,128), 1);

        var _vase_idx = menu_reanim.find_track("SelectorScreen_ZenGarden_button");
        var _vase_xf = menu_reanim.get_current_transform(_vase_idx);
        if (menu_spr_vasebreaker >= 0) draw_sprite_ext(menu_spr_vasebreaker, 0, menu_reanim.x + _vase_xf[RT_X], menu_reanim.y + _vase_xf[RT_Y], 1, 1, 0, make_color_rgb(128,128,128), 1);

        // Original pot button offsets from GameSelector::Update / TrackButton.
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
        var _almanac_spr = (hover_almanac && menu_spr_almanac_highlight >= 0) ? menu_spr_almanac_highlight : menu_spr_almanac;
        var _store_spr = (hover_store && menu_spr_store_highlight >= 0) ? menu_spr_store_highlight : menu_spr_store;
        var _zen_spr = (hover_zengarden && menu_spr_zengarden_highlight >= 0) ? menu_spr_zengarden_highlight : menu_spr_zengarden;
        if (_almanac_spr >= 0) draw_sprite(_almanac_spr, 0, _almanac_x, _almanac_y);
        if (_store_spr >= 0) draw_sprite(_store_spr, 0, _store_x, _store_y);
        if (_zen_spr >= 0) draw_sprite(_zen_spr, 0, _zen_x, _zen_y);

        // GameSelector::Draw / NewLawnButton position, button offsets, and resized bounds.
        var _options_x = _pot_bg_x + 494 + 111;
        var _options_y = _pot_bg_y + 434 + 80;
        var _help_x = _pot_bg_x + 576 + 111;
        var _help_y = _pot_bg_y + 458 + 80;
        var _quit_x = _pot_bg_x + 644 + 111;
        var _quit_y = _pot_bg_y + 469 + 80;
        var _options_art = (hover_options && menu_spr_options_highlight >= 0) ? menu_spr_options_highlight : menu_spr_options;
        var _help_art = (hover_help && menu_spr_help_highlight >= 0) ? menu_spr_help_highlight : menu_spr_help;
        var _quit_art = (hover_quit && menu_spr_quit_highlight >= 0) ? menu_spr_quit_highlight : menu_spr_quit;
        if (_options_art >= 0) draw_sprite(_options_art, 0, _options_x, _options_y + 15);
        if (_help_art >= 0) draw_sprite(_help_art, 0, _help_x, _help_y + 30);
        if (_quit_art >= 0) draw_sprite(_quit_art, 0, _quit_x + 5, _quit_y + 5);

        // GameSelector::Draw writes the active player identity over the welcome sign.
        draw_set_color(make_color_rgb(255,245,200));
        draw_set_halign(fa_center); draw_set_valign(fa_middle);
        pvz_lawn_draw_text_native(170.5, 102.5, profile_name + "!", "BrianneTod16", 1.0);
        draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
    }

    if (boot_state == "starting_adventure" && is_struct(hand_reanim)) hand_reanim.draw();
    if (boot_state == "starting_adventure") {
        draw_set_alpha(clamp((start_transition_ticks - 376.0) / 75.0, 0, 1));
        draw_set_color(c_black); draw_rectangle(0,0,room_width,room_height,false);
        draw_set_alpha(1); draw_set_color(c_white);
    }
    if (boot_state == "menu" && menu_modal != "") {
        var _ml = menu_modal_layout();
        draw_set_alpha(0.58); draw_set_color(c_black); draw_rectangle(0, 0, room_width, room_height, false); draw_set_alpha(1); draw_set_color(c_white);

        if (menu_modal == "options" || menu_modal == "options_advanced") {
            // NewOptionsDialog::Draw uses IMAGE_OPTIONS_MENUBACK and its original control sprites.
            if (menu_spr_options_bg >= 0) draw_sprite(menu_spr_options_bg, 0, _ml.ox, _ml.oy);
            draw_set_color(make_color_rgb(107, 109, 145));
            draw_set_halign(fa_right); draw_set_valign(fa_middle);
            if (menu_modal == "options") {
                pvz_lawn_draw_text_native(_ml.ox + 186, _ml.oy + 145, pvz_lawn_string("OPTIONS_MUSIC", "Music"), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 186, _ml.oy + 177, pvz_lawn_string("OPTIONS_SOUND", "Sound"), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 274, _ml.oy + 212, pvz_lawn_string("OPTIONS_ACCELERATION", "3D Acceleration"), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 274, _ml.oy + 248, pvz_lawn_string("OPTIONS_FULLSCREEN", "Fullscreen"), "DwarvenTodcraft12", 0.85);

                if (menu_spr_options_slider >= 0) {
                    draw_sprite(menu_spr_options_slider, 0, _ml.music_x, _ml.music_y);
                    draw_sprite(menu_spr_options_slider, 0, _ml.sfx_x, _ml.sfx_y);
                }
                if (menu_spr_options_knob >= 0) {
                    var _kw = sprite_get_width(menu_spr_options_knob); var _kh = sprite_get_height(menu_spr_options_knob);
                    var _music_kx = _ml.music_x + 8 + global.pvz_lawn_music_volume * max(0, _ml.music_w - _kw - 16);
                    var _sfx_kx = _ml.sfx_x + 8 + global.pvz_lawn_sfx_volume * max(0, _ml.sfx_w - _kw - 16);
                    draw_sprite(menu_spr_options_knob, 0, _music_kx, _ml.music_y + (_ml.music_h - _kh) * 0.5);
                    draw_sprite(menu_spr_options_knob, 0, _sfx_kx, _ml.sfx_y + (_ml.sfx_h - _kh) * 0.5);
                }
                draw_set_halign(fa_left);
                pvz_lawn_draw_text_native(_ml.ox + 342, _ml.oy + 148, string(round(global.pvz_lawn_music_volume * 100)), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 342, _ml.oy + 180, string(round(global.pvz_lawn_sfx_volume * 100)), "DwarvenTodcraft12", 0.85);
                if (menu_spr_options_check_off >= 0 && menu_spr_options_check_on >= 0) {
                    draw_sprite(global.pvz_lawn_accel_enabled ? menu_spr_options_check_on : menu_spr_options_check_off, 0, _ml.accel_x, _ml.accel_y);
                    draw_sprite(global.pvz_lawn_fullscreen_enabled ? menu_spr_options_check_on : menu_spr_options_check_off, 0, _ml.fullscreen_x, _ml.fullscreen_y);
                }
                pvz_lawn_draw_stone_button(_ml.almanac_x, _ml.almanac_y, _ml.button_w, _ml.button_h,
                    pvz_lawn_string("VIEW_ALMANAC_BUTTON", "View Almanac"),
                    point_in_rectangle(mouse_x, mouse_y, _ml.almanac_x, _ml.almanac_y, _ml.almanac_x + _ml.button_w, _ml.almanac_y + _ml.button_h), false);
                pvz_lawn_draw_stone_button(_ml.advanced_x, _ml.advanced_y, _ml.button_w, _ml.button_h,
                    pvz_lawn_string("ADVANCED_OPTIONS_BUTTON", "Advanced Options"),
                    point_in_rectangle(mouse_x, mouse_y, _ml.advanced_x, _ml.advanced_y, _ml.advanced_x + _ml.button_w, _ml.advanced_y + _ml.button_h), false);
            } else {
                // NewOptionsDialog::UpdateAdvancedPage (page 1): original four checkboxes and labels.
                pvz_lawn_draw_text_native(_ml.ox + _ml.bgw * 0.5, _ml.oy + 137, "GameMaker PvZ recreation", "DwarvenTodcraft12", 0.85);
                draw_set_halign(fa_right);
                pvz_lawn_draw_text_native(_ml.ox + 278, _ml.oy + 170, pvz_lawn_string("OPTIONS_DEBUG_MODE", "Debug Mode"), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 278, _ml.oy + 210, pvz_lawn_string("OPTIONS_DISCORD_PRESENCE", "Discord Presence"), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 278, _ml.oy + 250, pvz_lawn_string("OPTIONS_SEED_BANK_KEYBINDS", "Seed Bank Keybinds"), "DwarvenTodcraft12", 0.85);
                pvz_lawn_draw_text_native(_ml.ox + 278, _ml.oy + 290, pvz_lawn_string("OPTIONS_SEED_BANK_KEYBIND", "Seed Bank Format"), "DwarvenTodcraft12", 0.85);
                draw_set_halign(fa_left);
                if (menu_spr_options_check_off >= 0 && menu_spr_options_check_on >= 0) {
                    draw_sprite(global.pvz_lawn_debug_mode ? menu_spr_options_check_on : menu_spr_options_check_off, 0, _ml.ox + 284, _ml.oy + 148);
                    draw_sprite(global.pvz_lawn_discord_presence ? menu_spr_options_check_on : menu_spr_options_check_off, 0, _ml.ox + 284, _ml.oy + 188);
                    draw_sprite(global.pvz_lawn_bank_keybinds ? menu_spr_options_check_on : menu_spr_options_check_off, 0, _ml.ox + 284, _ml.oy + 228);
                    draw_sprite(global.pvz_lawn_zero_nine_format ? menu_spr_options_check_on : menu_spr_options_check_off, 0, _ml.ox + 284, _ml.oy + 268);
                }
                draw_set_halign(fa_center);
                pvz_lawn_draw_text_native(_ml.ox + _ml.bgw * 0.5, _ml.oy + 350, global.pvz_lawn_zero_nine_format ? "1-0" : "0-9", "DwarvenTodcraft12", 0.85);
            }
            draw_set_halign(fa_left); draw_set_valign(fa_top);
            // Native options back button: image normal/down state plus the original translated label.
            var _okx = _ml.ok_x; var _oky = _ml.ok_y;
            var _okw = menu_spr_options_back >= 0 ? sprite_get_width(menu_spr_options_back) : 360;
            var _okh = menu_spr_options_back >= 0 ? sprite_get_height(menu_spr_options_back) : 100;
            var _okhover = point_in_rectangle(mouse_x, mouse_y, _okx, _oky, _okx + _okw, _oky + _okh);
            var _okart = (_okhover && mouse_check_button(mb_left) && menu_spr_options_back_down >= 0) ? menu_spr_options_back_down : menu_spr_options_back;
            if (_okart >= 0) draw_sprite(_okart, 0, _okx, _oky);
            draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_middle);
            pvz_lawn_draw_text_native(_okx + _okw * 0.5, _oky + _okh * 0.5 - 4,
                menu_modal == "options_advanced" ? pvz_lawn_string("DIALOG_BUTTON_BACK", "Back") : pvz_lawn_string("DIALOG_BUTTON_OK", "OK"), "DwarvenTodcraft15", 0.90);
            draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
        } else if (menu_modal == "help") {
            // AwardScreen::Draw for AWARD_HELP_ZOMBIENOTE: original day background + both note layers.
            if (menu_spr_help_background >= 0) draw_sprite_stretched(menu_spr_help_background, 0, -700, -300, 2800, 1200);
            if (menu_spr_help_note >= 0) draw_sprite(menu_spr_help_note, 0, 80, 80 + 60);
            if (menu_spr_help_note_inner >= 0) draw_sprite(menu_spr_help_note_inner, 0, 131, 132 + 60);
            // AwardScreen's source button: SeedChooser button + hover glow, 156x42 at (324,500)+board offsets.
            var _hbx = _ml.help_button_x; var _hby = _ml.help_button_y;
            var _hbhover = point_in_rectangle(mouse_x, mouse_y, _hbx, _hby, _hbx + _ml.help_button_w, _hby + _ml.help_button_h);
            if (menu_spr_help_button >= 0) draw_sprite_stretched(menu_spr_help_button, 0, _hbx, _hby, _ml.help_button_w, _ml.help_button_h);
            if (_hbhover && menu_spr_help_button_glow >= 0) draw_sprite_stretched(menu_spr_help_button_glow, 0, _hbx, _hby, _ml.help_button_w, _ml.help_button_h);
            draw_set_color(make_color_rgb(213, 159, 43)); draw_set_halign(fa_center); draw_set_valign(fa_middle);
            pvz_lawn_draw_text_native(_hbx + _ml.help_button_w * 0.5, _hby + _ml.help_button_h * 0.5 - 1, pvz_lawn_string("MAIN_MENU_BUTTON", "Main Menu"), "DwarvenTodcraft15", 0.90);
            draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
        } else if (menu_modal == "quit") {
            // LawnApp::ConfirmQuit with its source dialog nine-slice tiles and OK/Cancel buttons.
            var _qx = _ml.quit_x; var _qy = _ml.quit_y; var _qw = _ml.quit_w; var _qh = _ml.quit_h;
            var _edge_l = 28; var _edge_r = 28; var _header_h = 44; var _bottom_h = 28;
            if (menu_spr_dialog_tl >= 0 && menu_spr_dialog_tm >= 0 && menu_spr_dialog_tr >= 0 &&
                menu_spr_dialog_ml >= 0 && menu_spr_dialog_mm >= 0 && menu_spr_dialog_mr >= 0 &&
                menu_spr_dialog_bl >= 0 && menu_spr_dialog_bm >= 0 && menu_spr_dialog_br >= 0) {
                draw_sprite_stretched(menu_spr_dialog_tl, 0, _qx, _qy, _edge_l, _header_h);
                draw_sprite_stretched(menu_spr_dialog_tm, 0, _qx + _edge_l, _qy, _qw - _edge_l - _edge_r, _header_h);
                draw_sprite_stretched(menu_spr_dialog_tr, 0, _qx + _qw - _edge_r, _qy, _edge_r, _header_h);
                draw_sprite_stretched(menu_spr_dialog_ml, 0, _qx, _qy + _header_h, _edge_l, _qh - _header_h - _bottom_h);
                draw_sprite_stretched(menu_spr_dialog_mm, 0, _qx + _edge_l, _qy + _header_h, _qw - _edge_l - _edge_r, _qh - _header_h - _bottom_h);
                draw_sprite_stretched(menu_spr_dialog_mr, 0, _qx + _qw - _edge_r, _qy + _header_h, _edge_r, _qh - _header_h - _bottom_h);
                draw_sprite_stretched(menu_spr_dialog_bl, 0, _qx, _qy + _qh - _bottom_h, _edge_l, _bottom_h);
                draw_sprite_stretched(menu_spr_dialog_bm, 0, _qx + _edge_l, _qy + _qh - _bottom_h, _qw - _edge_l - _edge_r, _bottom_h);
                draw_sprite_stretched(menu_spr_dialog_br, 0, _qx + _qw - _edge_r, _qy + _qh - _bottom_h, _edge_r, _bottom_h);
            } else {
                draw_set_color(make_color_rgb(238, 221, 168)); draw_roundrect(_qx, _qy, _qx + _qw, _qy + _qh, false);
                draw_set_color(make_color_rgb(104, 80, 48)); draw_roundrect(_qx, _qy, _qx + _qw, _qy + _qh, true);
            }
            if (menu_spr_dialog_header >= 0) draw_sprite_stretched(menu_spr_dialog_header, 0, _qx + _edge_l, _qy, _qw - _edge_l - _edge_r, _header_h);
            draw_set_color(make_color_rgb(72, 55, 36)); draw_set_halign(fa_center); draw_set_valign(fa_middle);
            pvz_lawn_draw_text_native(room_width * 0.5, _qy + 23, pvz_lawn_string("QUIT_HEADER", "Quit Plants vs. Zombies?"), "DwarvenTodcraft18Yellow", 0.95);
            draw_set_halign(fa_left); draw_set_valign(fa_top);
            pvz_lawn_draw_text_ext_native(_qx + 38, _qy + 70, pvz_lawn_string("QUIT_MESSAGE", "Are you sure you want to quit?"), 4, _qw - 76, "BrianneTod16", 0.9);
            var _by = _qy + 157; var _bx1 = _qx + 42; var _bx2 = _qx + 246;
            var _bhv1 = point_in_rectangle(mouse_x, mouse_y, _bx1, _by, _bx1 + 132, _by + 42);
            var _bhv2 = point_in_rectangle(mouse_x, mouse_y, _bx2, _by, _bx2 + 132, _by + 42);
            pvz_lawn_draw_stone_button(_bx1, _by, 132, 42, pvz_lawn_string("QUIT_BUTTON", "Quit"), _bhv1, _bhv1 && mouse_check_button(mb_left));
            pvz_lawn_draw_stone_button(_bx2, _by, 132, 42, pvz_lawn_string("DIALOG_BUTTON_CANCEL", "Cancel"), _bhv2, _bhv2 && mouse_check_button(mb_left));
        }
        draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
    }
    gpu_set_texfilter(false);
    exit;
}
gpu_set_texfilter(false);
