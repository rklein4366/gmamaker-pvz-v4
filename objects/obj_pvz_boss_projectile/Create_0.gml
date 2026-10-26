if (!variable_instance_exists(id, "projectile_row")) projectile_row = 0;
if (!variable_instance_exists(id, "projectile_kind")) projectile_kind = "fire";
projectile_life = 3000;
projectile_speed = 0.95; // Fallback only: normal motion comes from the original Reanim _ground track.
body = undefined;
projectile_tick = 0;
projectile_trail_tick = 0;
projectile_form_finished = false;
if (projectile_kind == "basketball") {
    if (!variable_instance_exists(id, "start_x")) start_x = x;
    if (!variable_instance_exists(id, "start_y")) start_y = y;
    if (!variable_instance_exists(id, "target_x")) target_x = x - 300;
    if (!variable_instance_exists(id, "target_y")) target_y = y;
    if (!variable_instance_exists(id, "target_plant")) target_plant = noone;
    flight_ticks = 0;
    return;
}

// Zombie::BossHeadSpitContact: form once at 16 FPS, then the source's slow anim_role
// drives the actual ball speed through GetTrackVelocity("_ground").
body = new Reanim(projectile_kind == "ice" ? "Zombie_boss_iceball" : "Zombie_boss_fireball", x, y);
body.play("anim_form", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 16.0);
body.anim_rate = 16.0;
body.x = x;
body.y = y;

// The PC game renders the glow/highlight tracks additively instead of as white opaque art.
for (var _ti = 0; _ti < body.track_count; _ti++) {
    var _track_name = string_lower(body.def.tracks[_ti].name);
    if (projectile_kind == "ice") {
        if (_track_name == "ice_highlight") body.track_render_group[_ti] = 7;
    } else if (_track_name == "additive" || _track_name == "superglow") {
        body.track_render_group[_ti] = 7;
    }
}
depth = -y - 15;
