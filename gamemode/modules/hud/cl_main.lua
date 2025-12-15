-- Enhanced HUD Script for GMod
-- Core modules
local IsValid = IsValid
local LocalPlayer = LocalPlayer
local surface = surface
local draw = draw
local ScrW = ScrW
local ScrH = ScrH
local CurTime = CurTime
local Lerp = Lerp
local FrameTime = FrameTime
local Color = Color
local math = math
local table = table
local hook = hook
local render = render
local string = string
local tostring = tostring
local ipairs = ipairs
local Material = Material

-- Screen dimensions
local W, H = ScrW(), ScrH()

-- Helmet overlay material
local HELMET_MATERIAL = nil

-- Initialize helmet material
local function InitHelmetMaterial()
    -- Try to load custom helmet material first
    HELMET_MATERIAL = Material("clone_helmet_hud.vmt")

    -- If custom material not found, use Source material as fallback
    if HELMET_MATERIAL:IsError() then
        HELMET_MATERIAL = Material("models/props_combine/combine_interface_disp")
        print("[HUD] Custom helmet material not found, using Source material")
    end

    -- Final fallback to basic material
    if HELMET_MATERIAL:IsError() then
        HELMET_MATERIAL = Material("vgui/white")
        print("[HUD] Using basic white material for helmet")
    end
end

-- Initialize material after a short delay
timer.Simple(0.1, InitHelmetMaterial)

-- Helmet state tracking
local helmet_state = true
local helmet_alpha = 255
local last_helmet_check = 0
local camera_sway = {x = 0, y = 0}
local last_angles = Angle(0, 0, 0)

-- Create required fonts
surface.CreateFont("hud_dir", {
    font = "Tahoma",
    size = 20,
    weight = 800,
    antialias = true
})

surface.CreateFont("hud_deg", {
    font = "Tahoma",
    size = 16,
    weight = 500,
    antialias = true
})

surface.CreateFont("hud_values", {
    font = "Tahoma",
    size = 24,
    weight = 700,
    antialias = true
})

surface.CreateFont("hud_name", {
    font = "Tahoma",
    size = 26,
    weight = 800,
    antialias = true
})

surface.CreateFont("hud_team", {
    font = "Tahoma",
    size = 18,
    weight = 500,
    antialias = true
})

surface.CreateFont("hud_ammo", {
    font = "Tahoma",
    size = 40,
    weight = 800,
    antialias = true
})

surface.CreateFont("hud_ammo_reserve", {
    font = "Tahoma",
    size = 24,
    weight = 500,
    antialias = true
})

surface.CreateFont("hud_damage", {
    font = "Tahoma",
    size = 26,
    weight = 700,
    antialias = true,
    shadow = true
})

-- Animation variables
local lerp_health = 100
local lerp_armor = 0
local max_health = 100
local max_armor = 100

-- Define colors
local COLORS = {
    -- Colors for bars
    health = Color(110, 30, 30, 255),      -- Red for health
    armor = Color(180, 160, 20, 255),      -- Blue for armor
    stamina = Color(20, 60, 110, 255),     -- Green for stamina

    -- Background colors
    bg_dark = Color(40, 40, 40, 150),
    bg_light = Color(40, 40, 40, 150),

    -- Text colors
    text_bright = Color(255, 255, 255, 255),
    text_dim = Color(200, 200, 200, 200),
    text_dark = Color(0, 0, 0, 200),

    -- Special colors
    highlight = Color(255, 255, 255, 30),
    warning = Color(255, 60, 60),
    success = Color(60, 255, 60),
    primary = Color(110, 30, 30, 255),
    secondary = Color(180, 160, 20, 255),
    tertiary = Color(20, 60, 110, 255)
}

-- Compass directions
local directions = {
    { angle = 0, letter = "С" },
    { angle = 45, letter = "СВ" },
    { angle = 90, letter = "В" },
    { angle = 135, letter = "ЮВ" },
    { angle = 180, letter = "Ю" },
    { angle = 225, letter = "ЮЗ" },
    { angle = 270, letter = "З" },
    { angle = 315, letter = "СЗ" },
    { angle = 360, letter = "С" }
}

-- Damage numbers tracker
local HIT_NUMBERS = {}

-- Check if helmet is on
local function IsHelmetOn()
    local player = LocalPlayer()
    if not IsValid(player) then return false end

    local helmetBodyGroups = { 'Helmet', 'Head', 'helmet', 'head' }
    for k, data in pairs(player:GetBodyGroups()) do
        if table.HasValue(helmetBodyGroups, data.name) then
            return player:GetBodygroup(data.id) == 0 -- 0 = helmet on
        end
    end

    return true -- Default helmet on
end

