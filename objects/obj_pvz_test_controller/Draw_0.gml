draw_clear(make_color_rgb(69, 124, 48));
if (global.pvz_lawn_bg_sprite >= 0) {
    // PC Board::DrawBackdrop uses native-size art at (-BOARD_OFFSET_X, 0); apply Board.Move as camera translation.
    draw_sprite(global.pvz_lawn_bg_sprite, 0, -PVZ_BOARD_OFFSET_X - global.pvz_lawn_camera_x, 0);
} else {
    draw_set_color(make_color_rgb(73, 125, 48));
    draw_rectangle(0, 0, 800, 600, false);
}
// PoolEffect::PoolEffectDraw is a moving, three-layer 15x5 water mesh over background3.jpg.
pvz_lawn_draw_pool_effect();
// Board::DrawIce puts Zamboni's repeated frozen strip above the lawn/water and below game objects.
pvz_lawn_draw_zamboni_ice();
// Grid overlay and planting-cell highlight intentionally disabled.

// Board::DrawHouseDoorBottom: show the original interior when the winner starts entering the house.
if (global.pvz_lawn_lost_state != "" && global.pvz_lawn_door_interior_sprite >= 0) {
    draw_sprite(global.pvz_lawn_door_interior_sprite, 0, 114 - global.pvz_lawn_camera_x, 285);
}
