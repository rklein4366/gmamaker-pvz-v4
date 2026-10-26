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
    x -= projectile_speed;
    // Zombie::UpdateBossFireball follows GetPosYBasedOnRow(aPosX + 75, fireballRow) each tick.
    y = pvz_lawn_row_y(projectile_row, x + 75.0, -90);
    projectile_life--;
    body.x = x; body.y = y; body.update();
    // Zombie::UpdateBossFireball continuously squishes the cell under the moving ball
    // while the fire/ice reanimation continues across the entire row.
    var _impact_x = x + 75.0;
    if (variable_global_exists("pvz_lawn_grid") && _impact_x >= PVZ_GRID_X && _impact_x < PVZ_GRID_X + PVZ_COLS * PVZ_CELL_W) {
        var _col = clamp(floor((_impact_x - PVZ_GRID_X) / PVZ_CELL_W), 0, PVZ_COLS - 1);
        var _plant = global.pvz_lawn_grid[# _col, projectile_row];
        if (instance_exists(_plant)) {
            var _plant_kind = variable_instance_exists(_plant, "plant_kind") ? _plant.plant_kind : "";
            // SquishAllInSquare(ATTACKTYPE_DRIVE_OVER) deliberately skips Spikeweed and Spikerock.
            if (_plant_kind != "spikeweed" && _plant_kind != "spikerock") pvz_lawn_zombie_remove_plant(_plant);
        }
    }
    if (projectile_life <= 0 || x < -180) {
        instance_destroy();
        break;
    }
}
