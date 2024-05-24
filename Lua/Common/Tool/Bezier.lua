local Bezier = BaseClass()

-- Init function v0 = 1st point, v1 = handle of the 1st point , v2 = handle of the 2nd point, v3 = 2nd point

-- handle1 = v0 + v1

-- handle2 = v3 + v2
--/ <summary>
--/ 起始点，第一个影响点，第二个影响点，结束点
--/ </summary>
--/ <param name="v0"></param>
--/ <param name="v1"></param>
--/ <param name="v2"></param>
--/ <param name="v3"></param>
function Bezier:__ctor(v0, v1,v2,v3)
	self.p0 = v0
	self.p1 = v1
	self.p2 = v2
	self.p3 = v3
end

function Bezier:__defaultVar()
    return {
        p0 = false,
        p1 = false,
        p2 = false,
        p3 = false,
        ti = 0,
        b0 = Vector3.zero,
        b1 = Vector3.zero,
        b2 = Vector3.zero,
        b3 = Vector3.zero,
        Ax = 0,
        Ay = 0,
        Az = 0,
        Bx = 0,
        By = 0,
        Bz = 0,
        Cx = 0,
        Cy = 0,
        Cz = 0,
    }
end

-- 0.0 >= t <= 1.0

function Bezier:GetPointAtTime(t)
    self:CheckConstant()

    local t2 = t * t

    local t3 = t * t * t

    local x = self.Ax * t3 + self.Bx * t2 + self.Cx * t + self.p0.x

    local y = self.Ay * t3 + self.By * t2 + self.Cy * t + self.p0.y

    local z = self.Az * t3 + self.Bz * t2 + self.Cz * t + self.p0.z

    return Vector3(x, y, z)

end

function Bezier:SetConstant()

    self.Cx = 3 * ((self.p0.x + self.p1.x) - self.p0.x)

    self.Bx = 3 * ((self.p3.x + self.p2.x) - (self.p0.x + self.p1.x)) - self.Cx

    self.Ax = self.p3.x - self.p0.x - self.Cx - self.Bx

    self.Cy = 3 * ((self.p0.y + self.p1.y) - self.p0.y)

    self.By = 3 * ((self.p3.y + self.p2.y) - (self.p0.y + self.p1.y)) - self.Cy

    self.Ay = self.p3.y - self.p0.y - self.Cy - self.By

    self.Cz = 3 * ((self.p0.z + self.p1.z) - self.p0.z)

    self.Bz = 3 * ((self.p3.z + self.p2.z) - (self.p0.z + self.p1.z)) - self.Cz

    self.Az = self.p3.z - self.p0.z - self.Cz - self.Bz

end

-- Check if self.p0, self.p1, self.p2 or self.p3 have changed

function Bezier:CheckConstant()
    if (self.p0 ~= self.b0 or self.p1 ~= self.b1 or self.p2 ~= self.b2 or self.p3 ~= self.b3) then 
        self:SetConstant()
        self.b0 = self.p0
        self.b1 = self.p1
        self.b2 = self.p2
        self.b3 = self.p3
    end
end

local Bezier2 = function(startPos, controlPos, endPos, t)
    return startPos * (1 - t) * (1 -t)  + controlPos * 2 * t * (1 - t)  + endPos * t * t 
end
function Bezier:Bezier2Path(pointCount)
    local pointList = {}
    for i = 1, pointCount do
        local t = i / pointCount
        table.insert(pointList, Bezier2(self.p0, self.p1, self.p2, t))
    end
    return pointList
end

local Bezier3 = function(startPos, controlPos1, controlPos2, endPos, t)
    local t2 = 1 - t
    return startPos * t2 * t2 * t2  + controlPos1 * 3 * t * t2 * t2  + controlPos2 * 3 * t * t * t2  + endPos * t * t * t
end
function Bezier:Bezier3Path(pointCount)
    local pointList = {}
    for i = 1, pointCount do
        local t = i / pointCount
        table.insert(pointList, Bezier3(self.p0, self.p1, self.p2, self.p3, t))
    end
    return pointList
end

return Bezier
