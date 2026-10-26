if (!variable_instance_exists(id, "projectile_row")) projectile_row = 0;
if (!variable_instance_exists(id, "projectile_kind")) projectile_kind = "fire";
projectile_life = 850;
projectile_speed = 0.95;
body = undefined;
if (projectile_kind == "basketball") {
    if (!variable_instance_exists(id, "start_x")) start_x = x;
    if (!variable_instance_exists(id, "start_y")) start_y = y;
    if (!variable_instance_exists(id, "target_x")) target_x = x - 300;
    if (!variable_instance_exists(id, "target_y")) target_y = y;
    if (!variable_instance_exists(id, "target_plant")) target_plant = noone;
    flight_ticks = 0;
    return;
}
body = new Reanim(projectile_kind == "ice" ? "Zombie_boss_iceball" : "Zombie_boss_fireball", x, y);
body.play_all(ReanimLoop.LOOP);
body.anim_rate = 24.0;