-- Check if in third person
local function IsThirdPerson()
    local player = LocalPlayer()
    if not IsValid(player) then return false end
    return player:ShouldDrawLocalPlayer()
end

-- Draw helmet overlay using material
local function DrawHelmetOverlay()
    local player = LocalPlayer()
    if not IsValid(player) or not player:Alive() then return end

    -- Check helmet state - helmet is on only in first person AND with helmet
    local current_helmet = IsHelmetOn() and not IsThirdPerson()

    if current_helmet ~= helmet_state then
        helmet_state = current_helmet
    end

    local target_alpha = helmet_state and 255 or 0
    helmet_alpha = Lerp(FrameTime() * 5, helmet_alpha, target_alpha)

    if helmet_alpha < 5 then return end

    -- Calculate camera sway effect
    local current_angles = player:EyeAngles()
    local angle_diff = current_angles - last_angles

    -- Smooth camera sway
    camera_sway.x = Lerp(FrameTime() * 10, camera_sway.x, math.Clamp(angle_diff.y * 0.1, -2, 2))
    camera_sway.y = Lerp(FrameTime() * 10, camera_sway.y, math.Clamp(-angle_diff.p * 0.1, -2, 2))

    last_angles = current_angles

    -- Draw helmet overlay material covering the entire screen with sway
    if HELMET_MATERIAL and not HELMET_MATERIAL:IsError() then
        surface.SetMaterial(HELMET_MATERIAL)
        surface.SetDrawColor(255, 255, 255, helmet_alpha)

        -- Draw the helmet overlay texture with camera sway
        surface.DrawTexturedRect(camera_sway.x, camera_sway.y, W, H)
    end
end

-- Helper functions
local function DrawRoundedBox(radius, x, y, w, h, color)
    draw.RoundedBox(radius, x, y, w, h, color)
end

-- Function to draw animated glowing effect for individual segments
local function DrawSegmentGlow(x, y, w, h, color, intensity)
    local time = CurTime()
    intensity = intensity or 2

    -- Pulsing animation
    local pulse = math.sin(time * 1.5) * 0.4 + 0.6 -- Range from 0.2 to 1.0
    local alpha = math.floor(20 * pulse)

    local glow_color = Color(color.r, color.g, color.b, alpha)

    for i = 1, intensity do
        local glow_size = i * 1.5 * pulse
        DrawRoundedBox(2, x - glow_size, y - glow_size, w + glow_size * 2, h + glow_size * 2, glow_color)
    end
end

-- Function to draw particles along individual segment edges
local function DrawSegmentParticles(x, y, w, h, color, segment_index, slant_amount)
    slant_amount = slant_amount or 0
    local time = CurTime()

    -- Only 2 particles per segment, slower movement
    for i = 1, 2 do
        local speed = 0.2 + (segment_index * 0.02) + (i * 0.1) -- Much slower
        local progress = (time * speed + i * 0.5 + segment_index * 0.1) % 1.0
        local perimeter = 2 * (w + h)
        local distance = progress * perimeter

        local particle_x, particle_y

        if distance <= w then
            -- Top edge
            particle_x = x + distance
            particle_y = y + (distance * slant_amount / w)
        elseif distance <= w + h then
            -- Right edge
            particle_x = x + w - slant_amount
            particle_y = y + (distance - w) + slant_amount
        elseif distance <= 2 * w + h then
            -- Bottom edge
            local bottom_progress = distance - w - h
            particle_x = x + w - bottom_progress
            particle_y = y + h
        else
            -- Left edge
            particle_x = x
            particle_y = y + h - (distance - 2 * w - h)
        end

        -- Create shorter trail effect
        for j = 0, 1 do
            local trail_progress = (progress - j * 0.05) % 1.0
            local trail_distance = trail_progress * perimeter

            local trail_x, trail_y
            if trail_distance <= w then
                trail_x = x + trail_distance
                trail_y = y + (trail_distance * slant_amount / w)
            elseif trail_distance <= w + h then
                trail_x = x + w - slant_amount
                trail_y = y + (trail_distance - w) + slant_amount
            elseif trail_distance <= 2 * w + h then
                local trail_bottom_progress = trail_distance - w - h
                trail_x = x + w - trail_bottom_progress
                trail_y = y + h
            else
                trail_x = x
                trail_y = y + h - (trail_distance - 2 * w - h)
            end

            local particle_size = 1.5 - (j * 0.5)
            local alpha = (120 - j * 40) * (math.sin(time * 2 + segment_index + i) * 0.3 + 0.7)

            local particle_color = Color(color.r, color.g, color.b, alpha)
            DrawRoundedBox(0, trail_x - particle_size/2, trail_y - particle_size/2, particle_size, particle_size, particle_color)
        end
    end
end

