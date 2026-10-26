var _ticks = global.pvz_lawn_steps;
repeat (_ticks) {
    x += pea_speed;
    life_ticks++;
    hit_target = noone;
    // Projectile uses type-specific hitboxes and source altitude; flying balloons and underground diggers are not hit by ordinary lawn peas.
    with (obj_zombie_base) {
        var _zr = pvz_lawn_zombie_hitbox(id);
        if (other.hit_target == noone && !dead && !intro_preview && !pvz_lawn_zombie_ignores_ground_collision(id)
            && !(zombie_kind == "balloon" && phase == "balloon_flying")
            && !(zombie_kind == "snorkel" && phase == "snorkel_swimming")
            && !(zombie_kind == "boss" && phase != "boss_head_down" && phase != "boss_head_spit" && phase != "boss_head_idle_after_spit")
            && (zombie_kind == "boss" || row == other.projectile_row)
            && other.x + 28 > _zr[0] && other.x < _zr[2] && other.y + 28 > _zr[1] && other.y < _zr[3]) other.hit_target = id;
    }
    if (hit_target != noone) {
        if (projectile_kind == "snowpea") {
            pvz_lawn_snowpea_debug("IMPACT CANDIDATE: projectile_id=" + string(id) + ", target_id=" + string(hit_target) + ", projectile_row=" + string(projectile_row) + ", target_row=" + string(hit_target.row) + ", target_kind=" + string(hit_target.zombie_kind) + ", target_dead=" + string(hit_target.dead));
        }
        // Projectile::PlayImpactSound: pails get shield-hit only; cones get plastic-hit then splat;
        // unarmored zombies get the randomized FOLEY_SPLAT variants.
        var _hit_kind = hit_target.zombie_kind;
        var _hit_armor = hit_target.armor_health;
        pvz_lawn_zombie_take_damage(hit_target, pea_damage);
        if (projectile_kind == "snowpea") {
            if (instance_exists(hit_target) && !hit_target.dead) {
                // Keep the normal hit flash from pvz_lawn_zombie_take_damage. Snow Pea applies
                // the chill tint separately; clearing the flash here made Snow Pea hits behave
                // differently from normal pea hits when the zombie was already chilled.
                // Zombie::Update decrements mChilledCounter; the original chilled duration is 1000 ticks.
                var _chill_before_hit = hit_target.chilled_countdown;
                if (_chill_before_hit <= 0) pvz_lawn_play_sound("frozen.ogg");
                hit_target.chilled_countdown = max(_chill_before_hit, 1000);
                pvz_lawn_snowpea_debug("CHILL APPLIED: zombie_id=" + string(hit_target) + ", kind=" + string(hit_target.zombie_kind) + ", previous_ticks=" + string(_chill_before_hit) + ", new_ticks=" + string(hit_target.chilled_countdown) + ", body_valid=" + string(!is_undefined(hit_target.body) && hit_target.body != noone));
                pvz_lawn_snowpea_debug("HIT FLASH PRESERVED: zombie_id=" + string(hit_target) + ", flash_ticks=" + string(hit_target.just_got_shot));
                // Do not set a persistent tint here. The zombie update/draw derives blue
                // solely from chilled_countdown and clears it when the slowdown expires.
            }
        }
        if (_hit_armor > 0 && (_hit_kind == "buckethead" || _hit_kind == "screendoor" || _hit_kind == "ducky_tube_buckethead" || _hit_kind == "football" || _hit_kind == "ladder" || _hit_kind == "bobsled_team")) {
            pvz_lawn_play_random_sound(["shieldhit.ogg", "shieldhit2.ogg"]);
        } else {
            if (_hit_armor > 0 && (_hit_kind == "conehead" || _hit_kind == "ducky_tube_conehead" || _hit_kind == "digger")) pvz_lawn_play_random_sound(["plastichit.ogg", "plastichit2.ogg"]);
            pvz_lawn_play_splat();
        }
        if (projectile_kind == "snowpea") {
            // Projectile::DoImpact uses the Snow Pea-specific splash sheet, not the ordinary green-pea splat.
            pvz_lawn_spawn_particle("SnowPeaSplat", x - 3, y + 12);
        } else {
            pvz_lawn_spawn_splat(x, y, hit_target);
        }
        instance_destroy();
        break;
    }
    if (x > room_width + 30 || life_ticks > 300) {
        if (projectile_kind == "snowpea") pvz_lawn_snowpea_debug("MISS / EXPIRED: projectile_id=" + string(id) + ", row=" + string(projectile_row) + ", age_ticks=" + string(life_ticks) + ", x=" + string(x) + ", no zombie overlap was found");
        instance_destroy();
        break;
    }
}
