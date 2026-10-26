repeat (global.pvz_lawn_steps) {
    fx_age++;
    for (var _i = 0; _i < fx_particle_count; _i++) {
        if (fx_age >= fx_particle_life[_i]) continue;
        fx_particle_x[_i] += fx_particle_vx[_i];
        fx_particle_y[_i] += fx_particle_vy[_i];
        fx_particle_vy[_i] += fx_particle_gravity[_i];
        fx_particle_vx[_i] *= 0.985;
    }
    if (fx_age >= fx_max_life) { instance_destroy(); break; }
}
