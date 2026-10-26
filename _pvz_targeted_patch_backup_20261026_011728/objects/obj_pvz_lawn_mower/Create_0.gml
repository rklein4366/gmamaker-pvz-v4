// LawnMower::LawnMowerInitialize for the original daytime lawn mower.
if (!variable_instance_exists(id, "row")) row = 0;
row = clamp(row, 0, pvz_lawn_active_rows() - 1);
mower_state = "ready";
mower_visible = false;
y = pvz_lawn_row_y(row, x, 23);
chomp_counter = 0;
mower_body = new Reanim("LawnMower", x + 6, y + 18);
mower_body.loop_type = ReanimLoop.LOOP;
mower_body.play("anim_normal", ReanimLoop.LOOP, 0, 0.0);
mower_body.anim_rate = 0.0;
mower_body.scale_x = 0.85;
mower_body.scale_y = 0.85;
// Draw the mower above zombies in its lane, as requested; lower GameMaker depth is foreground.
depth = -y - 40;
