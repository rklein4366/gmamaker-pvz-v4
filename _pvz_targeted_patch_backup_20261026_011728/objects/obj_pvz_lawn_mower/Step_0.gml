// LawnMower::Update, using the project's 100 Hz source-compatible logic clock.
if (global.pvz_lawn_camera_pan_tick >= PVZ_CAMERA_PAN_LEFT_END
    && global.pvz_lawn_ready_set_plant_ticks >= (PVZ_READY_SET_PLANT_END - PVZ_READY_SET_PLANT_START)) {
    mower_visible = true;
}
if (!mower_visible || global.pvz_lawn_menu_open) exit;
var _mower_id = id;
repeat (global.pvz_lawn_steps) {
    if (!instance_exists(_mower_id)) break;
    if (_mower_id.mower_state == "squished") break;
    // LawnMower::Update checks every zombie, not just the nearest one, so a single mower can clear a group.
    with (obj_zombie_base) pvz_lawn_mower_try_hit(_mower_id, id);
    if (!instance_exists(_mower_id)) break;
    if (_mower_id.mower_state == "triggered") {
        var _mower_speed = 3.33;
        if (_mower_id.chomp_counter > 0) {
            _mower_id.chomp_counter--;
            // LawnMower::Update's CURVE_BOUNCE_SLOW_MIDDLE start-up ramp over 50 source ticks.
            var _curve_t = clamp(1.0 - _mower_id.chomp_counter / 50.0, 0.0, 1.0);
            _mower_speed = lerp(1.0, 3.33, _curve_t);
        }
        _mower_id.x += _mower_speed;
        _mower_id.y = pvz_lawn_row_y(_mower_id.row, _mower_id.x + 40, 23);
        _mower_id.depth = -_mower_id.y - 40; // Keep it in front of the zombie sprites after movement.
        _mower_id.mower_body.x = _mower_id.x + 6;
        _mower_id.mower_body.y = _mower_id.y + 18;
        _mower_id.mower_body.update();
        // WIDE_BOARD_WIDTH is 1040 in the wide source; removing its 240px extension gives 800px.
        if (_mower_id.x > room_width) {
            _mower_id.mower_body.dead = true;
            instance_destroy(_mower_id);
            break;
        }
    }
}
