if (!variable_instance_exists(id, "sun_motion")) sun_motion = "from_plant";
picked = false;
collecting = false;
landed = false;
collect_distance = 0;
sun_scale = 1.0; // COIN_SUN is full size whether spawned by sky or Sunflower.
sun_fade_ticks = 0;
if (sun_motion == "sky") {
    sun_vx = 0.0;
    sun_vy = 0.67; // Coin::CoinInitialize COIN_MOTION_FROM_SKY
    sun_ground_y = irandom_range(300, 549); // Rand(250) + 300
} else {
    sun_vx = -0.4 + random(0.8); // -0.4 + RandRangeFloat(0, 0.8)
    sun_vy = -1.7 - random(1.7); // -1.7 - RandRangeFloat(0, 1.7)
    sun_ground_y = y + 15 + irandom(19); // mPosY + 15 + Rand(20)
}
life_ticks = 750; // Coin::GetDisappearTime normal sun lifetime after it reaches the ground.
body = new Reanim("Sun", x + 30, y + 30);
body.scale_x = sun_scale;
body.scale_y = sun_scale;
body.play_all(ReanimLoop.LOOP);
depth = -y - 30; // Sort by the visible sun Reanim origin at (x+30, y+30), not the object's top-left.
