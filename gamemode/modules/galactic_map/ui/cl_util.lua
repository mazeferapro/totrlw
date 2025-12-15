surface.CreateFont( 'gmap.1', {
	font = 'Mont Bold';
	size = scale(32);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.2', {
	font = 'Mont Regular';
	size = scale(20);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.2_underline', {
	font = 'Mont Regular';
	size = scale(20);
	antialias = true;
	extended = true;
	weight = 350;
    rotary = true;
} )

surface.CreateFont( 'gmap.3', {
	font = 'Mont Bold';
	size = scale(20);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.4', {
	font = 'Mont Regular';
	size = scale(14);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.5', {
	font = 'Mont Black';
	size = scale(100);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.6', {
	font = 'Mont Bold';
	size = scale(18);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.7', {
	font = 'Mont Bold';
	size = scale(16);
	antialias = true;
	extended = true;
	weight = 350;
} )

surface.CreateFont( 'gmap.8', {
	font = 'Mont Heavy';
	size = scale(32);
	antialias = true;
	extended = true;
	weight = 350;
} )

function CountCapturedPlanets()
    local republicCount, cisCount = 0, 0

    for _, planet in pairs(GALACTIC_MAP) do
        if planet.team == 1 then
            republicCount = republicCount + 1
        elseif planet.team == 2 then
            cisCount = cisCount + 1
        end
        -- Планеты с team == 3 не учитываются
    end

    return republicCount, cisCount
end

local cachedParsedText = setmetatable({}, {__mode = 'v'})
local cachedProcessedText = setmetatable({}, {__mode = 'v'})

local function colorToString(color)
    return string.format('%d,%d,%d,%d', color.r or 255, color.g or 255, color.b or 255, color.a or 255)
end

local function textSegments(segments)
    local result = ''
    for _, segment in ipairs(segments) do
        local text = segment.text or ''
        if segment.font then
            text = string.format('<font=%s>%s</font>', segment.font, text)
        end
        if segment.color then
            text = string.format('<color=%s>%s</color>', colorToString(segment.color), text)
        end
        result = result .. text
    end
    return result
end

function draw.markupText(options)
    local text
    if type(options.text) == 'table' then
        text = cachedProcessedText[options.text]
        if not text then
            text = textSegments(options.text)
            cachedProcessedText[options.text] = text
        end
    else
        text = options.text or ''
        if options.font then
            text = string.format('<font=%s>%s</font>', options.font, text)
        end
        if options.color then
            text = string.format('<color=%s>%s</color>', colorToString(options.color), text)
        end
    end

    local parsed = cachedParsedText[text]
    if not parsed then
        parsed = markup.Parse(text)
        cachedParsedText[text] = parsed
    end

    parsed:Draw(
        options.x or 0,
        options.y or 0,
        options.alignX or TEXT_ALIGN_LEFT,
        options.alignY or TEXT_ALIGN_TOP,
        options.alpha or 255
    )
end

-- Example:
--[[
    draw.markupText({
        text = {
            {text = 'Привет, ', font = 'DermaLarge', color = {r = 255, g = 0, b = 0}},
            {text = 'мир!', font = 'DermaDefault', color = {r = 0, g = 255, b = 0}}
        },
        x = ScrW() / 2,
        y = ScrH() / 2,
        alignX = TEXT_ALIGN_CENTER,
        alignY = TEXT_ALIGN_CENTER
    })
--]]

local scrW, scrH = ScrW(), ScrH()
local blur, white = Material( 'pp/blurscreen' ), Color( 255, 255, 255 )
function draw.Blur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor( white )
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat( '$blur', (i / 3) * (amount or 6) )
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end