-- Function to draw particles for stamina segments
local function DrawStaminaSegmentParticles(x, y, w, h, color, segment_index)
    local time = CurTime()

    -- Only 1 particle per segment for stamina, slower
    local speed = 0.15 + (segment_index * 0.01)
    local progress = (time * speed + segment_index * 0.1) % 1.0
    local perimeter = 2 * (w + h)
    local distance = progress * perimeter

    local particle_x, particle_y

    if distance <= w then
        -- Top edge
        particle_x = x + distance
        particle_y = y
    elseif distance <= w + h then
        -- Right edge
        particle_x = x + w
        particle_y = y + (distance - w)
    elseif distance <= 2 * w + h then
        -- Bottom edge
        particle_x = x + w - (distance - w - h)
        particle_y = y + h
    else
        -- Left edge
        particle_x = x
        particle_y = y + h - (distance - 2 * w - h)
    end

    -- Short trail
    for j = 0, 1 do
        local trail_progress = (progress - j * 0.08) % 1.0
        local trail_distance = trail_progress * perimeter

        local trail_x, trail_y
        if trail_distance <= w then
            trail_x = x + trail_distance
            trail_y = y
        elseif trail_distance <= w + h then
            trail_x = x + w
            trail_y = y + (trail_distance - w)
        elseif trail_distance <= 2 * w + h then
            trail_x = x + w - (trail_distance - w - h)
            trail_y = y + h
        else
            trail_x = x
            trail_y = y + h - (trail_distance - 2 * w - h)
        end

        local particle_size = 1.3 - (j * 0.4)
        local alpha = (100 - j * 30) * (math.sin(time * 1.8 + segment_index) * 0.3 + 0.7)

        local particle_color = Color(color.r, color.g, color.b, alpha)
        DrawRoundedBox(0, trail_x - particle_size/2, trail_y - particle_size/2, particle_size, particle_size, particle_color)
    end
end

-- Function to draw segmented bar with background
local function DrawSegmentedBar(x, y, w, h, value, max, color, segments, has_background)
    segments = segments or 10
    has_background = has_background == nil and true or has_background

    -- Draw background if needed
    if has_background then
        DrawRoundedBox(4, x - 2, y - 2, w + 4, h + 4, COLORS.bg_dark)
    end

    local segment_width = w / segments
    local segment_spacing = 2
    local actual_segment_width = segment_width - segment_spacing

    -- Calculate how many segments should be filled
    local fill_ratio = math.Clamp(value / max, 0, 1)
    local filled_segments = math.floor(fill_ratio * segments)
    local partial_fill = (fill_ratio * segments) - filled_segments

    for i = 0, segments - 1 do
        local seg_x = x + (i * segment_width)

        local is_filled = false
        if i < filled_segments then
            is_filled = true
        elseif i == filled_segments and partial_fill > 0 then
            is_filled = true
        end

        if is_filled then
            DrawSegmentGlow(seg_x, y, actual_segment_width, h, color, 2)
            DrawStaminaSegmentParticles(seg_x, y, actual_segment_width, h, color, i)
        end

        local seg_color
        if is_filled then
            seg_color = color
        else
            seg_color = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3, 100)
        end

        DrawRoundedBox(2, seg_x, y, actual_segment_width, h, seg_color)
    end

    return value
end

-- Function to draw slanted health bar with segments and individual effects (helmet mode)
local function DrawSlantedHealthBar(x, y, w, h, value, max, color, segments)
    segments = segments or 15

    local slant_amount = 20

    -- Calculate segments
    local segment_width = w / segments
    local segment_spacing = 2
    local actual_segment_width = segment_width - segment_spacing

    local fill_ratio = math.Clamp(value / max, 0, 1)
    local filled_segments = math.floor(fill_ratio * segments)
    local partial_fill = (fill_ratio * segments) - filled_segments

    -- Draw segments with individual effects
    for i = 0, segments - 1 do
        local seg_x = x + (i * segment_width)

        -- Calculate segment height based on slant
        local top_offset = (seg_x + actual_segment_width - x) * (slant_amount / w)
        local seg_top_y = y + top_offset
        local seg_bottom_y = y + h

        local is_filled = false
        if i < filled_segments then
            is_filled = true
        elseif i == filled_segments and partial_fill > 0 then
            is_filled = true
        end

        -- Draw glow for filled segments only
        if is_filled then
            DrawSegmentGlow(seg_x, seg_top_y, actual_segment_width, h - top_offset, color, 2)
        end

        -- Create segment vertices
        local seg_verts = {
            {x = seg_x, y = seg_bottom_y},
            {x = seg_x, y = seg_top_y},
            {x = seg_x + actual_segment_width, y = seg_top_y + (actual_segment_width * slant_amount / w)},
            {x = seg_x + actual_segment_width, y = seg_bottom_y}
        }

        local seg_color
        if is_filled then
            seg_color = color
            -- Draw particles for filled segments only
            DrawSegmentParticles(seg_x, seg_top_y, actual_segment_width, h - top_offset, color, i, slant_amount * (actual_segment_width / w))
        else
            seg_color = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 80)
        end

        surface.SetDrawColor(seg_color)
        draw.NoTexture()
        surface.DrawPoly(seg_verts)
    end

    return value
