if (projectile_kind == "basketball") {
    repeat (global.pvz_lawn_steps) {
        if (!instance_exists(id)) break;
        flight_ticks++;
        var _t = clamp(flight_ticks / 120.0, 0.0, 1.0);
        x = lerp(start_x, target_x, _t);
        // Projectile::ProjectileUpdate uses a lobbed arc; its source initial vertical velocity
        // is -7 with +0.115 gravity. Normalize the same up-then-down arc to the selected plant.
        y = lerp(start_y, target_y, _t) - sin(_t * pi) * 205.0;
        if (_t >= 1.0) {
            if (instance_exists(target_plant) && target_plant.plant_health > 0) {
                // gProjectileDefinition assigns PROJECTILE_BASKETBALL 75 damage.
                target_plant.plant_health -= 75;
                target_plant.eaten_flash_countdown = max(target_plant.eaten_flash_countdown, 25);
                if (target_plant.plant_health <= 0) pvz_lawn_zombie_remove_plant(target_plant);
            }
            instance_destroy();
            break;
        }
    }
    exit;
}

repeat (global.pvz_lawn_steps) {
    if (!instance_exists(id)) break;

    if (!is_undefined(body) && body != noone) {
        if (!projectile_form_finished && (body.loop_count > 0 || body.anim_time >= 1.0)) {
            projectile_form_finished = true;
            body.play("anim_role", ReanimLoop.LOOP, 0, 2.0);
        }

        // Zombie::UpdateBossFireball moves by the animated _ground track speed, not a
        // constant per-tick slide. Use the constant only if the asset has no _ground track.
        var _ball_speed = abs(pvz_lawn_ground_track_speed(body, projectile_speed));
        x -= _ball_speed;
        y = pvz_lawn_row_y(projectile_row, x + 75.0, -90.0);
        body.x = x;
        body.y = y;
        body.update();
    } else {
        // Safe fallback if the source Reanim asset could not be loaded.
        x -= projectile_speed * 0.47;
        y = pvz_lawn_row_y(projectile_row, x + 75.0, -90.0);
    }

    projectile_tick++;
    projectile_life--;

    // UpdateBossFireball emits the original persistent ground-trail particle at a 1-in-10
    // chance each logic tick, behind the moving ball. Ice uses Iceball_Trail instead.
    if (irandom(9) == 0) {
        var _trail_x = x + 100.0 + random_range(0.0, 20.0);
        var _trail_y = pvz_lawn_row_y(projectile_row, _trail_x - 40.0, 90.0) + random_range(-50.0, 0.0);
        pvz_lawn_spawn_particle(projectile_kind == "ice" ? "Iceball_Trail" : "Fireball_Trail", _trail_x, _trail_y);
    }

    // Zombie::SquishAllInSquare(ATTACKTYPE_DRIVE_OVER) removes ordinary plants underneath
    // the ball as it crosses the selected row. Spikeweed and Spikerock are source exceptions.
    var _impact_x = x + 75.0;
    if (variable_global_exists("pvz_lawn_grid") && _impact_x >= PVZ_GRID_X && _impact_x < PVZ_GRID_X + PVZ_COLS * PVZ_CELL_W) {
        var _col = clamp(floor((_impact_x - PVZ_GRID_X) / PVZ_CELL_W), 0, PVZ_COLS - 1);
        var _plant = global.pvz_lawn_grid[# _col, projectile_row];
        if (instance_exists(_plant)) {
            var _plant_kind = variable_instance_exists(_plant, "plant_kind") ? _plant.plant_kind : "";
            if (_plant_kind != "spikeweed" && _plant_kind != "spikerock") pvz_lawn_zombie_remove_plant(_plant);
        }
    }

    // Zombie::UpdateBossFireball also SquishMower()s any mower in its row whose X falls
    // inside [ballX, ballX+50]. Preserve the mower object and its original flattened pose.
    with (obj_pvz_lawn_mower) {
        if (row == other.projectile_row && mower_state != "squished"
            && x > other.x && x < other.x + 50.0) {
            mower_state = "squished";
            if (!variable_instance_exists(id, "mower_squished_counter")) mower_squished_counter = 500;
            else mower_squished_counter = 500;
            mower_body.scale_x = 0.85;
            mower_body.scale_y = 0.22;
            mower_body.x = x - 11.0;
            mower_body.y = y + 65.0;
        }
    }

    if (projectile_life <= 0 || x < -180.0) {
        if (!is_undefined(body) && body != noone) body.dead = true;
        instance_destroy();
        break;
    }
}
