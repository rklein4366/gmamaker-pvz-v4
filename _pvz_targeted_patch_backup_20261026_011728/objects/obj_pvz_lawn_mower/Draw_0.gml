if (!mower_visible || is_undefined(mower_body) || mower_body == noone) exit;
// LawnMower::DrawShadow center is (x-7, y+47) on the daytime lawn.
var _env = variable_global_exists("pvz_lawn_environment_index") ? global.pvz_lawn_environment_index : 0;
var _shadow = (_env == 1 || _env == 3 || _env == 5) ? global.pvz_shadow2_sprite : global.pvz_shadow_sprite;
if (_shadow >= 0 && mower_state != "squished") {
    var _sw = sprite_get_width(_shadow);
    var _sh = sprite_get_height(_shadow);
    draw_sprite_ext(_shadow, 0, x - 7 - _sw * 0.5 - global.pvz_lawn_camera_x, y + 47 - _sh * 0.5, 1, 1, 0, c_white, 1);
}
pvz_lawn_reanim_draw_camera(mower_body, x + 6, y + 18, global.pvz_lawn_camera_x);