end

-- Function to draw slanted armor bar with segments and individual effects (helmet mode)
local function DrawSlantedArmorBar(x, y, w, h, value, max, color, segments)
    segments = segments or 15

    local slant_amount = 20

    -- Calculate segments
    local segment_width = w / segments
    local segment_spacing = 2
    local actual_segment_width = segment_width - segment_spacing

    local fill_ratio = math.Clamp(value / max, 0, 1)
    local filled_segments = math.floor(fill_ratio * segments)
    local partial_fill = (fill_ratio * segments) - filled_segments

    -- Draw segments with individual effects
    for i = 0, segments - 1 do
        local seg_x = x + (i * segment_width)

        -- Calculate segment height based on slant (reversed)
        local top_offset = slant_amount - ((seg_x + actual_segment_width - x) * (slant_amount / w))
        local seg_top_y = y + top_offset
        local seg_bottom_y = y + h

        -- Determine if segment should be filled (from right to left)
        local segment_from_right = segments - 1 - i
        local is_filled = false
        if segment_from_right < filled_segments then
            is_filled = true
        elseif segment_from_right == filled_segments and partial_fill > 0 then
            is_filled = true
        end

        -- Draw glow for filled segments only
        if is_filled then
            DrawSegmentGlow(seg_x, seg_top_y, actual_segment_width, h - top_offset, color, 2)
        end

        -- Create segment vertices
        local seg_verts = {
            {x = seg_x, y = seg_bottom_y},
            {x = seg_x, y = seg_top_y},
            {x = seg_x + actual_segment_width, y = seg_top_y - (actual_segment_width * slant_amount / w)},
            {x = seg_x + actual_segment_width, y = seg_bottom_y}
        }

        local seg_color
        if is_filled then
            seg_color = color
            -- Draw particles for filled segments only
            DrawSegmentParticles(seg_x, seg_top_y, actual_segment_width, h - top_offset, color, i, -(slant_amount * (actual_segment_width / w)))
        else
            seg_color = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 80)
        end

        surface.SetDrawColor(seg_color)
        draw.NoTexture()
        surface.DrawPoly(seg_verts)
    end

    return value
end

-- Исправленная функция для отрисовки шкалы выносливости (заполнение от центра наружу)
local function DrawCenterStaminaBar(x, y, w, h, value, max, color, segments)
    segments = segments or 12

    local segment_width = w / segments
    local segment_spacing = 1
    local actual_segment_width = segment_width - segment_spacing

    local fill_ratio = math.Clamp(value / max, 0, 1)
    local total_filled_segments = math.floor(fill_ratio * segments + 0.5) -- Добавляем округление

    -- Исправленный расчет заполнения от центра наружу
    local center = segments / 2 -- Центр (может быть дробным)

    for i = 0, segments - 1 do
        local seg_x = x + (i * segment_width)

        -- Определяем, должен ли этот сегмент быть заполнен
        local should_fill = false

        if total_filled_segments >= segments then
            -- Все сегменты заполнены
            should_fill = true
        else
            -- Расчет расстояния от центра для текущего сегмента
            local distance_from_center = math.abs(i + 0.5 - center)
            local max_distance_to_fill = (total_filled_segments / 2)

            -- Заполняем если расстояние от центра меньше максимального расстояния заполнения
            should_fill = distance_from_center <= max_distance_to_fill
        end

        -- Рисуем свечение для заполненных сегментов
        if should_fill then
            DrawSegmentGlow(seg_x, y, actual_segment_width, h, color, 1)
        end

        local seg_color
        if should_fill then
            seg_color = color
            -- Рисуем частицы для заполненных сегментов
            DrawStaminaSegmentParticles(seg_x, y, actual_segment_width, h, color, i)
        else
            seg_color = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 80)
        end

        DrawRoundedBox(2, seg_x, y, actual_segment_width, h, seg_color)
    end

    return value
