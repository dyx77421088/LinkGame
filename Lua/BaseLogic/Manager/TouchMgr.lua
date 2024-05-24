--------------------------------------------------------------------------------
--     作者:yjp
--     文件描述:专门用来作为鼠标或者屏幕触碰的管理
--     创建时间:2022/05/10 
--------------------------------------------------------------------------------
local Input = UnityEngine.Input
local Screen = UnityEngine.Screen
local TouchPhase = UnityEngine.TouchPhase
local TouchMgr = Singleton("TouchMgr")

function TouchMgr:__ctor()

end

function TouchMgr:__delete()

end

function TouchMgr:Initialize()

end

function TouchMgr:IsTouchBegin()
    if ComUtils.IsMobile() then
        -- printext("IsTouchBegin: ============>", Input.touchCount, Input.GetTouch(0).phase)
        return Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began
    else--if(ComUtils.Is_Dev()) then
        return true
    -- else
    --     return Input.GetMouseButtonDown(0)
        -- return true
    end
end

function TouchMgr:IsInTouch()
    if(ComUtils.IsMobile()) then
        -- printext("IsInTouch: ============>", Input.touchCount, Input.GetTouch(0).phase)
        return Input.touchCount > 0
    else--if(ComUtils.Is_Dev()) then
        return true
    -- else
    --     return Input.GetMouseButton(0)
    end
end

function TouchMgr:IsTouchMove()
    if(ComUtils.IsMobile()) then
        return Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Moved
    elseif(not self:IsTouchInScreen()) then
        return false
    elseif(ComUtils.Is_Dev()) then
        return true
    else
        return Input.GetMouseButton(0)
        -- return true
    end
end

function TouchMgr:IsTouchEnd()
    if ComUtils.IsMobile() then
        -- printext("IsTouchEnd: ============>", Input.touchCount, Input.GetTouch(0).phase)
        return Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Ended
    else
        return Input.GetMouseButtonUp(0)
    end
end

function TouchMgr:GetTouchPosition()
    if(ComUtils.IsMobile()) then
        if(Input.touchCount > 0) then
            return CastUtils.V3toV2(Input.GetTouch(0).position)
        end
    else
        return CastUtils.V3toV2(Input.mousePosition)
    end
end

function TouchMgr:IsTouchInScreen()
    local pos = self:GetTouchPosition()
    return 0 < pos.x and pos.x < Screen.width and 0 < pos.y and pos.y < Screen.height
end

return TouchMgr