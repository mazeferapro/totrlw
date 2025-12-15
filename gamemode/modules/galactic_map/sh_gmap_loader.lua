-- sh_gmap_loader.lua (robust loader)
-- Положи в: gamemodes/<твой_gamemode>/gamemode/modules/galactic_map/sh_gmap_loader.lua

-- гарантируем глобализацию luna
luna = luna or {}
luna.loader = luna.loader or {}

-- базовые данные для поиска
local gamemode_name = engine.ActiveGamemode() or "unknown_gm"
local module_rel = "modules/galactic_map/"

-- helper: пытаемся найти файл в нескольких вариантах
local function tryFind(path)
    -- 1) путь как задан пользователем (чаще всего это относительный путь внутри gamemode)
    if file.Exists(path, "LUA") then return path end

    -- 2) путь внутри папки gamemode/gamemode/modules/galactic_map/
    local p2 = "gamemodes/" .. gamemode_name .. "/gamemode/" .. module_rel .. path
    if file.Exists(p2, "LUA") then return p2 end

    -- 3) путь внутри gamemode/gamemode/ (если подключение ожидало ../core/...)
    local p3 = "gamemodes/" .. gamemode_name .. "/gamemode/" .. path
    if file.Exists(p3, "LUA") then return p3 end

    -- 4) как fallback — путь modules/galactic_map/... в lua/ (редко)
    local p4 = module_rel .. path
    if file.Exists(p4, "LUA") then return p4 end

    return nil
end

-- Реализация loader'ов
if SERVER then
    function luna.loader.Server(path)
        local fp = tryFind(path)
        if fp then
            include(fp)
            MsgN("[luna.loader] included server: ", fp)
        else
            MsgN("[luna.loader] MISSING server file: ", path)
        end
    end

    function luna.loader.Client(path)
        local fp = tryFind(path)
        if fp then
            AddCSLuaFile(fp)
            MsgN("[luna.loader] AddCSLuaFile: ", fp)
        else
            MsgN("[luna.loader] MISSING client file (AddCSLuaFile): ", path)
        end
    end
else -- CLIENT
    function luna.loader.Client(path)
        local fp = tryFind(path)
        if fp then
            include(fp)
            MsgN("[luna.loader] included client: ", fp)
        else
            MsgN("[luna.loader] MISSING client file (include): ", path)
        end
    end

    function luna.loader.Server(path)
        -- клиент ничего не делает с серверными файлами
    end
end

-- === дальше идут твои подключения (без изменений) ===
luna.loader.Client 'core/cl_core.lua'
luna.loader.Server 'core/sv_core.lua'

luna.loader.Client 'ui/cl_util.lua'

luna.loader.Client 'tabs/cl_gmap_admin.lua'

luna.loader.Client 'ui/cl_frame.lua'
luna.loader.Client 'ui/cl_info.lua'
luna.loader.Client 'ui/cl_planet.lua'
luna.loader.Client 'ui/cl_wrap_text.lua'
luna.loader.Client 'ui/cl_canvas.lua'
luna.loader.Client 'ui/cl_checkbox.lua'
luna.loader.Client 'ui/cl_entry.lua'
luna.loader.Client 'ui/cl_combobox.lua'
luna.loader.Client 'ui/cl_button.lua'
luna.loader.Client 'ui/cl_horiz_scroll.lua'

function GetTickets()
    return GetGlobalInt( 'Tickets', 0 )
end
