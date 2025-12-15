-- Функции для получения ссылок и цветов, просто так удобнее

hook.Add('NextRP::ConfigLoaded', 'NextRP::ConfigRelatedStuff', function()   
    function l(name)
        return NextRP.Config.Link[name]
    end
    
    function c(name)
        return NextRP.Style.Theme[name]
    end
end)