var _a = clamp(1 - fx_age / fx_life, 0, 1);
if (global.pvz_fx_splat >= 0) {
    draw_set_alpha(_a);
    draw_sprite_ext(global.pvz_fx_splat, image_index, x - global.pvz_lawn_camera_x, y, 0.62 + fx_age * 0.025, 0.62 + fx_age * 0.025, 0, c_white, 1);
    draw_set_alpha(1);
} else {
    draw_set_alpha(_a);
    draw_set_color(make_color_rgb(105, 177, 67));
    var _r = 3 + fx_age * 0.5;
    draw_circle(x - global.pvz_lawn_camera_x, y, _r, false);
    draw_circle(x - _r - global.pvz_lawn_camera_x, y - 1, max(1, _r * 0.35), false);
    draw_circle(x + _r * 0.8 - global.pvz_lawn_camera_x, y - _r * 0.3, max(1, _r * 0.25), false);
    draw_set_alpha(1);
}
