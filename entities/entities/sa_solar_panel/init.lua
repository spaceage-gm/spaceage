AddCSLuaFile("cl_init.lua")
AddCSLuaFile("info.lua")
AddCSLuaFile("shared.lua")

include("info.lua")
include("shared.lua")

function ENT:Think()
	self:CalcThinkTime()
	self:GenerateResource("energy", 200)
end
