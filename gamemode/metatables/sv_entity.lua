-- Copyright (C) Charles Leasure, Mark Dietzer, and Michael Johnson d.b.a SpaceAge - All Rights Reserved
-- See LICENSE file for more information.

include("../utilities/planet_util.lua")
include("../utilities/sorted_set.lua")

local ENTITY = FindMetaTable("Entity")

function ENTITY:InitializeSpaceAge()
	if self.planets == nil then
		self.planets = sorted_set.new(planet_util.compare)
	end
end

function ENTITY:EnteredPlanet(planet)
	if self.planets == nil then
		self:InitializeSpaceAge()
	end

	self.planets:insert(planet)

	return self:ApplyPlanet(self.planets[#self.planets])
end

function ENTITY:ExitedPlanet(planet)
	self.planets:remove(planet)

	return self:ApplyPlanet(self.planets[#self.planets])
end

-- if an entity's gravity is set to 0, the engine converts it to 1
local ENTITY_NOGRAVITY = 0.00001

function ENTITY:ApplyPlanet(planet)
	if planet == nil then
		local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableDrag(false)
			phys:EnableGravity(false)
		end

		self:SetGravity(ENTITY_NOGRAVITY)
		return
	end

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableDrag(true)
		phys:EnableGravity(true)
	end

	local gravity = planet:GetPlanetGravity()
	if gravity == 0 then
		self:SetGravity(ENTITY_NOGRAVITY)
	else
		self:SetGravity(gravity)
	end
end
