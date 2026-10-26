if (!variable_instance_exists(id, "intro_preview")) intro_preview = false;
if (!variable_instance_exists(id, "row")) row = irandom(pvz_lawn_active_rows() - 1);
row = clamp(row, 0, pvz_lawn_active_rows() - 1);
y = pvz_lawn_row_y(row, x, -30);
pvz_lawn_zombie_init("digger");