end
-- Function to draw health bar for third person - top slant left high to right low
local function DrawThirdPersonHealthBar(x, y, w, h, value, max, color, segments)
    segments = segments or 20

    local slant_amount = 15

    local segment_width = w / segments
    local segment_spacing = 2
    local actual_segment_width = segment_width - segment_spacing

    local fill_ratio = math.Clamp(value / max, 0, 1)
    local filled_segments = math.floor(fill_ratio * segments)
    local partial_fill = (fill_ratio * segments) - filled_segments

    for i = 0, segments - 1 do
        local seg_x = x + (i * segment_width)

        -- Top slant: left high, right low
        local progress = (seg_x - x) / w
        local left_top_y = y + (progress * slant_amount)
        local right_top_y = y + ((seg_x + actual_segment_width - x) / w * slant_amount)

        local seg_verts = {
            {x = seg_x, y = y + h},                              -- Bottom left
            {x = seg_x, y = left_top_y},                         -- Top left
            {x = seg_x + actual_segment_width, y = right_top_y}, -- Top right
            {x = seg_x + actual_segment_width, y = y + h}        -- Bottom right
        }

        local is_filled = false
        if i < filled_segments then
            is_filled = true
        elseif i == filled_segments and partial_fill > 0 then
            is_filled = true
        end

        local seg_color
        if is_filled then
            seg_color = color
            DrawSegmentGlow(seg_x, left_top_y, actual_segment_width, h - (left_top_y - y), color, 2)
            DrawSegmentParticles(seg_x, left_top_y, actual_segment_width, h - (left_top_y - y), color, i, (right_top_y - left_top_y) / actual_segment_width)
        else
            seg_color = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 80)
        end

        surface.SetDrawColor(seg_color)
        draw.NoTexture()
        surface.DrawPoly(seg_verts)
    end

    return value
end

-- Function to draw armor bar for third person - bottom slant left low to right high
local function DrawThirdPersonArmorBar(x, y, w, h, value, max, color, segments)
    segments = segments or 20

    local slant_amount = 15

    local segment_width = w / segments
    local segment_spacing = 2
    local actual_segment_width = segment_width - segment_spacing

    local fill_ratio = math.Clamp(value / max, 0, 1)
    local filled_segments = math.floor(fill_ratio * segments)
    local partial_fill = (fill_ratio * segments) - filled_segments

    for i = 0, segments - 1 do
        local seg_x = x + (i * segment_width)

        -- Bottom slant: left low, right high
        local progress = (seg_x - x) / w
        local left_bottom_y = y + h - (progress * slant_amount)
        local right_bottom_y = y + h - ((seg_x + actual_segment_width - x) / w * slant_amount)

        local seg_verts = {
            {x = seg_x, y = left_bottom_y},                      -- Bottom left
            {x = seg_x, y = y},                                  -- Top left
            {x = seg_x + actual_segment_width, y = y},           -- Top right
            {x = seg_x + actual_segment_width, y = right_bottom_y} -- Bottom right
        }

        local is_filled = false
        if i < filled_segments then
            is_filled = true
        elseif i == filled_segments and partial_fill > 0 then
            is_filled = true
        end

        local seg_color
        if is_filled then
            seg_color = color
            DrawSegmentGlow(seg_x, y, actual_segment_width, h, color, 2)
            DrawSegmentParticles(seg_x, y, actual_segment_width, h, color, i, (right_bottom_y - left_bottom_y) / actual_segment_width)
        else
            seg_color = Color(color.r * 0.2, color.g * 0.2, color.b * 0.2, 80)
        end

        surface.SetDrawColor(seg_color)
        draw.NoTexture()
        surface.DrawPoly(seg_verts)
    end

    return value
end

local function DrawShadowText(text, font, x, y, color, align_x, align_y)
    align_x = align_x or TEXT_ALIGN_LEFT
    align_y = align_y or TEXT_ALIGN_TOP

    -- Shadow
    draw.SimpleText(text, font, x + 1, y + 1, COLORS.text_dark, align_x, align_y)

    -- Main text
    draw.SimpleText(text, font, x, y, color, align_x, align_y)
end

