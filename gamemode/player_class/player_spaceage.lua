-- Copyright (C) Charles Leasure, Mark Dietzer, and Michael Johnson d.b.a SpaceAge - All Rights Reserved
-- See LICENSE file for more information.

local BaseClass = baseclass.Get("player_sandbox")

local PLAYER = {}

function PLAYER:SetupDataTables()
	BaseClass.SetupDataTables(self)

	hook.Run("SetupPlayerDatatables", self.Player)
	hook.Run("PostSetupPlayerDatatables", self.Player)
end

player_manager.RegisterClass("player_spaceage", PLAYER, "player_sandbox")
