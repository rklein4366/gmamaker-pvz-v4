var _camera_x = global.pvz_lawn_camera_x;
var _fade = clamp(1 - fx_age / max(1, fx_max_life), 0, 1);
// A little ground contact puff precedes and underlays the individual specks.
draw_set_alpha(0.24 * _fade);
draw_set_color(make_color_rgb(102, 73, 42));
draw_ellipse(x - _camera_x - 8, y - 2, x - _camera_x + 8, y + 3, false);
for (var _i = 0; _i < fx_particle_count; _i++) {
    var _part_fade = clamp(1 - fx_age / max(1, fx_particle_life[_i]), 0, 1);
    if (_part_fade <= 0) continue;
    var _r = fx_particle_radius[_i];
    draw_set_alpha(_part_fade);
    draw_set_color(fx_particle_color[_i]);
    draw_ellipse(fx_particle_x[_i] - _camera_x - _r, fx_particle_y[_i] - _r * 0.65, fx_particle_x[_i] - _camera_x + _r, fx_particle_y[_i] + _r * 0.65, false);
}
draw_set_alpha(1);
draw_set_color(c_white);
