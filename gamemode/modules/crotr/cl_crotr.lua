local uii = {}

uii.UI = uii.UI or nil

local LIB = PAW_MODULE('lib')

local tBought = nil

local nCRotR = nil

function uii:open()
    if IsValid(uii.UI) then uii.UI:Remove() end

    uii.UI = TDLib('DFrame')
        :ClearPaint()
        :On('Paint', function(s, w, h)
            surface.SetMaterial(NextRP.Style.Materials.CharacterSystemBackground)
            surface.SetDrawColor(150, 150, 150, 255)

            surface.DrawTexturedRect(0, 0, w, h)

            surface.SetDrawColor(NextRP.Style.Theme.Accent)
            surface.DrawRect(0, 0, w, 5)
            surface.DrawRect(0, h - 5, w, 5)
        end)
    uii.UI:SetSize(ScrW()/1.5, ScrH()/1.5)
    uii.UI:Center()
    uii.UI:MakePopup()
    uii.UI:SetTitle('')
    uii.UI:ShowCloseButton(false)
    uii.UI:SetDraggable(false)

    local antispace = TDLib('DPanel', uii.UI)
		:ClearPaint()
		antispace:SetPos(0, 0)
		antispace:SetSize(uii.UI:GetWide(), 64)

	local header = TDLib('DPanel', antispace)
	    :ClearPaint()
	    :SmartStick(TOP, 0, 10)
	    header:SetSize(antispace:GetX(), 32)

	local sText = LocalPlayer():FullName()..'. CRotRss: '..nCRotR

	local name = TDLib('DPanel', header)
        :ClearPaint()
        :Stick(LEFT)
        :Text(sText, 'font_sans_21')
    name:SetSize(surface.GetTextSize(sText)+50)

	local close = TDLib('DButton', header)
		:Text('', 'font_sans_16')
		:SetRemove(uii.UI)
		:ClearPaint()
		:Stick(RIGHT)
		:Background(Color(40,40,40, 200))
		:FadeHover()
		:On('Paint', function(s, w, h)
			surface.SetDrawColor(color_white)
		    surface.SetMaterial(PawsUI.Materials.CloseButton)
		    surface.DrawTexturedRect(12, 12, w-24, h-24)
		end)

	close:SetSize(32,32)

	local SLOT_PRICE = NextRP.CRotR.Config.SlotPrice -- Берем цену из конфига

    local buySlot = TDLib('DButton', header)
        :Text('Купить слот ('..SLOT_PRICE..' CRotR)', 'font_sans_16')
        :ClearPaint()
        :SmartStick(RIGHT, 0, 0, 5) -- Сдвигаем влево на 5 от кнопки 'close'
        :Background(NextRP.Style.Theme.Accent) -- Выделяем кнопку акцентным цветом
        :FadeHover(Color(255, 255, 255, 50))
        :On('DoClick', function()
            -- Вызов функции покупки слота с ценой из конфига
            BuySlot(SLOT_PRICE)
        end)

    buySlot:SetSize(surface.GetTextSize('Купить слот ('..SLOT_PRICE..' CRotR)')+30, 32)

	if NextRP.CRotR:IsAdmin(LocalPlayer()) then
    	local admin = TDLib('DButton', header)
			:Text('Управление', 'font_sans_16')
			:SetRemove(uii.UI)
			:ClearPaint()
			:SmartStick(RIGHT, 0, 0, 5)
			:Background(Color(40,40,40, 200))
			:FadeHover()
			:On('Paint', function(s, w, h)
				surface.SetDrawColor(color_white)
			end)
			:On('DoClick', function()
				netstream.Start('NextRP::AddCRotRs', nil, nil)
			end)

		admin:SetSize(surface.GetTextSize(admin:GetText())+20,32)
    end

    local pn = uii:chars(uii.UI)
end


