var _ticks = global.pvz_lawn_steps;
repeat (_ticks) {
    if (collecting) {
        // Coin::UpdateCollected heads for the sun-bank at (5, 0), moving 1/21 per source tick.
        var _dest_x = 5 + global.pvz_lawn_camera_x; // Keep sun-bank target fixed on screen during board pan.
        var _dest_y = 0;
        var _dx = abs(x - _dest_x);
        var _dy = abs(y - _dest_y);
        if (x > _dest_x) x -= _dx / 21.0; else if (x < _dest_x) x += _dx / 21.0;
        if (y > _dest_y) y -= _dy / 21.0; else if (y < _dest_y) y += _dy / 21.0;
        collect_distance = sqrt(_dx * _dx + _dy * _dy);
        sun_scale = clamp(collect_distance * 0.05, 0.5, 1.0); // Coin::UpdateCollected / GetSunScale.
        if (collect_distance < 8.0) {
            global.pvz_lawn_sun += 25; // Coin::GetSunValue(COIN_SUN)
            instance_destroy();
            break;
        }
    } else if (!landed) {
        if (y + sun_vy < sun_ground_y) {
            y += sun_vy;
            x += sun_vx;
            if (sun_motion == "from_plant") sun_vy += 0.09; // Coin::UpdateFall gravity for plant drops.
        } else {
            landed = true;
            y = sun_ground_y;
            sun_vy = 0;
        }
    } else if (sun_fade_ticks > 0) {
        sun_fade_ticks--;
        if (sun_fade_ticks <= 0) { instance_destroy(); break; }
    } else {
        life_ticks--;
        if (life_ticks <= 0) sun_fade_ticks = 15; // Coin::StartFade(15), then UpdateFade.
    }
    body.x = x + 30;
    body.y = y + 30;
    body.scale_x = sun_scale;
    body.scale_y = sun_scale;
    body.alpha = sun_fade_ticks > 0 ? sun_fade_ticks / 15.0 : 1.0;
    body.update();
    depth = -y - 30; // Sort using the visible Reanim origin at y+30 as the sun falls or collects.
}
