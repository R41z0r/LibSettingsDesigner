local addonName, addon = ...

addon.name = addonName
addon.L = addon.L or {}

local DEFAULT_PROFILE = {
	enabled = true,
	visualsEnabled = true,
	shortcutsEnabled = true,
	mode = "balanced",
	scale = 1,
	frameTitle = "Sample Settings",
	announceEnabled = true,
	announceChannel = "SAY",
	sound = 8959,
	roles = { damage = true },
	accentColor = { r = 0.96, g = 0.76, b = 0.28, a = 1 },
	roleColors = {
		tank = { r = 0.35, g = 0.55, b = 1.00, a = 1 },
		healer = { r = 0.25, g = 0.90, b = 0.45, a = 1 },
		damage = { r = 1.00, g = 0.35, b = 0.25, a = 1 },
	},
	groupColorOverrides = {
		friends = { r = 0.35, g = 0.75, b = 1.00, a = 1 },
		guild = { r = 0.25, g = 0.90, b = 0.45, a = 1 },
	},
	themePreset = "gold",
	brokerColumns = {
		{ id = "name", label = "Name", icon = 134400, formatKey = "text", visible = true },
		{ id = "zone", label = "Zone", icon = 135769, formatKey = "text", visible = true },
		{ id = "level", label = "Level", icon = 132762, formatKey = "badge", visible = false },
	},
	customGroups = {
		{ id = "friends", label = "Friends", icon = 136074, color = { r = 0.35, g = 0.75, b = 1.00, a = 1 } },
		{ id = "guild", label = "Guild", icon = 136075, color = { r = 0.25, g = 0.90, b = 0.45, a = 1 } },
	},
	shortcuts = {
		{ id = "open", label = "Open Settings", icon = 134400, formatKey = "slash" },
		{ id = "reload", label = "Reload UI", icon = 136243, formatKey = "macro" },
		{ id = "help", label = "Open Help", icon = 134227, formatKey = "slash" },
	},
	settingsWindow = { width = 1080, height = 700, locked = false, density = "compact" },
}

local function copyDefaults(source, target)
	target = target or {}
	for key, value in pairs(source) do
		if type(value) == "table" then
			target[key] = copyDefaults(value, type(target[key]) == "table" and target[key] or {})
		elseif target[key] == nil then
			target[key] = value
		end
	end
	return target
end

function addon.GetDB()
	LibSettingsDesignerSampleDB = LibSettingsDesignerSampleDB or {}
	LibSettingsDesignerSampleDB.profile = copyDefaults(DEFAULT_PROFILE, LibSettingsDesignerSampleDB.profile)
	return LibSettingsDesignerSampleDB.profile
end

function addon.ResetProfile()
	LibSettingsDesignerSampleDB = LibSettingsDesignerSampleDB or {}
	LibSettingsDesignerSampleDB.profile = copyDefaults(DEFAULT_PROFILE, {})
end

function addon.Print(message)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage("|cffd8b45fLibSettingsDesigner Sample:|r " .. tostring(message or ""))
	end
end

local loginFrame = _G.CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function()
	addon.Print("Type /lsdsample to open the sample settings menu.")
end)

function addon.RefreshPreview()
	local db = addon.GetDB()
	addon.Print(("Preview refreshed: %s, scale %.0f%%."):format(db.enabled and "enabled" or "disabled", (tonumber(db.scale) or 1) * 100))
end
