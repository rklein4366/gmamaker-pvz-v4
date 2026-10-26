if (projectile_kind == "basketball") {
    if (variable_global_exists("pvz_catapult_ball_sprite") && global.pvz_catapult_ball_sprite >= 0) {
        draw_sprite_ext(global.pvz_catapult_ball_sprite, 0, x - global.pvz_lawn_camera_x, y, 0.8, 0.8, (flight_ticks * 6) mod 360, c_white, 1.0);
    }
} else if (!is_undefined(body) && body != noone) {
    // Draw the base ball normally, then the source-assigned superglow/ice-highlight tracks
    // additively. This avoids the flat white overlay caused by drawing every track normally.
    gpu_set_blendmode(bm_normal);
    pvz_lawn_reanim_draw_camera(body, x, y, global.pvz_lawn_camera_x, 0);
    gpu_set_blendmode(bm_add);
    pvz_lawn_reanim_draw_camera(body, x, y, global.pvz_lawn_camera_x, 7);
    gpu_set_blendmode(bm_normal);
}
