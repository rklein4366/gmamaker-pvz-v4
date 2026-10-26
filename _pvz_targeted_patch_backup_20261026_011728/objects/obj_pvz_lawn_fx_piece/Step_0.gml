if (fx_kind == "charred_zombie") {
    repeat (global.pvz_lawn_steps) {
        if (!instance_exists(id)) break;
        if (is_undefined(fx_charred_reanim) || fx_charred_reanim == noone) { instance_destroy(); break; }
        fx_charred_reanim.x = x;
        fx_charred_reanim.y = y;
        fx_charred_reanim.update();
        fx_age++;
        if (fx_charred_finished_age < 0 && fx_charred_reanim.loop_count > 0) {
            fx_charred_finished_age = fx_age;
            fx_life = fx_age + 15;
        }
        if (fx_age >= fx_life) { instance_destroy(); break; }
    }
    exit;
}

if (fx_kind == "xml_emitter") {
    repeat (global.pvz_lawn_steps) {
        if (!instance_exists(id)) break;
        if (!is_struct(fx_xml_data)) { instance_destroy(); break; }
        var _xml_cfg = fx_xml_data;
        var _follow_active = variable_instance_exists(id, "fx_follow_id") && fx_follow_id != noone;
        if (_follow_active) {
            if (!instance_exists(fx_follow_id)) { instance_destroy(); break; }
            // ParticleSystem attachment follows the projectile origin; emitted snowflakes do not follow it.
            fx_xml_origin_x = fx_follow_id.x + 8.0;
            fx_xml_origin_y = fx_follow_id.y + 13.0;
            x = fx_xml_origin_x;
            y = fx_xml_origin_y;
        }
        if (fx_xml_age >= _xml_cfg.system_duration) {
            if (_follow_active && variable_instance_exists(id, "fx_loop_while_following") && fx_loop_while_following) {
                // Only effects explicitly marked continuous may restart when attached to a live object.
                fx_xml_age = 0;
                fx_xml_spawned = 0;
                fx_xml_spawn_accum = 0;
            } else {
                instance_destroy();
                break;
            }
        }
        fx_xml_age++;

        var _active_count = pvz_lawn_particle_count_children(id);
        var _spawn_count = 0;
        if (_xml_cfg.has_spawn_rate) {
            fx_xml_spawn_accum += _xml_cfg.spawn_rate * 0.01;
            _spawn_count = floor(fx_xml_spawn_accum);
            fx_xml_spawn_accum -= _spawn_count;
        }
        if (_active_count + _spawn_count < fx_xml_initial_active) {
            _spawn_count = fx_xml_initial_active - _active_count;
        }
        if (_xml_cfg.max_launched >= 0) {
            _spawn_count = min(_spawn_count, max(0, _xml_cfg.max_launched - fx_xml_spawned));
        }
        _spawn_count = clamp(_spawn_count, 0, 64);
        for (var _spawn_i = 0; _spawn_i < _spawn_count; _spawn_i++) {
            if (pvz_lawn_particle_emit(id)) fx_xml_spawned++;
        }
    }
    exit;
}

if (fx_parent_emitter != noone) {
    // TodParticleEmitter::UpdateParticle: fields update velocity before position; frames remain random/static unless animated by XML.
    repeat (global.pvz_lawn_steps) {
        if (!instance_exists(id)) break;
        if (fx_age >= fx_life) { instance_destroy(); break; }
        var _life_t = clamp(fx_age / max(1, fx_life - 1), 0.0, 1.0);
        var _friction_x = fx_friction_x;
        var _friction_y = fx_friction_y;
        if (fx_friction_x_keytime < 1.0) {
            _friction_x = _life_t < fx_friction_x_keytime
                ? lerp(fx_friction_x, fx_friction_x_end, _life_t / max(0.001, fx_friction_x_keytime))
                : fx_friction_x_end;
        }
        if (fx_friction_y_keytime < 1.0) {
            _friction_y = _life_t < fx_friction_y_keytime
                ? lerp(fx_friction_y, fx_friction_y_end, _life_t / max(0.001, fx_friction_y_keytime))
                : fx_friction_y_end;
        }
        if (!fx_grounded) {
            fx_vx *= clamp(1.0 - _friction_x, 0.0, 1.0);
            fx_vy *= clamp(1.0 - _friction_y, 0.0, 1.0);
            fx_vy += fx_gravity;
            x += fx_vx;
            y += fx_vy;
            if (fx_ground_enabled && y >= fx_ground_y && fx_vy > 0) {
                y = fx_ground_y;
                fx_vx *= fx_reflect;
                fx_vy = -fx_vy * fx_reflect;
                // An XML GroundConstraint with zero reflect is a resting contact, not a
                // zero-velocity particle that receives gravity again on the next tick.
                if (fx_reflect <= 0.001 || (abs(fx_vy) < 0.10 && abs(fx_vx) < 0.10)) {
                    fx_vx = 0;
                    fx_vy = 0;
                    fx_spin = 0;
                    fx_grounded = true;
                }
            }
        }
        fx_angle += fx_spin;
        fx_age++;
    }
    exit;
}
repeat (global.pvz_lawn_steps) {
    fx_age++;
    if (!fx_grounded) {
        x += fx_vx;
        y += fx_vy;
        if (fx_friction_x > 0) fx_vx *= clamp(1.0 - fx_friction_x, 0.0, 1.0);
        if (fx_friction_y > 0) fx_vy *= clamp(1.0 - fx_friction_y, 0.0, 1.0);
        fx_vy += fx_gravity; // Original acceleration field: XML Y=17 means +0.17 velocity per 10 ms tick.
        // Clamp a detached fragment once it reaches its GroundConstraint. The prior manual
        // approximation reflected velocity on every floor contact, causing a second full fall
        // and making heads begin spinning after landing. Keep launch spin in flight, then settle.
        if (fx_ground_enabled && y >= fx_ground_y && fx_vy > 0) {
            y = fx_ground_y;
            fx_vx = 0;
            fx_vy = 0;
            fx_spin = 0;
            fx_collision_spin_done = true;
            fx_spin_active_until = fx_age;
            fx_grounded = true;
        }
    }
    // Source launch spin is applied during flight only; settled parts remain still.
    if (!fx_grounded && fx_age <= fx_spin_active_until) {
        var _spin_fade = fx_spin_decay ? (1.0 - fx_age / max(1, fx_spin_active_until)) : 1.0;
        fx_angle += fx_spin * _spin_fade;
    }
    if (fx_age >= fx_life) { instance_destroy(); break; }
}
