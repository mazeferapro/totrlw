local PANEL = {}

surface.CreateFont("SummeLibrary.Radial.Content",{font="Roboto",extended=false,size=ScrH()/35,weight=600,blursize=0,scanlines=0,antialias=true})
surface.CreateFont("SummeLibrary.Radial.CenterHeader",{font="Roboto",extended=false,size=ScrH()/25,weight=700,blursize=0,scanlines=0,antialias=true})
surface.CreateFont("SummeLibrary.Radial.CenterSubHeader",{font="Roboto",extended=false,size=ScrH()/40,weight=500,blursize=0,scanlines=0,antialias=true})

function PANEL:Init()
	self.PanelScale=1.3;
	self.PanelX=ScrW()/2;
	self.PanelY=ScrH()/2;
	self.CurrentlyHovered=-1;
	self.FixedRadius=250*self.PanelScale;
	self.Title="Radial Menu"
	self.pColor=Color(255,77,77)
	self.bgColor=Color(255,255,255)
	self.contents={}
	self.CreateTime=CurTime()
end

function PANEL:SetTitle(title)
	self.Title=title
end

function PANEL:SetPrimaryColor(color)
	self.pColor=color
end

function PANEL:SetBackgroundColor(color)
	self.bgColor=color
end

function PANEL:AddContent(content)
	local a=vgui.Create("DPanel",self)
	a.content=content;
	a:SetMouseInputEnabled(false)
	a.isActHovered=false;
	a.NormalColor=Color(255,255,255)
	function a:Paint(b,c)
		local d=Color(255,255,255)
		if self.isActHovered then
			d=SquadSystem:GetPrimaryColor()
		end;
		self.NormalColor=SummeLibrary:LerpColor(FrameTime()*12,self.NormalColor,d)
		if content.display.type=="text" then
			draw.DrawText(content.display.text,"SummeLibrary.Radial.Content",b*.5,c*.3,self.NormalColor,TEXT_ALIGN_CENTER)
		elseif content.display.type=="imgur" then
			surface.SetDrawColor(self.NormalColor)
			SummeLibrary:DrawImgur(b*.25,c*.25,b*.5,b*.5,content.display.imgur)
		end
	end;
	function a:DoStuff()
		if content.func then
			content.func()
		end
		surface.PlaySound("summe/squadsystem/radial2.mp3")
	end;
	self.contents[#self.contents+1]=a;
	self.size=#self.contents;
	self.pointsPerSection=360/self.size
end

function PANEL:PerformLayout(w, h)
	for a,b in SortedPairs(self.contents)do
		local c=(a-1)*self.pointsPerSection+self.pointsPerSection/2;
		c=math.rad(c)
		local d=128*self.PanelScale;
		local e=d;
		local f=self.FixedRadius*3/4;
		local g=math.sin(c)*f;
		local h=math.cos(c)*f;
		local i=self.PanelX-d/2+g;
		local j=self.PanelY-e/2.4-h;
		b:SetSize(d,e)b:SetPos(i,j)
	end
end

function PANEL:Close()
	self:Remove()
end

function PANEL:Paint(w, h)
	do
		local a=self.FixedRadius*1.2;
		local b=360-(math.deg(math.atan2(gui.MouseX()-self.PanelX,gui.MouseY()-self.PanelY))+180)
		for c=0,359,self.pointsPerSection do
			local d=c/self.pointsPerSection;
			local e=b>=c and b<c+self.pointsPerSection;
			local f=self.FixedRadius/2;
			local g=math.abs(self.PanelX-gui.MouseX())
			local h=math.abs(self.PanelY-gui.MouseY())
			local i=math.sqrt(g^2+h^2)
			if i<f then
				if self.CurrentlyHovered != -1 then
					self:OnLeave(self.CurrentlyHovered+1)
					self:OnEnter(-1)
					self.CurrentlyHovered=-1
				end;
				e=nil
			end;
			if e and self.CurrentlyHovered != d then
				self:OnLeave(self.CurrentlyHovered+1)
				self:OnEnter(d+1)
				self.CurrentlyHovered=d
			end
		end
	end
	draw.NoTexture()
	surface.SetDrawColor(self.bgColor)
	draw.Circle(w*.5,h*.5,h*.35,100)
	draw.SimpleText(self.Title,"SummeLibrary.Radial.CenterHeader",self.PanelX,self.PanelY,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
	draw.SimpleText(self.SelectedTitle or"-","SummeLibrary.Radial.CenterSubHeader",self.PanelX,self.PanelY+ScrH()*.05,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
end

function PANEL:OnLeave(index)
	local a=self.contents[index]
	if not IsValid(a) then return end;
	self.activePanel=false;
	self.SelectedTitle="-"a.isActHovered=false
end

function PANEL:OnEnter(index)
	local a=self.contents[index]
	if index == -1 or not IsValid(a) then self.SelectedTitle="-" return end;
	self.activePanel=a;
	self.SelectedTitle=a.content.display.text;
	a.isActHovered=true;
	surface.PlaySound("summe/squadsystem/radial1.mp3")
end

function PANEL:ClearContents()
	self.contents={}
	self.contents[#self.contents+1]=panel;
	self.size=#self.contents;
	self.pointsPerSection=360/self.size;
	self.activePanel=false;
	self.SelectedTitle="-"
end

function PANEL:OnMousePressed(key)
	if key == MOUSE_LEFT then
		self:Close()
		if self.activePanel and IsValid(self.activePanel) then self.activePanel:DoStuff() end
	elseif key == MOUSE_RIGHT then
		self:Close()
	end
end

vgui.Register("SummeFixed.Radial", PANEL)