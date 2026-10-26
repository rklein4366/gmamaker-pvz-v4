param(
    [string]$ProjectRoot = (Get-Location).Path
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$Yyp = Join-Path $ProjectRoot 'PvZ.yyp'
$RuntimePath = Join-Path $ProjectRoot 'scripts\scr_pvz_lawn_runtime\scr_pvz_lawn_runtime.gml'
$FxStepPath = Join-Path $ProjectRoot 'objects\obj_pvz_lawn_fx_piece\Step_0.gml'
$FxCreatePath = Join-Path $ProjectRoot 'objects\obj_pvz_lawn_fx_piece\Create_0.gml'
if (-not (Test-Path -LiteralPath $Yyp)) { throw "PvZ.yyp was not found in '$ProjectRoot'. Enter the project folder, not the .yyp filename." }
foreach ($p in @($RuntimePath, $FxStepPath, $FxCreatePath)) {
    if (-not (Test-Path -LiteralPath $p)) { throw "Required source file was not found: $p" }
}

$BackupRoot = Join-Path $ProjectRoot ("_pvz_boss_low_health_death_v5_1_backup_" + (Get-Date -Format 'yyyyMMdd_HHmmss'))
function Backup-File([string]$FullPath, [string]$RelativePath) {
    $destination = Join-Path $BackupRoot $RelativePath
    $directory = Split-Path -Parent $destination
    if (-not (Test-Path -LiteralPath $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
    Copy-Item -LiteralPath $FullPath -Destination $destination -Force
}
function Replace-Once([string]$Source, [string]$Old, [string]$New, [string]$Label) {
    $Old = $Old.Replace('`n', "`n")
    $New = $New.Replace('`n', "`n")
    $count = ([regex]::Matches($Source, [regex]::Escape($Old))).Count
    if ($count -ne 1) { throw "Expected one match for '$Label', found $count. No project source was written. Check that you selected the correct project. Backup folder will be created only after validation." }
    $index = $Source.IndexOf($Old, [StringComparison]::Ordinal)
    return $Source.Substring(0, $index) + $New + $Source.Substring($index + $Old.Length)
}
function Write-Utf8NoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

$runtime = [System.IO.File]::ReadAllText($RuntimePath) -replace "`r`n", "`n"
$fxStep = [System.IO.File]::ReadAllText($FxStepPath) -replace "`r`n", "`n"
$fxCreate = [System.IO.File]::ReadAllText($FxCreatePath) -replace "`r`n", "`n"
$origRuntime = $runtime; $origFxStep = $fxStep; $origFxCreate = $fxCreate

# 1. Source-matched damage stages, head-following smoke, <10% pulse/explosion, and boss death helpers.
$helper = @'
/// PVZ_BOSS_LOW_HEALTH_DEATH_V5
/// Original Zombie.cpp equivalents: GetBodyDamageIndex, TakeBodyDamage, ApplyBossSmokeParticles,
/// Draw (BOSS_FLASH_HEALTH_FRACTION), BossStartDeath, BossDie and PlayDeathAnim.
function pvz_lawn_boss_set_damage_sprite(_boss, _track_name, _image_path) {
    if (!instance_exists(_boss) || is_undefined(_boss.body) || _boss.body == noone) return;
    var _track = _boss.body.find_track(_track_name);
    if (_track < 0) return;
    var _image = _image_path == "" ? -1 : reanim_get_part_sprite(_image_path);
    _boss.body.track_sprite_override[_track] = _image;
}

function pvz_lawn_boss_stop_smoke_emitters(_boss) {
    if (!instance_exists(_boss)) return;
    var _boss_id = _boss.id;
    for (var _i = instance_number(obj_pvz_lawn_fx_piece) - 1; _i >= 0; _i--) {
        var _fx = instance_find(obj_pvz_lawn_fx_piece, _i);
        if (_fx == noone || !variable_instance_exists(_fx, "fx_kind")) continue;
        if (_fx.fx_kind == "xml_emitter" && variable_instance_exists(_fx, "fx_boss_smoke")
            && _fx.fx_boss_smoke && variable_instance_exists(_fx, "fx_follow_id") && _fx.fx_follow_id == _boss_id) {
            _fx.fx_loop_while_following = false;
        }
    }
}

function pvz_lawn_boss_start_smoke(_boss, _include_third) {
    if (!instance_exists(_boss) || is_undefined(_boss.body) || _boss.body == noone) return;
    // ApplyBossSmokeParticles first cross-fades the old attached smoke systems, then creates two replacements.
    pvz_lawn_boss_stop_smoke_emitters(_boss);
    pvz_lawn_spawn_particle("ZamboniSmoke", _boss.x, _boss.y, _boss, true, "Boss_head", 120.0, 30.0);
    pvz_lawn_spawn_particle("ZamboniSmoke", _boss.x, _boss.y, _boss, true, "Boss_head", 205.0, 58.0);
    if (_include_third) pvz_lawn_spawn_particle("ZamboniSmoke", _boss.x, _boss.y, _boss, true, "Boss_head", 193.0, 27.0);
}

function pvz_lawn_boss_stop_trail_effects() {
    for (var _i = instance_number(obj_pvz_lawn_fx_piece) - 1; _i >= 0; _i--) {
        var _fx = instance_find(obj_pvz_lawn_fx_piece, _i);
        if (_fx == noone || !variable_instance_exists(_fx, "fx_kind") || _fx.fx_kind != "xml_emitter") continue;
        var _effect = variable_instance_exists(_fx, "fx_xml_effect_name") ? string_lower(_fx.fx_xml_effect_name) : "";
        if (_effect != "fireball_trail" && _effect != "iceball_trail") continue;
        var _emitter_id = _fx.id;
        for (var _p = instance_number(obj_pvz_lawn_fx_piece) - 1; _p >= 0; _p--) {
            var _child = instance_find(obj_pvz_lawn_fx_piece, _p);
            if (_child != noone && variable_instance_exists(_child, "fx_parent_emitter") && _child.fx_parent_emitter == _emitter_id) {
                instance_destroy(_child);
            }
        }
        if (instance_exists(_emitter_id)) instance_destroy(_emitter_id);
    }
}

function pvz_lawn_boss_spawn_fireball_death(_x, _y) {
    // BossDestroyFireball creates six original REANIM_JALAPENO_FIRE effects around the extinguished fireball.
    for (var _i = 0; _i < 6; _i++) {
        var _angle = 360.0 * _i / 6.0 + 90.0;
        var _fx_x = _x + sin(degtorad(_angle)) * 60.0;
        var _fx_y = _y + cos(degtorad(_angle)) * 60.0;
        var _fire = new Reanim("fire", _fx_x, _fx_y);
        if (is_undefined(_fire.def) || _fire.def == undefined || !_fire.track_exists("anim_flame")) continue;
        _fire.play("anim_flame", ReanimLoop.PLAY_ONCE_FULL_LAST_FRAME, 0, random_range(20.0, 25.0));
        _fire.anim_time = 0.2;
        var _fire_fx = instance_create_layer(_fx_x, _fx_y, "Instances", obj_pvz_lawn_fx_piece, {
            fx_sprite: -1,
            fx_kind: "charred_zombie",
            fx_life: 120,
            fx_age: 0,
            fx_fade_start: 105,
            fx_charred_reanim: _fire,
            fx_charred_finished_age: -1
        });
        if (instance_exists(_fire_fx)) _fire_fx.depth = -400000;
    }
}

function pvz_lawn_boss_destroy_projectiles() {
    pvz_lawn_boss_stop_trail_effects();
    for (var _i = instance_number(obj_pvz_boss_projectile) - 1; _i >= 0; _i--) {
        var _projectile = instance_find(obj_pvz_boss_projectile, _i);
        if (_projectile == noone || !variable_instance_exists(_projectile, "projectile_kind")) continue;
        var _kind = string_lower(_projectile.projectile_kind);
        if (_kind == "fire") {
            pvz_lawn_boss_spawn_fireball_death(_projectile.x + 80.0, _projectile.y + 40.0);
            instance_destroy(_projectile);
        } else if (_kind == "ice") {
            pvz_lawn_spawn_particle("IceBallDeath", _projectile.x + 80.0, _projectile.y + 80.0);
            instance_destroy(_projectile);
        }
        // Catapult basketball projectiles are not Zomboss fireballs and are left alone.
    }
}

function pvz_lawn_boss_fade_music() {
    if (!variable_global_exists("pvz_lawn_music_instances")) return;
    var _live = [];
    for (var _i = 0; _i < array_length(global.pvz_lawn_music_instances); _i++) {
        var _handle = global.pvz_lawn_music_instances[_i];
        if (_handle >= 0 && audio_is_playing(_handle)) {
            audio_sound_gain(_handle, 0.0, 200);
            array_push(_live, _handle);
        }
    }
    global.pvz_lawn_music_instances = _live;
}

function pvz_lawn_boss_die_cleanup(_boss) {
    if (!instance_exists(_boss)) return;
    if (variable_instance_exists(_boss, "boss_death_cleanup_done") && _boss.boss_death_cleanup_done) return;
    _boss.boss_death_cleanup_done = true;
    pvz_lawn_boss_stop_smoke_emitters(_boss);
    pvz_lawn_boss_destroy_projectiles();
    pvz_lawn_boss_fade_music();
    // Zombie::BossDie calls DieWithLoot on every other live zombie and removes board cold effects.
    var _boss_id = _boss.id;
    for (var _i = instance_number(obj_zombie_base) - 1; _i >= 0; _i--) {
        var _z = instance_find(obj_zombie_base, _i);
        if (_z == noone || _z.id == _boss_id) continue;
        if (variable_instance_exists(_z, "chilled_countdown")) _z.chilled_countdown = 0;
        if (variable_instance_exists(_z, "body") && !is_undefined(_z.body) && _z.body != noone) {
            pvz_lawn_reanim_set_tint(_z.body, false, c_white);
        }
        if (!variable_instance_exists(_z, "dead") || !_z.dead) pvz_lawn_zombie_die(_z);
    }
    if (variable_instance_exists(_boss, "chilled_countdown")) _boss.chilled_countdown = 0;
}

function pvz_lawn_boss_update_degradation(_boss) {
    if (!instance_exists(_boss) || !variable_instance_exists(_boss, "zombie_kind") || _boss.zombie_kind != "boss") return;
    if (is_undefined(_boss.body) || _boss.body == noone || _boss.dead) return;
    if (!variable_instance_exists(_boss, "body_health") || !variable_instance_exists(_boss, "body_max_health")) return;
    if (!variable_instance_exists(_boss, "boss_critical_effect_played")) _boss.boss_critical_effect_played = false;
    if (!variable_instance_exists(_boss, "boss_death_pending")) _boss.boss_death_pending = false;
    if (!variable_instance_exists(_boss, "boss_death_started")) _boss.boss_death_started = false;
    if (!variable_instance_exists(_boss, "boss_death_cleanup_done")) _boss.boss_death_cleanup_done = false;
    if (!variable_instance_exists(_boss, "boss_smoke_stage_started")) _boss.boss_smoke_stage_started = false;

    var _max_health = max(1.0, _boss.body_max_health);
    // Zombie::GetBodyDamageIndex: stage 1 below 4/5 health; stage 2 below 1/2 health.
    var _stage = (_boss.body_health < _max_health / 2.0) ? 2 : ((_boss.body_health < _max_health * 4.0 / 5.0) ? 1 : 0);
    if (_stage != _boss.body_damage_index) {
        _boss.body_damage_index = _stage;
        if (_stage == 1) {
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_head", "reanim/Zombie_boss_head_damage1.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_jaw", "reanim/Zombie_boss_jaw_damage1.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_outerarm_hand", "reanim/Zombie_boss_outerarm_hand_damage1.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_outerarm_thumb2", "reanim/Zombie_boss_outerarm_thumb_damage1.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_innerleg_foot", "reanim/Zombie_boss_foot_damage1.png");
        } else if (_stage == 2) {
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_head", "reanim/Zombie_boss_head_damage2.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_jaw", "reanim/Zombie_boss_jaw_damage2.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_outerarm_hand", "reanim/Zombie_boss_outerarm_hand_damage2.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_outerarm_thumb2", "reanim/Zombie_boss_outerarm_thumb_damage2.png");
            pvz_lawn_boss_set_damage_sprite(_boss, "Boss_outerleg_foot", "reanim/Zombie_boss_foot_damage2.png");
            _boss.boss_smoke_stage_started = true;
            pvz_lawn_boss_start_smoke(_boss, false);
        }
    }

    // Zombie::TakeBodyDamage: critical explosion, small explosion Foley, and third smoke system below 10% HP.
    if (_boss.body_health < _max_health / 10.0 && !_boss.boss_critical_effect_played) {
        _boss.boss_critical_effect_played = true;
        pvz_lawn_spawn_particle("BossExplosion", 770.0, 260.0);
        pvz_lawn_play_sound("explosion.ogg");
        pvz_lawn_boss_start_smoke(_boss, true);
    }
}

function pvz_lawn_boss_play_driver_death(_boss) {
    if (!instance_exists(_boss) || is_undefined(_boss.body) || _boss.body == noone) return;
    var _track = _boss.body.find_track("Boss_head2");
    if (_track < 0) return;
    for (var _i = 0; _i < array_length(_boss.body.attached[_track]); _i++) {
        var _driver = _boss.body.attached[_track][_i];
        if (!is_undefined(_driver) && _driver != noone && _driver.def != undefined && _driver.track_exists("anim_death")) {
            _driver.play("anim_death", ReanimLoop.PLAY_ONCE_AND_HOLD, 20, 18.0);
        }
    }
}

function pvz_lawn_boss_begin_death(_boss) {
    if (!instance_exists(_boss) || is_undefined(_boss.body) || _boss.body == noone || _boss.dead) return;
    if (!variable_instance_exists(_boss, "boss_death_pending")) _boss.boss_death_pending = true;
    if (!variable_instance_exists(_boss, "boss_death_started")) _boss.boss_death_started = false;
    if (_boss.boss_death_started) return;
    _boss.boss_death_pending = true;
    _boss.boss_death_started = true;
    _boss.body_health = max(1, _boss.body_health);
    _boss.eating = false;
    _boss.target_plant = noone;
    _boss.bite_ticks = 0;
    _boss.phase = "boss_head_leave";
    _boss.body.play("anim_head_leave", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 24.0);
    _boss.special_counter = max(1, round(_boss.body.frame_count / 24.0 * 100.0));
    _boss.boss_head_leave_thump1 = false;
    _boss.boss_head_leave_thump2 = false;
    // Zombie::BossStartDeath: the top-layer boss explosion and both original death Foley sounds.
    pvz_lawn_spawn_particle("BossExplosion", 700.0, 150.0);
    pvz_lawn_play_sound("bossexplosion.ogg");
    pvz_lawn_play_sound("gargantudeath.ogg");
    pvz_lawn_boss_die_cleanup(_boss);
}

function pvz_lawn_boss_finish_death(_boss) {
    if (!instance_exists(_boss) || is_undefined(_boss.body) || _boss.body == noone || _boss.dead) return;
    pvz_lawn_boss_die_cleanup(_boss);
    // Zombie::PlayDeathAnim for ZOMBIE_BOSS: body and attached Dr. Edgar driver both use anim_death at 18 FPS.
    _boss.body.play("anim_death", ReanimLoop.PLAY_ONCE_AND_HOLD, 20, 18.0);
    pvz_lawn_boss_play_driver_death(_boss);
    _boss.dead = true;
    _boss.phase = "dying";
    _boss.fade_ticks = -1;
    _boss.death_ticks = max(35, ceil(_boss.body.frame_count / 18.0 * 100.0) + 20);
    _boss.death_sound_played = false; // Keep the source-timed falling Foley if the imported death clip reaches its event.
    _boss.eating = false;
    _boss.target_plant = noone;
    _boss.bite_ticks = 0;
}

'@
$bodyStageSignature = 'function pvz_lawn_zombie_update_body_damage_stage(_zid) {'
if (-not $runtime.Contains('PVZ_BOSS_LOW_HEALTH_DEATH_V5')) {
    $oldHelperIndex = -1
    foreach ($marker in @('/// PVZ_BOSS_DEGRADATION_STAGES_V1','/// PVZ_BOSS_DEGRADATION_STAGES_V2','/// PVZ_BOSS_DEGRADATION_STAGES_V3','/// PVZ_BOSS_DEGRADATION_STAGES_V4')) {
        $candidate = $runtime.IndexOf($marker, [StringComparison]::Ordinal)
        if ($candidate -ge 0 -and ($oldHelperIndex -lt 0 -or $candidate -lt $oldHelperIndex)) { $oldHelperIndex = $candidate }
    }
    $stageIndex = $runtime.IndexOf($bodyStageSignature, [StringComparison]::Ordinal)
    if ($stageIndex -lt 0) { throw 'Could not find the zombie body-damage-stage function.' }
    if ($oldHelperIndex -ge 0 -and $stageIndex -gt $oldHelperIndex) {
        $runtime = $runtime.Substring(0, $oldHelperIndex) + $helper + $runtime.Substring($stageIndex)
    } else {
        $runtime = Replace-Once $runtime $bodyStageSignature ($helper + $bodyStageSignature) 'insert source-matched boss effects/death helpers'
    }
}

# If this is the base source rather than v4, route the damage-stage helper to the boss-specific implementation.
if (-not $runtime.Contains('PVZ_BOSS_DAMAGE_STAGE_DISPATCH_V3')) {
    $oldStageEntry = @'
function pvz_lawn_zombie_update_body_damage_stage(_zid) {
    if (!instance_exists(_zid) || is_undefined(_zid.body) || _zid.body == noone) return;
    if (_zid.zombie_kind == "catapult") pvz_lawn_zombie_update_catapult_visuals(_zid);
    with (_zid) {
        if (zombie_kind == "boss") exit;
'@
    $newStageEntry = @'
function pvz_lawn_zombie_update_body_damage_stage(_zid) {
    if (!instance_exists(_zid) || is_undefined(_zid.body) || _zid.body == noone) return;
    // PVZ_BOSS_DAMAGE_STAGE_DISPATCH_V3: keep Zomboss on its source-specific 80% / 50% stages.
    if (_zid.zombie_kind == "boss") { pvz_lawn_boss_update_degradation(_zid); return; }
    if (_zid.zombie_kind == "catapult") pvz_lawn_zombie_update_catapult_visuals(_zid);
    with (_zid) {
'@
    $runtime = Replace-Once $runtime $oldStageEntry $newStageEntry 'route Zomboss into source-matched damage stages'
}

# Add custom track-following support to the existing particle helper without changing older call sites.
# Match the declaration structurally instead of assuming one exact whitespace/parameter-list spelling.
if (-not $runtime.Contains('PVZ_BOSS_SMOKE_TRACK_FOLLOW_V1')) {
    $signaturePattern = '(?m)^(?<prefix>[ \t]*function\s+pvz_lawn_spawn_particle\s*\()(?<params>[^)]*)(?<suffix>\)\s*\{)'
    $signatureMatch = [regex]::Match($runtime, $signaturePattern)
    if (-not $signatureMatch.Success) {
        throw "Could not locate the pvz_lawn_spawn_particle function declaration. No project source was written."
    }

    $parameterText = $signatureMatch.Groups['params'].Value
    foreach ($requiredParameter in @('_name', '_x', '_y', '_follow_id', '_loop_while_following')) {
        if (-not [regex]::IsMatch($parameterText, "(?:^|,)\s*$([regex]::Escape($requiredParameter))\b")) {
            throw "Found pvz_lawn_spawn_particle, but its parameter list does not contain '$requiredParameter'. No project source was written. Header: $($signatureMatch.Value)"
        }
    }

    $newParameterText = $parameterText.TrimEnd()
    $optionalParameters = @(
        @{ Name = '_follow_track'; Text = '_follow_track = ""' },
        @{ Name = '_follow_offset_x'; Text = '_follow_offset_x = 0.0' },
        @{ Name = '_follow_offset_y'; Text = '_follow_offset_y = 0.0' }
    )
    foreach ($parameter in $optionalParameters) {
        if (-not [regex]::IsMatch($newParameterText, "(?:^|,)\s*$([regex]::Escape($parameter.Name))\b")) {
            if ($newParameterText.Length -gt 0) { $newParameterText += ', ' }
            $newParameterText += $parameter.Text
        }
    }

    $newHeader = $signatureMatch.Groups['prefix'].Value + $newParameterText + $signatureMatch.Groups['suffix'].Value + ' // PVZ_BOSS_SMOKE_TRACK_FOLLOW_V1'
    $runtime = $runtime.Substring(0, $signatureMatch.Index) + $newHeader + $runtime.Substring($signatureMatch.Index + $signatureMatch.Length)

    # Add missing emitter metadata immediately after fx_xml_data. Keep any fields already present.
    $signatureAfterEdit = [regex]::Match($runtime, '(?m)^[ \t]*function\s+pvz_lawn_spawn_particle\s*\(')
    $returnMarker = 'return _started;'
    $returnIndex = $runtime.IndexOf($returnMarker, $signatureAfterEdit.Index, [StringComparison]::Ordinal)
    if ($returnIndex -lt 0) { throw 'Could not find the end of pvz_lawn_spawn_particle while adding emitter metadata. No project source was written.' }
    $functionText = $runtime.Substring($signatureAfterEdit.Index, ($returnIndex + $returnMarker.Length) - $signatureAfterEdit.Index)
    $dataLinePattern = '(?m)^(?<indent>[ \t]*)fx_xml_data\s*:\s*_cfg\s*,[ \t]*$'
    $dataLineMatches = [regex]::Matches($functionText, $dataLinePattern)
    if ($dataLineMatches.Count -ne 1) {
        throw "Expected one fx_xml_data: _cfg, property inside pvz_lawn_spawn_particle, found $($dataLineMatches.Count). No project source was written."
    }

    $dataLine = $dataLineMatches[0]
    $indent = $dataLine.Groups['indent'].Value
    $properties = @(
        @{ Name = 'fx_xml_effect_name'; Text = 'fx_xml_effect_name: string_lower(_name),' },
        @{ Name = 'fx_follow_track'; Text = 'fx_follow_track: _follow_track,' },
        @{ Name = 'fx_follow_offset_x'; Text = 'fx_follow_offset_x: _follow_offset_x,' },
        @{ Name = 'fx_follow_offset_y'; Text = 'fx_follow_offset_y: _follow_offset_y,' },
        @{ Name = 'fx_boss_smoke'; Text = 'fx_boss_smoke: (_follow_id != noone && _follow_track == "Boss_head" && string_lower(_name) == "zombanismoke"),' }
    )
    $linesToAdd = @()
    foreach ($property in $properties) {
        if (-not [regex]::IsMatch($functionText, "(?m)^[ \t]*$([regex]::Escape($property.Name))\s*:")) {
            $linesToAdd += ($indent + $property.Text)
        }
    }
    if ($linesToAdd.Count -gt 0) {
        $expandedDataLine = $dataLine.Value + "`n" + ($linesToAdd -join "`n")
        $functionText = $functionText.Substring(0, $dataLine.Index) + $expandedDataLine + $functionText.Substring($dataLine.Index + $dataLine.Length)
        $runtime = $runtime.Substring(0, $signatureAfterEdit.Index) + $functionText + $runtime.Substring($signatureAfterEdit.Index + (($returnIndex + $returnMarker.Length) - $signatureAfterEdit.Index))
    }
}

# Fade music handles on BossDie, matching the original mMusic->FadeOut(200).
if (-not $runtime.Contains('PVZ_BOSS_MUSIC_TRACK_V1')) {
    $oldPlay = '    var _instance = audio_play_sound(_stream, _priority, false);'
    $newPlay = @'
    var _instance = audio_play_sound(_stream, _priority, false);
    // PVZ_BOSS_MUSIC_TRACK_V1: retain handles for source-style BossDie music fade-out.
    if (_is_music) {
        if (!variable_global_exists("pvz_lawn_music_instances")) global.pvz_lawn_music_instances = [];
        var _music_live = [];
        for (var _music_i = 0; _music_i < array_length(global.pvz_lawn_music_instances); _music_i++) {
            var _music_handle = global.pvz_lawn_music_instances[_music_i];
            if (_music_handle >= 0 && audio_is_playing(_music_handle)) array_push(_music_live, _music_handle);
        }
        array_push(_music_live, _instance);
        global.pvz_lawn_music_instances = _music_live;
    }
'@
    $runtime = Replace-Once $runtime $oldPlay $newPlay 'track playing music handles for boss death fade'
}

# Make lethal boss damage follow BossStartDeath -> head leave -> body and driver death animations.
if (-not $runtime.Contains('PVZ_BOSS_STAGED_DEATH_V1')) {
    $oldDamageBlock = @'
        if (_remain > 0) body_health -= _remain;
        pvz_lawn_zombie_update_body_damage_stage(id);
        if (has_arm && body_health > 0 && body_health < body_max_health * 2 / 3) pvz_lawn_zombie_lose_arm(id);
        if (has_head && body_health < body_max_health / 3) pvz_lawn_zombie_lose_head(id);
        if (body_health <= 0) {
            if (_no_body) pvz_lawn_zombie_die_no_body(id);
            else pvz_lawn_zombie_die(id);
        }
'@
    $newDamageBlock = @'
        if (_remain > 0) body_health -= _remain;
        // Zombie::TakeBodyDamage clamps Zomboss lethal health to one and lets UpdateBoss finish its current head-down sequence.
        if (zombie_kind == "boss" && body_health <= 0) {
            body_health = 1;
            boss_death_pending = true;
        }
        pvz_lawn_zombie_update_body_damage_stage(id);
        // Zombie::CanLoseBodyParts explicitly excludes ZOMBIE_BOSS, even at the one-health death sentinel.
        if (zombie_kind != "boss" && has_arm && body_health > 0 && body_health < body_max_health * 2 / 3) pvz_lawn_zombie_lose_arm(id);
        if (zombie_kind != "boss" && has_head && body_health < body_max_health / 3) pvz_lawn_zombie_lose_head(id);
        if (body_health <= 0) {
            if (_no_body) pvz_lawn_zombie_die_no_body(id);
            else pvz_lawn_zombie_die(id);
        }
'@
    $runtime = Replace-Once $runtime $oldDamageBlock $newDamageBlock 'preserve original Zomboss lethal-health sentinel'
    $runtime = Replace-Once $runtime 'function pvz_lawn_zombie_take_damage(_zid, _damage, _no_body = false) {' 'function pvz_lawn_zombie_take_damage(_zid, _damage, _no_body = false) { // PVZ_BOSS_STAGED_DEATH_V1' 'mark staged boss damage handler'
}

# Keep the boss degradation/critical-health gate live on its normal update path, not only on damage events.
if (-not $runtime.Contains('PVZ_BOSS_DEGRADATION_STEP_HOOK_V1') -and -not $runtime.Contains('if (_kind == "boss") pvz_lawn_boss_update_degradation(_zid);')) {
    $oldStepHeader = @'
function pvz_lawn_zombie_step_special(_zid, _ground_speed) {
    if (!instance_exists(_zid) || _zid.dead) return false;
    var _kind = _zid.zombie_kind;
'@
    $newStepHeader = @'
function pvz_lawn_zombie_step_special(_zid, _ground_speed) {
    if (!instance_exists(_zid) || _zid.dead) return false;
    var _kind = _zid.zombie_kind;
    if (_kind == "boss") pvz_lawn_boss_update_degradation(_zid); // PVZ_BOSS_DEGRADATION_STEP_HOOK_V1
'@
    $runtime = Replace-Once $runtime $oldStepHeader $newStepHeader 'run source-matched boss health effects during normal boss updates'
}

# Ensure other boss-death entry points also use the dedicated animation sequence, not the generic death branch.
if (-not $runtime.Contains('PVZ_BOSS_DIE_REDIRECT_V1')) {
    $oldDieBranch = @'
    if (_zid.dead || global.pvz_lawn_lost_state != "") return;
    if (_zid.zombie_kind == "flag") pvz_lawn_zombie_drop_flag(_zid);
'@
    $newDieBranch = @'
    if (_zid.dead || global.pvz_lawn_lost_state != "") return;
    if (_zid.zombie_kind == "boss") { pvz_lawn_boss_begin_death(_zid); return; } // PVZ_BOSS_DIE_REDIRECT_V1
    if (_zid.zombie_kind == "flag") pvz_lawn_zombie_drop_flag(_zid);
'@
    $dieFunctionIndex = $runtime.IndexOf('function pvz_lawn_zombie_die(_zid) {', [StringComparison]::Ordinal)
    if ($dieFunctionIndex -lt 0) { throw 'Could not find pvz_lawn_zombie_die.' }
    $dieBranchIndex = $runtime.IndexOf($oldDieBranch, $dieFunctionIndex, [StringComparison]::Ordinal)
    if ($dieBranchIndex -lt 0) { throw 'Could not find the die-handler branch after pvz_lawn_zombie_die.' }
    $runtime = $runtime.Substring(0, $dieBranchIndex) + $newDieBranch + $runtime.Substring($dieBranchIndex + $oldDieBranch.Length)
}

# DAMAGE_DOESNT_LEAVE_BODY does not bypass the original Zomboss death animation (PlayDeathAnim has an explicit boss exception).
if (-not $runtime.Contains('PVZ_BOSS_DIE_NO_BODY_REDIRECT_V1')) {
    $dieNoBodyHeader = @'
function pvz_lawn_zombie_die_no_body(_zid) {
    if (!instance_exists(_zid)) return;
    if (_zid.dead || global.pvz_lawn_lost_state != "") return;
'@
    $dieNoBodyHeaderNew = @'
function pvz_lawn_zombie_die_no_body(_zid) {
    if (!instance_exists(_zid)) return;
    if (_zid.dead || global.pvz_lawn_lost_state != "") return;
    if (_zid.zombie_kind == "boss") { pvz_lawn_boss_begin_death(_zid); return; } // PVZ_BOSS_DIE_NO_BODY_REDIRECT_V1
'@
    $runtime = Replace-Once $runtime $dieNoBodyHeader $dieNoBodyHeaderNew 'route no-body Zomboss deaths through the source death sequence'
}

# Schedule death only after the current head-down / spit / post-spit idle has played, like UpdateBoss.
if (-not $runtime.Contains('PVZ_BOSS_DEATH_HEAD_LEAVE_V1')) {
    $oldIdleAfterSpit = @'
        if (_zid.phase == "boss_head_idle_after_spit" && _zid.special_counter <= 0) {
            _zid.phase = "boss_head_leave";
            _zid.body.play("anim_head_leave", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 12.0);
            _zid.special_counter = max(1, round(_zid.body.frame_count / 12.0 * 100.0));
            return true;
        }
'@
    $newIdleAfterSpit = @'
        // PVZ_BOSS_DEATH_HEAD_LEAVE_V1: lethal damage finishes the existing head-down sequence before death.
        if (_zid.phase == "boss_head_idle_after_spit" && _zid.special_counter <= 0) {
            if (variable_instance_exists(_zid, "boss_death_pending") && _zid.boss_death_pending) {
                pvz_lawn_boss_begin_death(_zid);
                return true;
            }
            _zid.phase = "boss_head_leave";
            _zid.body.play("anim_head_leave", ReanimLoop.PLAY_ONCE_AND_HOLD, 0, 12.0);
            _zid.special_counter = max(1, round(_zid.body.frame_count / 12.0 * 100.0));
            return true;
        }
'@
    $runtime = Replace-Once $runtime $oldIdleAfterSpit $newIdleAfterSpit 'start boss death after current head attack finishes'
    $oldLeave = @'
        if (_zid.phase == "boss_head_leave" && (_zid.body.loop_count > 0 || _zid.special_counter <= 0)) {
            _zid.phase = "boss_idle";
            _zid.special_counter = irandom_range(100, 200);
            _zid.body.play("anim_idle", ReanimLoop.LOOP, 0, 6.0);
            return true;
        }
'@
    $newLeave = @'
        if (_zid.phase == "boss_head_leave" && (_zid.body.loop_count > 0 || _zid.special_counter <= 0)) {
            if (variable_instance_exists(_zid, "boss_death_pending") && _zid.boss_death_pending) {
                // Original UpdateBoss calls BossPlayIdle after the head leaves; the next idle update starts PlayDeathAnim.
                pvz_lawn_boss_stop_smoke_emitters(_zid);
                _zid.phase = "boss_idle";
                _zid.special_counter = irandom_range(100, 200);
                _zid.body.play("anim_idle", ReanimLoop.LOOP, 0, 6.0);
                return true;
            }
            _zid.phase = "boss_idle";
            _zid.special_counter = irandom_range(100, 200);
            _zid.body.play("anim_idle", ReanimLoop.LOOP, 0, 6.0);
            return true;
        }
'@
    $runtime = Replace-Once $runtime $oldLeave $newLeave 'return from head departure to idle before paired death animations'
    $oldBossIdle = @'
        if (_zid.phase == "boss_idle") {
            _zid.special_counter--;
'@
    $newBossIdle = @'
        if (_zid.phase == "boss_idle") {
            // PVZ_BOSS_DEATH_IDLE_FINALIZE_V1: original UpdateBoss sees the one-health sentinel immediately after BossPlayIdle.
            if (variable_instance_exists(_zid, "boss_death_pending") && _zid.boss_death_pending) {
                pvz_lawn_boss_finish_death(_zid);
                return true;
            }
            _zid.special_counter--;
'@
    $runtime = Replace-Once $runtime $oldBossIdle $newBossIdle 'finish boss body/driver death after source-style idle handoff'
}

# Original low-health flash: TodAnimateCurve(0,39,MainCounter%40,155,255,CURVE_BOUNCE).
if (-not $runtime.Contains('PVZ_BOSS_LOW_HEALTH_FLASH_V1')) {
    $oldTintBlock = @'
    var _chill_active = chilled_countdown > 0 && _kind != "zomboni";
    var _snowpea_tint = _chill_active ? make_color_rgb(75, 75, 255) : c_white;
    pvz_lawn_reanim_set_tint(body, _chill_active, _snowpea_tint);
'@
    $newTintBlock = @'
    var _chill_active = chilled_countdown > 0 && _kind != "zomboni";
    var _snowpea_tint = _chill_active ? make_color_rgb(75, 75, 255) : c_white;
    // PVZ_BOSS_LOW_HEALTH_FLASH_V1: reproduce the original grayscale bounce below BOSS_FLASH_HEALTH_FRACTION (10% HP).
    var _boss_low_health_flash = (_kind == "boss" && !dead && body_health < body_max_health / 10.0);
    if (_boss_low_health_flash) {
        var _boss_pulse_age = (global.pvz_lawn_tick mod 40) / 39.0;
        var _boss_bounce = 1.0 - abs(2.0 * _boss_pulse_age - 1.0);
        var _boss_gray = round(155.0 + 100.0 * _boss_bounce);
        if (_chill_active) {
            var _boss_cold = round(65.0 + 10.0 * _boss_bounce);
            pvz_lawn_reanim_set_tint(body, true, make_color_rgb(_boss_cold, _boss_cold, _boss_gray));
        } else {
            pvz_lawn_reanim_set_tint(body, true, make_color_rgb(_boss_gray, _boss_gray, _boss_gray));
        }
    } else {
        pvz_lawn_reanim_set_tint(body, _chill_active, _snowpea_tint);
    }
'@
    $runtime = Replace-Once $runtime $oldTintBlock $newTintBlock 'apply original Zomboss low-health flashing pulse'
}

# Particle emitter object: custom follow-tracks allow original smoke to stay attached to Boss_head.
if (-not $fxCreate.Contains('PVZ_BOSS_SMOKE_TRACK_FOLLOW_V1')) {
    $fxCreate = $fxCreate + @'

// PVZ_BOSS_SMOKE_TRACK_FOLLOW_V1 defaults for optional original Boss_head smoke attachments.
if (!variable_instance_exists(id, "fx_xml_effect_name")) fx_xml_effect_name = "";
if (!variable_instance_exists(id, "fx_follow_track")) fx_follow_track = "";
if (!variable_instance_exists(id, "fx_follow_offset_x")) fx_follow_offset_x = 0.0;
if (!variable_instance_exists(id, "fx_follow_offset_y")) fx_follow_offset_y = 0.0;
if (!variable_instance_exists(id, "fx_boss_smoke")) fx_boss_smoke = false;
'@
}
if (-not $fxStep.Contains('PVZ_BOSS_SMOKE_TRACK_FOLLOW_V1')) {
    $oldFollow = @'
        if (_follow_active) {
            if (!instance_exists(fx_follow_id)) { instance_destroy(); break; }
            // ParticleSystem attachment follows the projectile origin; emitted snowflakes do not follow it.
            fx_xml_origin_x = fx_follow_id.x + 8.0;
            fx_xml_origin_y = fx_follow_id.y + 13.0;
            x = fx_xml_origin_x;
            y = fx_xml_origin_y;
        }
'@
    $newFollow = @'
        if (_follow_active) {
            if (!instance_exists(fx_follow_id)) { instance_destroy(); break; }
            // Ordinary follows preserve the existing projectile effect offset. Boss smoke follows the live Boss_head Reanim track.
            if (variable_instance_exists(id, "fx_follow_track") && fx_follow_track != ""
                && variable_instance_exists(fx_follow_id, "body") && !is_undefined(fx_follow_id.body)
                && fx_follow_id.body != noone) {
                var _follow_pos = pvz_lawn_track_world_pos(fx_follow_id.body, fx_follow_track, fx_follow_id.x, fx_follow_id.y);
                fx_xml_origin_x = _follow_pos[0] + (variable_instance_exists(id, "fx_follow_offset_x") ? fx_follow_offset_x : 0.0);
                fx_xml_origin_y = _follow_pos[1] + (variable_instance_exists(id, "fx_follow_offset_y") ? fx_follow_offset_y : 0.0);
            } else {
                fx_xml_origin_x = fx_follow_id.x + 8.0;
                fx_xml_origin_y = fx_follow_id.y + 13.0;
            }
            x = fx_xml_origin_x;
            y = fx_xml_origin_y;
        }
        // PVZ_BOSS_SMOKE_TRACK_FOLLOW_V1
'@
    $oldFollowCount = ([regex]::Matches($fxStep, [regex]::Escape($oldFollow))).Count
    if ($oldFollowCount -eq 1) {
        $fxStep = Replace-Once $fxStep $oldFollow $newFollow 'follow original smoke emitter from the Boss_head track'
    } else {
        # Alternate source revisions may have a different comment or spacing around the same follow block.
        $followPattern = '(?m)^(?<indent>[ \t]*)if\s*\(_follow_active\)\s*\{\s*if\s*\(!instance_exists\(fx_follow_id\)\)\s*\{\s*instance_destroy\(\);\s*break;\s*\}\s*(?://[^\r\n]*\r?\n\s*)?fx_xml_origin_x\s*=\s*fx_follow_id\.x\s*\+\s*8\.0\s*;\s*fx_xml_origin_y\s*=\s*fx_follow_id\.y\s*\+\s*13\.0\s*;\s*x\s*=\s*fx_xml_origin_x\s*;\s*y\s*=\s*fx_xml_origin_y\s*;\s*\}'
        $followMatches = [regex]::Matches($fxStep, $followPattern)
        if ($followMatches.Count -ne 1) {
            throw "Could not uniquely locate the existing fx_follow_id origin-update block (found $($followMatches.Count)). No project source was written."
        }
        $followMatch = $followMatches[0]
        $fxStep = $fxStep.Substring(0, $followMatch.Index) + $newFollow.TrimEnd() + $fxStep.Substring($followMatch.Index + $followMatch.Length)
    }
}

# Validate that all edits were prepared before touching the original project. Write backups of changed files first.
$changedRuntime = ($runtime -cne $origRuntime)
$changedFxStep = ($fxStep -cne $origFxStep)
$changedFxCreate = ($fxCreate -cne $origFxCreate)
if (-not ($changedRuntime -or $changedFxStep -or $changedFxCreate)) {
    Write-Host 'All v5.1 installer markers already exist; no files needed changes.' -ForegroundColor Yellow
    Write-Host "Project: $ProjectRoot"
    exit 0
}
New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
if ($changedRuntime) { Backup-File $RuntimePath 'scripts\scr_pvz_lawn_runtime\scr_pvz_lawn_runtime.gml' }
if ($changedFxStep) { Backup-File $FxStepPath 'objects\obj_pvz_lawn_fx_piece\Step_0.gml' }
if ($changedFxCreate) { Backup-File $FxCreatePath 'objects\obj_pvz_lawn_fx_piece\Create_0.gml' }
if ($changedRuntime) { Write-Utf8NoBom $RuntimePath $runtime }
if ($changedFxStep) { Write-Utf8NoBom $FxStepPath $fxStep }
if ($changedFxCreate) { Write-Utf8NoBom $FxCreatePath $fxCreate }

Write-Host ''
Write-Host 'PvZ Zomboss low-health smoke/flash and source-staged death fix v5.1 applied.' -ForegroundColor Green
Write-Host "Project: $ProjectRoot"
Write-Host "Backup:  $BackupRoot"
Write-Host 'Changes: original 80%/50% damage sprites; attached ZamboniSmoke systems and 10% grayscale pulse; BossStartDeath explosion + SFX; original fire/ice ball death effects; cleanup/fade; body + Dr. Edgar anim_death at 18 FPS.'
Write-Host 'Open PvZ.yyp in GameMaker and test the boss fight. This script has not run the GameMaker compiler.'
