if (projectile_kind == "basketball") {
    if (variable_global_exists("pvz_catapult_ball_sprite") && global.pvz_catapult_ball_sprite >= 0) {
        draw_sprite_ext(global.pvz_catapult_ball_sprite, 0, x - global.pvz_lawn_camera_x, y, 0.8, 0.8, (flight_ticks * 6) mod 360, c_white, 1.0);
    }
} else if (!is_undefined(body)) {
    pvz_lawn_reanim_draw_camera(body, x, y, global.pvz_lawn_camera_x);
}
