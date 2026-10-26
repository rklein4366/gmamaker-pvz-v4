if (fx_kind == "xml_emitter") exit;
var _alpha = fx_age >= fx_fade_start ? clamp((fx_life - fx_age) / max(1, fx_life - fx_fade_start), 0, 1) : 1;
var _scale_t = clamp(fx_age / max(1, fx_life - 1), 0, 1);
var _scale_key_t = clamp(fx_scale_keytime, 0.001, 1.0);
var _scale_interp_t = _scale_t < _scale_key_t ? _scale_t / _scale_key_t : 1.0;
var _draw_scale = lerp(fx_scale, fx_scale_end, _scale_interp_t);
// Multi-key ParticleScale tracks are evaluated segment by segment (e.g. SnowPeaPuff:
// .2 at 0%, .4 at 20%, .6 at 80%, .2 at 100%).
var _scale_curve_count = array_length(fx_scale_curve);
if (_scale_curve_count >= 2 && array_length(fx_scale_times) == _scale_curve_count) {
    if (_scale_t <= fx_scale_times[0]) {
        _draw_scale = fx_scale_curve[0];
    } else {
        var _scale_curve_resolved = false;
        for (var _scale_curve_i = 1; _scale_curve_i < _scale_curve_count; _scale_curve_i++) {
            var _scale_curve_right_t = fx_scale_times[_scale_curve_i];
            if (_scale_t <= _scale_curve_right_t) {
                var _scale_curve_left_t = fx_scale_times[_scale_curve_i - 1];
                var _scale_curve_span = max(0.001, _scale_curve_right_t - _scale_curve_left_t);
                var _scale_curve_u = clamp((_scale_t - _scale_curve_left_t) / _scale_curve_span, 0, 1);
                _draw_scale = lerp(fx_scale_curve[_scale_curve_i - 1], fx_scale_curve[_scale_curve_i], _scale_curve_u);
                _scale_curve_resolved = true;
                break;
            }
        }
        if (!_scale_curve_resolved) _draw_scale = fx_scale_curve[_scale_curve_count - 1];
    }
}
var _draw_alpha = clamp(_alpha * fx_alpha_mult, 0, 1);
if (fx_kind == "charred_zombie") {
    if (!is_undefined(fx_charred_reanim) && fx_charred_reanim != noone) {
        var _charred_alpha = fx_charred_finished_age >= 0 ? clamp((fx_life - fx_age) / 15.0, 0, 1) : 1.0;
        var _saved_charred_alpha = fx_charred_reanim.alpha;
        fx_charred_reanim.alpha = _charred_alpha;
        pvz_lawn_reanim_draw_camera(fx_charred_reanim, x, y, global.pvz_lawn_camera_x);
        fx_charred_reanim.alpha = _saved_charred_alpha;
    }
    exit;
}
var _rgb_t = clamp(fx_age / max(1, fx_life - 1), 0, 1);
var _red = _rgb_t < fx_color_r_keytime
    ? lerp(fx_color_r_start, fx_color_r_end, _rgb_t / max(0.001, fx_color_r_keytime))
    : fx_color_r_end;
var _green = _rgb_t < fx_color_g_keytime
    ? lerp(fx_color_g_start, fx_color_g_end, _rgb_t / max(0.001, fx_color_g_keytime))
    : fx_color_g_end;
var _blue = _rgb_t < fx_color_b_keytime
    ? lerp(fx_color_b_start, fx_color_b_end, _rgb_t / max(0.001, fx_color_b_keytime))
    : fx_color_b_end;
var _particle_color = make_color_rgb(round(clamp(_red, 0, 1) * 255), round(clamp(_green, 0, 1) * 255), round(clamp(_blue, 0, 1) * 255));
if (fx_sprite >= 0) {
    if (fx_parent_emitter != noone && array_length(fx_xml_sprites) > 0 && fx_xml_frame >= 0 && fx_xml_frame < array_length(fx_xml_sprites) && fx_xml_sprites[fx_xml_frame] >= 0) {
        draw_sprite_ext(fx_xml_sprites[fx_xml_frame], 0, x - global.pvz_lawn_camera_x, y, _draw_scale, _draw_scale, fx_angle, _particle_color, _draw_alpha);
    } else {
        draw_sprite_ext(fx_sprite, 0, x - global.pvz_lawn_camera_x, y, _draw_scale, _draw_scale, fx_angle, _particle_color, _draw_alpha);
    }
} else if (fx_kind == "cone") {
    draw_set_alpha(_draw_alpha);
    draw_set_color(make_color_rgb(232, 117, 34));
    draw_triangle(x - global.pvz_lawn_camera_x, y - 12, x - 8 - global.pvz_lawn_camera_x, y + 9, x + 8 - global.pvz_lawn_camera_x, y + 9, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
} else if (fx_kind == "nut") {
    // Small shell-colored fallback fragments for WallnutEatSmall.xml when its sheet is unavailable.
    draw_set_alpha(_draw_alpha);
    var _nut_x = x - global.pvz_lawn_camera_x;
    var _nut_a = degtorad(fx_angle);
    var _nut_dx = cos(_nut_a) * 4.0;
    var _nut_dy = sin(_nut_a) * 2.2;
    var _nut_tip_x = _nut_x + sin(_nut_a) * 2.6;
    var _nut_tip_y = y - cos(_nut_a) * 3.0;
    draw_set_color(make_color_rgb(142, 96, 54));
    draw_triangle(_nut_x - _nut_dx, y - _nut_dy, _nut_x + _nut_dx, y + _nut_dy, _nut_tip_x, _nut_tip_y, false);
    draw_set_color(make_color_rgb(82, 53, 31));
    draw_triangle(_nut_x - _nut_dx * 0.45, y - _nut_dy * 0.45, _nut_x + _nut_dx * 0.55, y + _nut_dy * 0.55, _nut_tip_x, _nut_tip_y, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
} else if (fx_kind == "bucket") {
    draw_set_alpha(_draw_alpha);
    draw_set_color(make_color_rgb(160, 164, 165));
    draw_rectangle(x - 8 - global.pvz_lawn_camera_x, y - 8, x + 8 - global.pvz_lawn_camera_x, y + 8, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
