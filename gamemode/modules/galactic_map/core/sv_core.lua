util.AddNetworkString( 'GMap:Menu' )
util.AddNetworkString( 'GMap:SyncAllPlayers' )
util.AddNetworkString( 'GMap:GetInfoConfig' )
util.AddNetworkString( 'GMap:GetInfoConfigOrderFrom' )
util.AddNetworkString( 'GMap:GetInfoConfigWarCompany' )

local function syncAll()
    net.Start( 'GMap:SyncAllPlayers' )
        net.WriteTable( GMap.Planets )
    net.Broadcast()
end

local function updateTickets()
    local totalTickets = 0
    for _, planet in pairs(GALACTIC_MAP) do
        if planet.team == 1 then
            totalTickets = totalTickets + (tonumber(planet.price) or 0)
        end
    end
    SetTickets(totalTickets)
end

net.Receive( 'GMap:GetInfoConfig', function( _, p)
    if not p:IsSuperAdmin() then p:ChatPrint('Вы не админ') return end

    local curPlanet = net.ReadInt(10)
    local warInfo = net.ReadTable()
    local planetPrice = net.ReadString()
    local warCompleted = net.ReadTable()
    local status = net.ReadString()
    local fProgress = net.ReadString()
    local sProgress = net.ReadString()

    GMap.Planets[curPlanet] = {
        ['WarInfo'] = warInfo,
        ['Status'] = status,
        ['PlanetPrice'] = planetPrice,
        ['Completed'] = warCompleted,
        ['firstProgress'] = fProgress,
        ['secondProgress'] = sProgress,
    }

    local mainTable = GALACTIC_MAP[curPlanet]
    mainTable.price = tonumber(planetPrice)
    updateTickets()

    syncAll()
end )

net.Receive( 'GMap:GetInfoConfigOrderFrom', function(_, p)
    if not p:IsSuperAdmin() then p:ChatPrint('Вы не админ') return end

    local desc = net.ReadString()
    local headerdesc = net.ReadString()

    GMap.Planets['OrderDescription'] = desc
    GMap.Planets['HeaderDescription'] = headerdesc

    syncAll()
end )

net.Receive( 'GMap:GetInfoConfigWarCompany', function(_, p)
    if not p:IsSuperAdmin() then p:ChatPrint('Вы не админ') return end

    local desc = net.ReadString()
    local headerdesc = net.ReadString()

    GMap.Planets['WarCompanyDesc'] = desc
    GMap.Planets['HeaderWarCompany'] = headerdesc

    syncAll()
end )

function SetTickets( value )
    if not value or not isnumber( value ) then return end

    SetGlobalInt( 'Tickets', value )
end

function TakeTickets( value )
    if not value or not isnumber( value ) then return end

    local tickets = GetTickets()
    SetGlobalInt( 'Tickets', tickets - value )
end

function AddTickets( value )
    if not value or not isnumber( value ) then return end

    local tickets = GetTickets()
    SetGlobalInt( 'Tickets', tickets + value )
end

hook.Add( 'InitPostEntity', 'GMap:Tickets', function()
    updateTickets()
end )

hook.Add( 'PlayerInitialSpawn', 'GMap:LoadConfig', function( ply )
    -- Дефолт проблема нэтов, что не успевают загружать игроку данные
    timer.Simple( 0.5, function()
        net.Start( 'GMap:SyncAllPlayers' )
            net.WriteTable( GMap.Planets )
        net.Send( ply )
    end )
end )

