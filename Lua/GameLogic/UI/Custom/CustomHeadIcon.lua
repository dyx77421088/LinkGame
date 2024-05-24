-- 玩家头像

local CustomHeadIcon = BaseClass(UIItem)


function CustomHeadIcon:__ctor(parent, viewbase, atlas)
    self.levText = false
    self.iconImage = false
    self.nameText = false
    self.powerText = false
    self.careerIcon = false
    self.atlas = atlas or false
    self:InitItem(parent, nil, viewbase)
end

function CustomHeadIcon:Initialize()
	self.headTrans = self:GetChild("","RectTransform")	
    if self:HasChild("Headportrai/OccupationIcon") then
        self.careerIcon = self:GetChild("Headportrai/OccupationIcon","Image")
    end
    
    if self:HasChild("Headportrai/Head") then
        self.iconImage = self:GetChild("Headportrai/Head","RawImage")
        self.iconImage.enabled = false
        self:AddOnClick(self.iconImage.gameObject, callback(self, "OnClickHeadIconHandler"))
    end
    
    if self:HasChild("nameTxt") then
        self.nameText = self:GetChild("nameTxt","Text")
    end

    if self:HasChild("powTxt") then
        self.powerText = self:GetChild("powTxt","Text")
    end

    if self:HasChild("Headportrai/lvTxt") then
        self.levText = self:GetChild("Headportrai/lvTxt", "Text")
    end

end

function CustomHeadIcon:OnClickHeadIconHandler(go)
	if(self.callBack) then
		self:callBack()
	end
end

--==============================--
--desc:
--time:2019-01-15 02:42:05
--@vo:
--@return 
--==============================--
function CustomHeadIcon:UpdateVo(vo)
    if vo then
        self:UpdateUI(vo)
    else
        self:ClearUI()
    end
end

function CustomHeadIcon:UpdateUI(vo)
    -- local pic = vo.pic
    local zid = vo.player_id
    local zcareer = vo.career
    local lev = vo.lv
    local zname = vo.name
    local power = vo.power

    self:SetLevText(lev)        
    self:SetNameText(zname)
    self:SetPowerText(power)
    self:SetIconImage(zcareer)
    self:SetCareerIcon(zcareer)
    -- self:LoadHead(pic)
end

-- php加载头像
function CustomHeadIcon:LoadHead()

end

function CustomHeadIcon:UpdateData(career,lv,callback)
	self:SetLevText(lv)
	self:SetCareerIcon(career)
	self:SetIconImage(career)
	self.callBack = callback
end

-- 设置回调方法
function CustomHeadIcon:SetClickCallBack(callback)
	self.callBack = callback
end

function CustomHeadIcon:SetDirection(value)
	local scale = Vector3(value,1,1)
	self.headTrans.localScale = scale
end


-- 设置头像图标
function CustomHeadIcon:SetIconImage( career )
    if self.iconImage then
        if not career  then
            self.iconImage.enabled = false
        elseif(career ~= 0) then
            self:LoadPlayerHead(career, self.iconImage, false)
            self.iconImage.enabled = true
        end         
    end    
end

--==============================--
--desc:设置职业图标
--time:2018-07-12 07:49:38
--@career:
--@return 
--==============================--
function CustomHeadIcon:SetCareerIcon(career)    
    if self.careerIcon then
        if not career or career == 0 or career > 10 then            
            self.careerIcon.enabled = false
        else
            Utility.LoadCareerImg(career, self.careerIcon, self.atlas)
            self.careerIcon.enabled = true
        end
        
    end    
end

--设置需要用到的图集，聊天有点特殊，需要指定图集，不用其他图集
function CustomHeadIcon:SetAtlas(atlas)
    self.atlas = atlas
end

-- 设置等级
function CustomHeadIcon:SetLevText( lev )
    if self.levText then
        if not lev or lev == 0 then
            self.levText.text = ""
        else
            local lv,transLev = Utility.GetTransLev(lev)
            self.levText.text = tostring(lv)
        end
    end    
end

-- 设置名字
function CustomHeadIcon:SetNameText( name )
    if self.nameText then
        if not name then
            self.nameText.text = ""
        else
            self.nameText.text = name
        end        
    end    
end


-- 设置战力
function CustomHeadIcon:SetPowerText( power )
    if self.powerText then
        if not power then
            self.powerText.text = string.format( "")
        else
            self.powerText.text = string.format( "战力  %s", power)
        end
    end    
end

function CustomHeadIcon:ClearUI()
    if self.levText then
        self.levText.text = ""
    end
    
    if self.nameText then
        self.nameText.text = ""
    end
    
    if self.powerText then
        self.powerText.text = ""
    end

    if self.iconImage then
        self.iconImage.enabled = false
    end
    
    if self.careerIcon then
        self.careerIcon.enabled = false
    end
end

function CustomHeadIcon:__delete()
    self.levText = false
    self.iconImage = false
    self.nameText = false
    self.powerText = false
    self.careerIcon = false
	self.callBack = false
	self.headTrans = false
end

function CustomHeadIcon:ShowSelf()
    
end

function CustomHeadIcon:HideSelf()
    self.callBack = false
end

return CustomHeadIcon