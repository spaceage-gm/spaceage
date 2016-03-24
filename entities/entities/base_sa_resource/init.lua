AddCSLuaFile("cl_init.lua")
AddCSLuaFile("info.lua")
AddCSLuaFile("shared.lua")

include("info.lua")
include("shared.lua")

local resource_network = require("resource_network")

function ENT:ServerInitialize()
	self:PhysicsInit(SOLID_VPHYSICS)
end

function ENT:GenerateResource(name, amtPerSec)
	if self.resourceNetwork == nil then
		return
	end

	local amt = amtPerSec * self.thinkTime
	self.resourceNetwork:injectResource(name, amt)
end

function ENT:ConsumeResource(name, amtPerSec)
	if self.resourceNetwork == nil then
		return false
	end

	local amt = amtPerSec * self.thinkTime
	return self.resourceNetwork:consumeResource(name, amt)
end

-- cache for performance
local mathMin = math.min

function ENT:StoreResource(resourceType, amount)
	local currentlyStored = self["Get" .. resourceType](self)

	local willStore = mathMin(self.ResourceStorage[resourceType] - currentlyStored, amount)
	self["Set" .. resourceType](self, currentlyStored + willStore)

	return willStore
end

function ENT:PullResource(resourceType, amount)
	local currentlyStored = self["Get" .. resourceType](self)

	local willConsume = mathMin(currentlyStored, amount)
	self["Set" .. resourceType](self, currentlyStored - willConsume)

	return willConsume
end

function ENT:GetResourceNetwork()
	return self.resourceNetwork
end

function ENT:IsInNetwork(target)
	return self.resourceNetwork ~= nil and self.resourceNetwork == target.resourceNetwork
end

function ENT:ResourceLink(target)
	if self.resourceNetwork == nil and target.resourceNetwork == nil then
		-- neither resource has a network, create a new network and join them

		local network = resource_network:new()

		self:JoinNetwork(network)
		target:JoinNetwork(network)

		return
	end

	if self.resourceNetwork == nil and target.resourceNetwork ~= nil then
		-- the target has a network and we don't, just join

		self:JoinNetwork(target.resourceNetwork)

		return
	end

	if self.resourceNetwork ~= nil and target.resourceNetwork == nil then
		-- we have a network and the target doesn't, just join them

		target:JoinNetwork(self.resourceNetwork)

		return
	end

	-- Remaining case: merging two networks

	error("not yet implemented")
end

function ENT:JoinNetwork(network)
	if self.resourceNetwork == network then
		-- we're already in this network
		return
	end

	if self.resourceNetwork ~= nil then
		self.resourceNetwork:removeResource(self)
	end

	if network == nil then
		self.resourceNetwork = nil
		self:SetNetworkID(0)
		return
	end

	self.resourceNetwork = network
	self.resourceNetwork:addResource(self)

	self:SetNetworkID(self.resourceNetwork.id)
end

function ENT:OnRemove()
	self:JoinNetwork(nil) -- leave our current network
end
