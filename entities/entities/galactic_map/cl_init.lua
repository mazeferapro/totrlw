include('shared.lua')

-- Создаём шрифты для текста
surface.CreateFont("LunaNPC1", {
    font = "Trebuchet24",
    size = 40,
    weight = 700,
    antialias = true
})

surface.CreateFont("LunaNPC2", {
    font = "Trebuchet24",
    size = 25,
    weight = 500,
    antialias = true
})

-- Локальная таблица luna для хранения названий шрифтов
local luna = {}
luna.NPC1 = "LunaNPC1"
luna.NPC2 = "LunaNPC2"

function ENT:Draw()
    self:DrawModel()
end
local function DrawShadowText(text, font, x, y, color, xalign, yalign)
    -- сначала чёрная тень
    draw.SimpleText(text, font, x+1, y+1, Color(0,0,0,255), xalign, yalign)
    -- потом основной текст
    draw.SimpleText(text, font, x, y, color, xalign, yalign)

        cam.Start3D2D(self:GetPos()+self:GetUp()*50, Ang, 0.05)
            pcall(function() render.PushFilterMin(TEXFILTER.ANISOTROPIC) end)
DrawShadowText('Галактическая Карта', luna.NPC1, -3, 0, COLOR_SECONDARY, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
DrawShadowText( 'Актуальная информация по военной компании', luna.NPC2, -3, 70,  COLOR_SECONDARY, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

    if self:GetPos():Distance(LocalPlayer():GetPos()) < 300 then
        local Ang = LocalPlayer():GetAngles()
        cam.End3D2D()
    end
end