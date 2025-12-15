local endpoint = 'http://185.251.89.135:5000/api/v1/server/'

NextRPToken = NextRPToken or false

local function GetEndpoint(sTo)
    return endpoint..sTo
end

hook.Add('Think', 'NextRP::GetAuthToken', function()
    if not NextRPToken then
        HTTP({
            success = function(code, body)
                if code == 200 then
                    local res = util.JSONToTable(body)
                    NextRPToken = res.token
            
                    print('[NextRP Gatekeeper] Токен авторизации получен. Спасибо что используете услуги Multiverse Team!')
                    NextRP.Logger.Ready = true
                else
                    NextRP.Logger.Ready = false
                    print('[NextRP Gatekeeper] Токен авторизации не получен, эта информация передана владельцу режима.')
                end

                hook.Run('NextRP::Token')
            end,
            fail = function(reason)
                NextRP.Logger.Ready = false
                print('[NextRP Gatekeeper] Токен авторизации не получен, эта информация передана владельцу режима. Код ошибки:', reason)

                hook.Run('NextRP::Token')
            end,
            method = 'GET',
            url = GetEndpoint('auth/'..NextRP.APIServerID..'?'..NextRP.Logger.table({
                ['sv'] = NextRP.ServerVersion,
                ['gv'] = NextRP.Version,
                ['si'] = NextRP.ServerID
            })),
        })
        hook.Remove('Think', 'NextRP::GetAuthToken')  
    end
end)