function uii:chars(pnl)
    local content = TDLib('DPanel', pnl)
        :ClearPaint()
        :SmartStick(FILL, 0, 15)

    content:SetPos(0, 0)
    content:SetSize(pnl:GetWide(), pnl:GetTall())

   	local iPos = 1

   	local jb = table.Copy(NextRP.CRotR.Config.Jobs)
   	local InLine = NextRP.CRotR.Config.InLine

   	local nIterCount = math.ceil(#jb/InLine)

   	if !nIterCount or nIterCount == nil or nIterCount < 1 then return end

   	for _ = 1, nIterCount do

	    local charBase = TDLib('DHorizontalScroller', content)
	        :SmartStick(TOP, 0,15,0,0)
	        :ClearPaint()
	        :DivTall(nIterCount + .35)

	    charBase:SetOverlap(-13)
	    -- Добавляем панели с персонажами
    	-- TODO: Сделать код не таким говном
	    for i = iPos, #jb do
	    	if i > InLine then for iter = 1, InLine do table.remove(jb, 1) end break end
	    	--iPos = i
	    	local job = jb[i]
	    	if not job then break end
	        local char = TDLib('DPanel')
	            :ClearPaint()
	            :Background(Color(47, 54, 64, 25))

	        char:SetWide((charBase:GetWide() - (13*InLine)) / InLine)

	        charBase:AddPanel(char) -- Добавить в скроллер

	        local tJob = NextRP.GetJobByID(job.id)
	        local formatedName = {}
	        formatedName[#formatedName + 1] = tJob.default_rank
	        if job.useNumber then
	            formatedName[#formatedName + 1] = LocalPlayer():GetNumber()
	        end
	        formatedName[#formatedName + 1] = LocalPlayer():GetName()

	        formatedName = table.concat(formatedName, ' ')

	        local status = TDLib('DPanel', char)
	        	:SmartStick(BOTTOM, 0, 0, 0, 5)
	            :ClearPaint()
	            :DualText(tBought[job.id] and '' or 'CRotRов: '..job.price, 'font_sans_21', nil, tBought[job.id] and 'ПРИОБРЕТЕНО' or formatedName, tBought[job.id] and 'font_sans_32' or 'font_sans_24', tBought[job.id] and Color(255,0,0) or nil, TEXT_ALIGN_CENTER)
	        status:SetTall(tBought[job.id] and 40 or 70)

	        local model
	        local rank = tJob.ranks[tJob.default_rank]
	        if not rank then
	            model = 'models/gman_high.mdl'
	        else
	            model = istable(rank.model) and table.Random(rank.model) or rank.model
	        end
	        local icon = TDLib( 'DModelPanel', char )
	            :Stick(FILL)

	        icon:SetModel( model or 'models/gman_high.mdl' )
	        icon:SetFOV(25)

	        local headpos = ((icon.Entity:GetBonePosition(icon.Entity:LookupBone('ValveBiped.Bip01_Head1') or 0)) - Vector(0,0,5)) or Vector(0, 0, 0)

	        icon:SetLookAt(headpos)
	        icon:SetCamPos(headpos - Vector(-45, 0, 0))


	        function icon:LayoutEntity( Entity )
	            return
	        end

	        local chooseButton = TDLib('DButton', char)
	            :ClearPaint()
	            :Text('')
	            :LinedCorners(Color(181, 181, 181), 50)
	            :On('Think', function(s)
	                s.L = LerpVector(FrameTime() * 6, s.L, headpos - Vector(s:IsHovered() and -40 or -45, 0, 0))
	                icon:SetCamPos(s.L)
	            end)
	            :On('DoClick', function()
	            	if !tBought[job.id] then
		                content:Clear()

		                local left = TDLib('DPanel', content)
		                	:ClearPaint()
		                	:Stick(LEFT)
		                	:DivWide(2)

		                local cont = TDLib('DPanel', left)
		                	:ClearPaint()
		                	:SmartStick(LEFT, left:GetWide()/4)
		                	:DivWide(1.9)

		                local icon = TDLib( 'DModelPanel', cont)
				            :Stick(FILL)

				        icon:SetModel(model or 'models/gman_high.mdl')
				        icon:SetFOV(25)


		                local right = TDLib('DPanel', content)
		                	:ClearPaint()
		                	:Stick(RIGHT)
		                	:DivWide(2)

		                local desc = TDLib('DPanel', right)
		                	:ClearPaint()
		                	:Stick(TOP)
		                	:DivWide(1.5)
		                	:DivTall(1)
		                	:On('Paint', function(s, w, h)
					            draw.DrawText(job.descText or 'Нет описания!', 'font_sans_32', 0, 5, color_white, TEXT_ALIGN_LEFT)
					        end)

	                    local back = TDLib('DButton', right)
	                        :ClearPaint()
	                        :Stick(BOTTOM, 5)
	                        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
	                        :FadeHover(Color(255, 255, 255, 50))
	                        :LinedCorners()
	                        :Text('Назад к выбору', 'font_sans_21')
	                        :FadeIn(.4)
	                        --:SetRemove(uii.UI)
	                        :On('DoClick', function()
	                            uii:open()
	                        end)

	                    back:SetTall(75)

			            local confirm = TDLib('DButton', right)
	                        :ClearPaint()
	                        :Stick(BOTTOM, 5)
	                        :Background(Color(53 - 15, 57 - 15, 68 - 15, 100))
	                        :FadeHover(Color(255, 255, 255, 50))
	                        :LinedCorners()
	                        :Text('Приобрести за '..job.price..' CRotRов', 'font_sans_21')
	                        :FadeIn(.2)
	                        :On('DoClick', function()
	                        	NextRP:Querry(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
				                'Вы действительно желаете приобрести данную профессию?.\n\n!ВНИМАНИЕ!\n\nПосле списания CRotRов эта профессия заменит Вашу текущую на этом слоте!.',
				                {
	                            	{
	                                    Text = 'Принять',
	                                    Click = function()
	                                        if nCRotR - job.price < 0 then LIB:Notify('У Вас недостаточно CRotRов!', 1, 5, LIB.Config.Colors.Red) return end
								            tBought[job.id] = true
								            local sBought = util.TableToJSON(tBought)
								            nCRotR = nCRotR - job.price
								            netstream.Start('NextRP::SpendCrotrs', sBought, nCRotR, tJob.index)
								            LIB:Notify('Вам выдана профессия "'..tJob.name..'" на текущий слот!', 0, 7, LIB.Config.Colors.Red)
			                            	uii.UI:Remove()
	                                    end
	                                },
	                            	{
	                                    Text = 'Отмена',
	                                    nil
	                                }
	                            })
	                        end)

	                    confirm:SetTall(75)
	                end
            	end)

            chooseButton.L = Vector(headpos-Vector(-45, 0, 0))
            chooseButton:SetSize(char:GetSize())
    	end
    end

    return content
end

function BuySlot(price)
    -- Проверка на стороне клиента 
    if nCRotR < price then 
        LIB:Notify('У Вас недостаточно CRotRов для покупки слота!', 1, 5, LIB.Config.Colors.Red)
        return 
    end

    -- Открываем диалог подтверждения
    NextRP:Querry(QUERY_MAT_QUESTION, NextRP.Style.Theme.Accent,
    'Вы действительно желаете приобрести дополнительный слот персонажа за '..price..' CRotRов?\n\n!ВНИМАНИЕ!\n\nСлот приобретается навсегда.',
    {
        {
            Text = 'Принять',
            Click = function()
                -- Отправляем запрос на сервер для списания средств и выдачи слота
                netstream.Start('NextRP::BuyCRotRSlot', price) -- <- Здесь передается цена
                uii.UI:Remove() 
                LIB:Notify('Запрос на покупку слота отправлен. Перезайдите на сервер, чтобы увидеть изменения.', 0, 7, LIB.Config.Colors.Green)
            end
        },
        {
            Text = 'Отмена',
            nil
        }
    })
end

netstream.Hook('NextRP::OpenCRotRMenu', function(bought, crotrs)
    tBought = util.JSONToTable(bought) or {}
    nCRotR = crotrs or 0

    uii:open()
end)