-- HUD Components
local function DrawCompass()
    local player = LocalPlayer()
    if not player:Alive() then return end

    local compass_width = 500
    local compass_height = 30
    local compass_x, compass_y

    -- Compass always centered regardless of helmet state
    compass_x = W / 2 - compass_width / 2
    compass_y = 20

    -- Compass background
    DrawRoundedBox(4, compass_x, compass_y, compass_width, compass_height, COLORS.bg_dark)

    -- Center marker always in screen center
    local marker_x = W / 2
    DrawShadowText("▼", "hud_dir", marker_x, compass_y - 5, COLORS.primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Player angle
    local yaw = player:GetAngles().y % 360

    -- Draw compass
    local marker_spacing = 30

    for deg = 0, 359, marker_spacing do
        local relative_angle = (yaw - deg + 540) % 360 - 180

        -- Only draw if in visible range
        if math.abs(relative_angle) <= 180 then
            local x_pos = marker_x + relative_angle * (compass_width / 360)

            -- Check if cardinal direction
            local is_cardinal = false
            local direction_text = ""

            for _, dir in ipairs(directions) do
                if deg == dir.angle then
                    is_cardinal = true
                    direction_text = dir.letter
                    break
                end
            end

            if is_cardinal then
                -- Draw cardinal direction
                surface.SetDrawColor(COLORS.primary)
                DrawShadowText(direction_text, "hud_dir", x_pos, compass_y + 15, COLORS.text_bright, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            elseif deg % 45 == 0 then
                -- Draw intermediate directions
                surface.SetDrawColor(COLORS.secondary)
                surface.DrawRect(x_pos - 1, compass_y + 8, 2, compass_height - 16)
            else
                -- Draw regular tick
                surface.SetDrawColor(COLORS.text_dim)
                surface.DrawRect(x_pos - 0.5, compass_y + 12, 1, compass_height - 24)
            end
        end
    end

    -- Compass border
    surface.SetDrawColor(COLORS.primary)
    surface.DrawOutlinedRect(compass_x, compass_y, compass_width, compass_height, 1)

    -- Current bearing text
    local bearing = math.Round(360 - yaw) % 360
    local bearing_x = compass_x + compass_width + 10
    DrawShadowText(bearing .. "°", "hud_dir", bearing_x, compass_y + 15, COLORS.text_bright, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

local function DrawPlayerHUD()
    local player = LocalPlayer()
    if not player:Alive() then return end

    max_health = player:GetMaxHealth() or 100

    -- Smoothly animate health
    lerp_health = Lerp(FrameTime() * 8, lerp_health or max_health, player:Health())

    -- Bar dimensions - different for helmet and third person
    local hp_armor_width, hp_armor_height, stamina_width, stamina_height

    if helmet_state then
        -- HELMET MODE - keep original dimensions
        hp_armor_width = 200   -- Original width
        hp_armor_height = 45   -- Original height
        stamina_width = 180    -- Original stamina width
        stamina_height = 12    -- Original stamina height
    else
        -- THIRD PERSON MODE - use new dimensions like in screenshot
        hp_armor_width = 280   -- Longer
        hp_armor_height = 20   -- Lower height
        stamina_width = 280   -- Smaller stamina width
        stamina_height = 5    -- Keep stamina height
    end

    local health_x, health_y, armor_x, armor_y
    local info_x, info_y, info_align

    if helmet_state then
        -- HELMET MODE - keep original positioning
        health_x = W / 2 - 420
        health_y = H - 120
        armor_x = W / 2 + 220
        armor_y = H - 120

        -- Player info centered
        info_x = W / 2
        info_y = 80
        info_align = TEXT_ALIGN_CENTER
    else
        -- THIRD PERSON MODE - positioning for stacked bars
        health_x = 30           -- Left side positioning
        health_y = H - 100      -- Higher up
        armor_x = 30            -- Same X as health
        armor_y = H - 65        -- Below health

        info_x = 30             -- Left aligned
        info_y = H - 150        -- Above the bars
        info_align = TEXT_ALIGN_LEFT
    end

    -- Player name and team
    DrawShadowText(player:Name(), "hud_name", info_x, info_y, COLORS.text_bright, info_align)
    DrawShadowText(team.GetName(player:Team()), "hud_team", info_x, info_y + 25, COLORS.text_dim, info_align)


    surface.SetDrawColor(COLORS.primary)
    surface.DrawOutlinedRect(W - 1890, H - 250, 300, 90, 1)
    DrawRoundedBox(0,W - 1890,H - 250, 300, 90, COLORS.bg_dark)
    if NextRP.MoneyHUD and NextRP.MoneyHUD.DrawMoney then
        NextRP.MoneyHUD:DrawMoney(W - 1880,H - 295, TEXT_ALIGN_LEFT)
    end

    -- Health bar
    if helmet_state then
        -- HELMET MODE - original slanted bars
        DrawSlantedHealthBar(health_x, health_y, hp_armor_width, hp_armor_height, lerp_health, max_health, COLORS.health, 15)
    else
        -- THIRD PERSON MODE - slanted bars with top slant
        DrawThirdPersonHealthBar(health_x, health_y, hp_armor_width, hp_armor_height, lerp_health, max_health, COLORS.health, 20)
    end

    -- Health text - SHOW on LEFT side in third person
    if helmet_state then
        DrawShadowText(math.Round(lerp_health), "hud_values", health_x - 40, health_y + hp_armor_height/2, COLORS.text_bright, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    else
        -- Show health text on LEFT side of health bar in third person (no max HP)
        DrawShadowText(math.Round(lerp_health), "hud_values", health_x - 40, health_y + hp_armor_height/2, COLORS.text_bright, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Armor bar - only if player has armor
    max_armor = player:GetMaxArmor() or 0
    lerp_armor = Lerp(FrameTime() * 8, lerp_armor or player:Armor(), player:Armor())

    if lerp_armor > 0 then
        if helmet_state then
            -- HELMET MODE - original slanted bars
            DrawSlantedArmorBar(armor_x, armor_y, hp_armor_width, hp_armor_height, lerp_armor, max_armor, COLORS.armor, 15)
        else
            -- THIRD PERSON MODE - slanted bars with bottom slant
            DrawThirdPersonArmorBar(armor_x, armor_y, hp_armor_width, hp_armor_height, lerp_armor, max_armor, COLORS.armor, 20)
        end

        -- Armor text - SHOW on LEFT side in third person
        if helmet_state then
            DrawShadowText(math.Round(lerp_armor), "hud_values", armor_x + hp_armor_width + 40, armor_y + hp_armor_height/2, COLORS.text_bright, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            -- Show armor text on LEFT side of armor bar in third person (no max armor)
            DrawShadowText(math.Round(lerp_armor), "hud_values", armor_x - 40, armor_y + hp_armor_height/2, COLORS.text_bright, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    -- Stamina
    local stamina = player:GetNW2Int('rollStamina', 0)
    if stamina > 0 then
        local stamina_x, stamina_y
        if helmet_state then
            -- HELMET MODE - original positioning and center-filling
            stamina_x = W / 2 - stamina_width / 2
            stamina_y = H - 20
        else
            -- THIRD PERSON MODE - stacked with other bars
            stamina_x = 30
            stamina_y = H - 75
        end

        if helmet_state then
            -- HELMET MODE - center-filling stamina bar
            DrawCenterStaminaBar(stamina_x, stamina_y, stamina_width, stamina_height, stamina, 100, COLORS.stamina, 6)
        else
            -- THIRD PERSON MODE - regular segmented bar (no slant, NO BACKGROUND)
            DrawSegmentedBar(stamina_x, stamina_y, stamina_width, stamina_height, stamina, 100, COLORS.stamina, 12, false) -- false = no background
        end

        -- NO STAMINA TEXT - removed completely
    end
end

local function DrawWeapon()
    local player = LocalPlayer()
    if not player:Alive() then return end

    local weapon = player:GetActiveWeapon()
    if not IsValid(weapon) then return end

    local clip = weapon:Clip1()
    if clip < 0 then return end

    local reserve = player:GetAmmoCount(weapon:GetPrimaryAmmoType())

    -- Ammo display position - always bottom right regardless of helmet state
    local x = W - 80
    local y = H - 80

    -- Ammo in clip (large)
    DrawShadowText(clip, "hud_ammo", x, y, COLORS.text_bright, TEXT_ALIGN_RIGHT)

    -- Divider
    DrawShadowText("/", "hud_ammo", x + 10, y, COLORS.primary, TEXT_ALIGN_CENTER)

    -- Reserve ammo (smaller)
    DrawShadowText(reserve, "hud_ammo_reserve", x + 30, y + 8, COLORS.text_dim, TEXT_ALIGN_LEFT)

    -- Weapon name
    local weapon_name = weapon:GetPrintName() or weapon:GetClass()
    DrawShadowText(weapon_name, "hud_team", x, y - 30, COLORS.text_dim, TEXT_ALIGN_RIGHT)
end

local function DrawDamageNumbers()
    for k, hit in pairs(HIT_NUMBERS) do
        local screen_pos = hit.pos:ToScreen()
        local alpha = math.Clamp(hit.time * 2, 0, 255)

        DrawShadowText(math.Round(hit.damage), "hud_damage", screen_pos.x, screen_pos.y, Color(220, 60, 60, 255), TEXT_ALIGN_CENTER)

        -- Move upward and reduce time
        hit.pos.z = hit.pos.z + (0.6 * FrameTime() * 60)
        hit.time = hit.time - (FrameTime() * 2)

        -- Remove if expired
        if hit.time <= 0 then
            table.remove(HIT_NUMBERS, k)
        end
    end
end

local function DrawTargetInfo()
    -- Show distance when zoomed
    if LocalPlayer():KeyDown(IN_ZOOM) then
        local trace = LocalPlayer():GetEyeTrace()
        local distance = math.Round((trace.HitPos - LocalPlayer():GetPos()):Length())

        local x = W / 2
        local y = 50

        -- Distance display
        DrawRoundedBox(4, x - 60, y - 15, 120, 30, COLORS.bg_dark)

        surface.SetDrawColor(COLORS.primary)
        surface.DrawOutlinedRect(x - 60, y - 15, 120, 30, 1)

        DrawShadowText(distance .. " units", "hud_values", x, y, COLORS.text_bright, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function DrawMedicInfo()
        -- Получаем размеры экрана
    local scrW = ScrW()
    local scrH = ScrH()

        -- Размеры HUD элементов
    local hudWidth = 150
    local hudHeight = 147

        -- Вычисляем центральную позицию по X и нижнюю по Y
    local centerX = (scrW / 2) - (hudWidth / 2)
    local bottomY = scrH - hudHeight - 100  -- 50 пикселей отступа от низа

    surface.SetMaterial(Material("body/head.png"))
    surface.SetDrawColor(125,LocalPlayer():GetNWInt("MedicineHead")*2.5,0,100)
    surface.DrawTexturedRect(centerX, bottomY, hudWidth, hudHeight)

    surface.SetMaterial(Material("body/chest.png"))
    surface.SetDrawColor(125,LocalPlayer():GetNWInt("MedicineChest")*2.5,0,100)
    surface.DrawTexturedRect(centerX, bottomY, hudWidth, hudHeight)

    surface.SetMaterial(Material("body/arms.png"))
    surface.SetDrawColor(125,LocalPlayer():GetNWInt("MedicineArm")*2.5,0,100)
    surface.DrawTexturedRect(centerX, bottomY, hudWidth, hudHeight)

    surface.SetMaterial(Material("body/stomach.png"))
    surface.SetDrawColor(125,LocalPlayer():GetNWInt("MedicineStomach")*2.5,0,100)
    surface.DrawTexturedRect(centerX, bottomY - 1, hudWidth, hudHeight)

    surface.SetMaterial(Material("body/legs.png"))
    surface.SetDrawColor(125,LocalPlayer():GetNWInt("MedicineLeg")*2.5,0,100)
    surface.DrawTexturedRect(centerX, bottomY - 4, hudWidth, hudHeight)
end

-- Main HUD drawing function

local PlayerHide = {
    {
        title = 'Dhelm',
        func = DrawHelmetOverlay,
    },
    {
        title = 'Dcomps',
        func = DrawCompass,
    },
    {
        title = 'Dhud',
        func = DrawPlayerHUD,
    },
    {
        title = 'Dwep',
        func = DrawWeapon,
    },
    {
        title = 'Ddmg',
        func = DrawDamageNumbers,
    },
    {
        title = 'Dtrgt',
        func = DrawTargetInfo,
    }
}
local function DrawHUD()
    local player = LocalPlayer()
    if not player:Alive() then return end

    -- Check helmet state periodically to avoid performance issues
    if CurTime() - last_helmet_check > 0.1 then
        last_helmet_check = CurTime()
    end

    -- Draw helmet overlay first (if helmet is on)

    --[[for _, v in ipairs(PlayerHide) do
        if !player:GetNWBool(v.title) then
            print(v.title)
            v.func()
        end
    end]]--

    -- Draw HUD elements - position changes based on helmet state
    --[[if !player:GetNWBool('Dhelm') then
        DrawHelmetOverlay()
    end
    if !player:GetNWBool('Dcomps') then
        DrawCompass()
    end
    if !player:GetNWBool('Dhud') then
        DrawPlayerHUD()
    end
    if !player:GetNWBool('Dwep') then
        DrawWeapon()
    end
    if !player:GetNWBool('Ddmg') then
        DrawDamageNumbers()
    end]]--
    if !player:GetNWBool('Dtrgt') then
        DrawTargetInfo()
    end
    --if !player:GetNWBool('DMM') then
        --DrawMedicInfo()
    --end
end

-- Register hit network receiver
--[[net.Receive("testhit", function()
    local dmg = net.ReadFloat()
    local pos = net.ReadVector()
    local target = net.ReadEntity()

    if IsValid(target) and (string.find(target:GetClass(), "npc_*") or target:IsPlayer()) then
        table.insert(HIT_NUMBERS, {
            damage = dmg,
            pos = pos,
            time = 1.5
        })
    end
end)]]--


-- Hook our HUD to the game
hook.Add("HUDPaint", "NewEnhancedHUD", DrawHUD)

-- Hide default HUD elements
local hide_elements = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudCrosshair"] = false,
    ["CHudDamageIndicator"] = true,
    ["CHudZoom"] = true,
    ["DarkRP_HUD"] = true,
    ["DarkRP_EntityDisplay"] = true,
    ["DarkRP_ZombieInfo"] = true,
    ["DarkRP_LocalPlayerHUD"] = true,
    ["DarkRP_Hungermod"] = true,
    ["DarkRP_Agenda"] = true
}

hook.Add("HUDShouldDraw", "HideDefaultHUDElements", function(name)
    if hide_elements[name] then
        return false
    end
    return true
end)

-- Hide target ID and death notices
hook.Add('HUDDrawTargetID', 'HideDrawTarget', function() return false end)
hook.Add('DrawDeathNotice', 'HideDrawDeath', function() return 0, 0 end)

print("[NEW HUD] Successfully loaded with enhanced segmented bars and positioning!")