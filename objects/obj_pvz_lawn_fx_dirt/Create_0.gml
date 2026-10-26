// Source PARTICLE_PLANTING: a very short upward dirt burst at Board::DoPlantingEffects' origin.
fx_age = 0;
fx_particle_count = 9;
fx_particle_x = array_create(fx_particle_count, x);
fx_particle_y = array_create(fx_particle_count, y);
fx_particle_vx = array_create(fx_particle_count, 0);
fx_particle_vy = array_create(fx_particle_count, 0);
fx_particle_gravity = array_create(fx_particle_count, 0.13);
fx_particle_life = array_create(fx_particle_count, 24);
fx_particle_radius = array_create(fx_particle_count, 2);
fx_particle_color = array_create(fx_particle_count, make_color_rgb(111, 79, 48));
fx_max_life = 0;
for (var _i = 0; _i < fx_particle_count; _i++) {
    fx_particle_x[_i] = x + random_range(-3, 3);
    fx_particle_y[_i] = y + random_range(-2, 2);
    fx_particle_vx[_i] = random_range(-1.8, 1.8);
    // GameMaker's positive Y points down; negative velocity gives the short upward spray.
    fx_particle_vy[_i] = random_range(-2.5, -0.6);
    fx_particle_gravity[_i] = random_range(0.09, 0.17);
    fx_particle_life[_i] = irandom_range(20, 31);
    fx_particle_radius[_i] = random_range(1.1, 2.8);
    var _earth = choose(0, 1, 2, 3);
    if (_earth == 0) fx_particle_color[_i] = make_color_rgb(95, 65, 38);
    else if (_earth == 1) fx_particle_color[_i] = make_color_rgb(125, 88, 51);
    else if (_earth == 2) fx_particle_color[_i] = make_color_rgb(145, 105, 64);
    else fx_particle_color[_i] = make_color_rgb(79, 57, 35);
    fx_max_life = max(fx_max_life, fx_particle_life[_i]);
}
// Keep the dust above the lawn objects but beneath the HUD overlay.
depth = -99999;
