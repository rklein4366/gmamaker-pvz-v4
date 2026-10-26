repeat (global.pvz_lawn_steps) {
    fx_age++;
    if (global.pvz_fx_splat >= 0) image_index = min(sprite_get_number(global.pvz_fx_splat) - 1, floor(fx_age / 3));
    if (fx_age >= fx_life) { instance_destroy(); break; }
}
