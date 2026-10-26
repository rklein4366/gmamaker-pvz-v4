projectile_row = clamp(floor((y - PVZ_GRID_Y) / pvz_lawn_cell_height()), 0, pvz_lawn_active_rows() - 1);
if (!variable_instance_exists(id, "projectile_kind")) projectile_kind = "pea";
pea_damage = 20; // Projectile.cpp: PROJECTILE_PEA and PROJECTILE_SNOWPEA both deal 20 damage.
pea_speed = 3.33; // Projectile.cpp: UpdateNormalMotion advances peas by 3.33 px per source tick
life_ticks = 0;
depth = -y - 20;
// Projectile::ProjectileInitialize attaches PARTICLE_SNOWPEA_TRAIL to the moving Snow Pea.
if (projectile_kind == "snowpea") pvz_lawn_spawn_particle("SnowPeaTrail", x + 8, y + 13, id, true);
