var _snowpea_sprite = variable_global_exists("pvz_fx_snowpea") ? global.pvz_fx_snowpea : -1;
var _pea_sprite = (projectile_kind == "snowpea" && _snowpea_sprite >= 0) ? _snowpea_sprite : global.pvz_fx_pea;
var _pea_tint = (projectile_kind == "snowpea" && _pea_sprite == global.pvz_fx_pea) ? make_color_rgb(110, 185, 255) : c_white;
if (_pea_sprite >= 0) {
    draw_sprite_ext(_pea_sprite, 0, x - global.pvz_lawn_camera_x, y, 1.0, 1.0, 0, _pea_tint, 1);
} else {
    draw_set_color(projectile_kind == "snowpea" ? make_color_rgb(100, 180, 255) : make_color_rgb(100, 196, 63));
    draw_ellipse(x - 7 - global.pvz_lawn_camera_x, y - 6, x + 7 - global.pvz_lawn_camera_x, y + 6, false);
    draw_set_color(projectile_kind == "snowpea" ? make_color_rgb(175, 220, 255) : make_color_rgb(159, 224, 98));
    draw_ellipse(x - 4 - global.pvz_lawn_camera_x, y - 4, x + 2 - global.pvz_lawn_camera_x, y, false);
}
