local addonName, addon = ...
local Designer = addon.LibSettingsDesigner
local Config = Designer and Designer.Config
local ConfigUI = Designer and Designer.UI

if not Config or not ConfigUI then
	return
end

local function DB()
	return addon.GetDB()
end

local function moveEntry(list, fromIndex, toIndex)
	if fromIndex == toIndex or not list[fromIndex] or toIndex < 1 or toIndex > #list then
		return
	end
	local entry = table.remove(list, fromIndex)
	table.insert(list, toIndex, entry)
end

local SAMPLE_NEW_TAGS = {
	["dashboard.showcase"] = true,
	["visuals.theme"] = true,
	["mode"] = true,
	["accentColor"] = true,
	["shortcuts"] = true,
}

local function getSampleVersion()
	return C_AddOns and C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"
end

local function splitVersionBadge(version)
	version = tostring(version or "")
	local base, suffix = version:match("^(.-)%-beta([%w%.%-]*)$")
	if base and base ~= "" then
		local number = tostring(suffix or ""):match("^(%d+)")
		return base, number and ("Beta " .. number) or "Beta"
	end
	base, suffix = version:match("^(.-)%-alpha([%w%.%-]*)$")
	if base and base ~= "" then
		local number = tostring(suffix or ""):match("^(%d+)")
		return base, number and ("Alpha " .. number) or "Alpha"
	end
	return version, nil
end

local app
app = Config:RegisterAddOn(addonName, {
	title = "LibSettingsDesigner Sample",
	settingsTitle = "LibSettingsDesigner Sample Settings",
	dashboardTitle = "Dashboard",
	addonFolder = addonName,
	assetRoot = "Interface\\AddOns\\LibSettingsDesignerSample\\libs\\LibSettingsDesigner\\Assets\\",
	density = "compact",
	showDensityButton = true,
	db = DB,
	locale = addon.L,
	version = function()
		return getSampleVersion()
	end,
	getSize = function()
		local window = DB().settingsWindow or {}
		return window.width, window.height
	end,
	setSize = function(width, height)
		DB().settingsWindow = DB().settingsWindow or {}
		DB().settingsWindow.width = width
		DB().settingsWindow.height = height
	end,
	getLocked = function()
		return DB().settingsWindow and DB().settingsWindow.locked == true
	end,
	setLocked = function(locked)
		DB().settingsWindow = DB().settingsWindow or {}
		DB().settingsWindow.locked = locked == true
	end,
	isNewTag = function(tagID)
		return SAMPLE_NEW_TAGS[tostring(tagID or "")] == true
	end,
	blizzardSettingsRoot = true,
	blizzardSettingsTitle = "LibSettingsDesigner Sample",
	openSettings = function()
		ConfigUI:Open(app)
	end,
	dashboard = function(_, stats)
		local versionValue, versionBadge = splitVersionBadge(getSampleVersion())
		return {
			hero = {
				title = "LibSettingsDesigner Sample",
				subtitle = "Preview dashboard cards, clickable status tiles, feature summaries, new-in-version entries, grouped rows, search, density, reset state, and info pages.",
				iconKey = "dashboard",
			},
			cards = {
				{
					title = "Dashboard Showcase",
					description = "See which dashboard blocks are available and what each click target does.",
					iconKey = "dashboard",
					pageID = "help.dashboard-showcase",
				},
				{
					title = "Behavior",
					description = "Toggles, dropdowns, multi-select rows, and dependent settings.",
					iconKey = "settingspage",
					pageID = "general.behavior",
				},
				{
					title = "Visuals",
					description = "Sliders, text input, color picker, and color override swatches.",
					iconKey = "appearance",
					pageID = "visuals.theme",
				},
				{
					title = "Version Notes",
					description = "Open a changelog-style info page from a dashboard card or version tile.",
					iconKey = "help",
					pageID = "help.changelog",
				},
			},
			status = {
				title = "Sample Status",
				tiles = function()
					return {
						{
							title = "Customized",
							value = tostring(stats.customized or 0) .. " / " .. tostring(stats.customizable or stats.controls or 0),
							atlas = "worldquest-tracker-questmarker",
							searchQuery = "scale color shortcut",
						},
						{
							title = "New",
							value = tostring(stats.newControls or 0),
							badge = "tag:new",
							atlas = "collections-icon-favorites",
							searchQuery = "tag:new",
						},
						{
							title = "Version",
							value = versionValue,
							badge = versionBadge,
							atlas = "UI-HUD-MicroMenu-Spellbook-Mouseover",
							onClick = function(state)
								if state and state.SetPage then
									state:SetPage("help.changelog")
								end
							end,
						},
						{
							title = "Shortcuts",
							value = tostring(#(DB().shortcuts or {})),
							icon = "Interface\\Icons\\INV_Misc_Note_05",
							onClick = function(state)
								if state and state.SetPage then
									state:SetPage("advanced.shortcuts")
								end
							end,
						},
					}
				end,
			},
			features = {
				enabledTitle = "Enabled Sample Pages",
				customizedTitle = "Customized Sample Pages",
				enabledBadge = ENABLED or "Enabled",
				customizedBadge = "Changed",
				limit = 5,
			},
			newEntries = {
				title = "New in this Version",
				limit = 5,
			},
		}
	end,
})

app:RegisterCategory({ id = "general", title = GENERAL or "General", iconAtlas = "communities-icon-chat", order = 100 })
app:RegisterCategory({ id = "visuals", title = "Visuals", iconAtlas = "transmog-icon-revert", order = 200 })
app:RegisterCategory({ id = "advanced", title = "Advanced", iconAtlas = "Professions-Icon-Quality-Tier5", order = 300 })
app:RegisterCategory({ id = "help", title = HELP_LABEL or "Help", iconAtlas = "QuestNormal", order = 900 })

app:RegisterPage({
	id = "general.behavior",
	category = "general",
	title = "Behavior",
	description = "Common settings rows for addon behavior.",
	mainToggleID = "enabled",
	iconKey = "settingspage",
	order = 100,
})
app:RegisterGroup("general.behavior", { id = "core", title = "Core", order = 100 })
app:RegisterGroup("general.behavior", { id = "output", title = "Output", order = 200 })

app:RegisterControl("general.behavior", {
	id = "enabled",
	key = "enabled",
	groupID = "core",
	groupTitle = "Core",
	type = "toggle",
	label = ENABLE or "Enable",
	description = "Master switch for the sample addon.",
	keywords = { "master", "on", "off" },
	default = true,
	order = 100,
	refreshOnChange = true,
})

app:RegisterControl("general.behavior", {
	id = "mode",
	key = "mode",
	groupID = "core",
	groupTitle = "Core",
	type = "dropdown",
	label = "Mode",
	description = "Single-choice dropdown with deterministic ordering.",
	newTagID = "mode",
	list = { minimal = "Minimal", balanced = "Balanced", detailed = "Detailed" },
	orderList = { "minimal", "balanced", "detailed" },
	default = "balanced",
	parentCheck = function() return DB().enabled == true end,
	order = 110,
})

app:RegisterControl("general.behavior", {
	id = "roles",
	groupID = "core",
	groupTitle = "Core",
	type = "multidropdown",
	label = "Role Filters",
	description = "Multi-select dropdown stored as a boolean map.",
	options = { tank = "Tank", healer = "Healer", damage = "Damage" },
	orderList = { "tank", "healer", "damage" },
	getSelection = function()
		DB().roles = DB().roles or {}
		return DB().roles
	end,
	setSelectedFunc = function(value, selected)
		DB().roles = DB().roles or {}
		DB().roles[value] = selected and true or nil
		addon.RefreshPreview()
	end,
	default = { damage = true },
	parentCheck = function() return DB().enabled == true end,
	order = 120,
})

app:RegisterControl("general.behavior", {
	id = "announcements",
	key = "announceEnabled",
	groupID = "output",
	groupTitle = "Output",
	type = "checkboxdropdown",
	label = "Announcements",
	description = "Combined checkbox plus dropdown row.",
	default = true,
	dropdownKey = "announceChannel",
	dropdownDefault = "SAY",
	dropdownList = { SAY = SAY or "Say", PARTY = PARTY or "Party", RAID = RAID or "Raid" },
	dropdownOrder = { "SAY", "PARTY", "RAID" },
	parentCheck = function() return DB().enabled == true end,
	order = 200,
})

app:RegisterControl("general.behavior", {
	id = "sound",
	key = "sound",
	groupID = "output",
	groupTitle = "Output",
	type = "sounddropdown",
	label = "Preview Sound",
	description = "Dropdown with menu-side sound preview buttons.",
	list = { [8959] = "Raid Warning", [847] = "Auction Window Open", [12889] = "Ready Check" },
	orderList = { 8959, 847, 12889 },
	default = 8959,
	playbackChannel = "Master",
	parentCheck = function() return DB().enabled == true end,
	order = 210,
})

app:RegisterControlNote("roles", {
	title = "Value shape",
	text = "MultiDropdown selections are stored as a boolean map. Selected values have true; deselected values are nil.",
	order = 10,
})

app:RegisterPage({
	id = "visuals.theme",
	category = "visuals",
	title = "Theme and Layout",
	description = "Visual controls for layout, text, and colors.",
	iconAtlas = "transmog-icon-revert",
	mainToggleID = "visualsEnabled",
	newTagID = "visuals.theme",
	order = 100,
})
app:RegisterGroup("visuals.theme", { id = "layout", title = "Layout", order = 100 })
app:RegisterGroup("visuals.theme", { id = "colors", title = "Colors", order = 200 })

app:RegisterControl("visuals.theme", {
	id = "visualsEnabled",
	key = "visualsEnabled",
	groupID = "layout",
	groupTitle = "Layout",
	type = "toggle",
	label = "Enable Visuals",
	description = "Makes this page appear in the dashboard enabled-feature panel.",
	default = true,
	parentCheck = function() return DB().enabled == true end,
	order = 90,
	refreshOnChange = true,
})

app:RegisterControl("visuals.theme", {
	id = "scale",
	key = "scale",
	groupID = "layout",
	groupTitle = "Layout",
	type = "slider",
	label = "Scale",
	description = "Numeric slider with formatter and runtime callback.",
	min = 0.5,
	max = 1.8,
	step = 0.05,
	default = 1,
	formatter = function(value) return string.format("%.0f%%", (tonumber(value) or 1) * 100) end,
	setValue = function(value)
		DB().scale = tonumber(value) or 1
		addon.RefreshPreview()
	end,
	parentCheck = function() return DB().enabled == true and DB().visualsEnabled == true end,
	order = 100,
})

app:RegisterControl("visuals.theme", {
	id = "frameTitle",
	key = "frameTitle",
	groupID = "layout",
	groupTitle = "Layout",
	type = "input",
	label = "Frame Title",
	description = "Text input row with max character handling.",
	default = "Sample Settings",
	maxChars = 32,
	inputWidth = 260,
	parentCheck = function() return DB().enabled == true and DB().visualsEnabled == true end,
	order = 110,
})

app:RegisterControl("visuals.theme", {
	id = "accentColor",
	key = "accentColor",
	groupID = "colors",
	groupTitle = "Colors",
	type = "colorpicker",
	label = "Accent Color",
	description = "Single color picker with alpha support.",
	newTagID = "accentColor",
	default = { r = 0.96, g = 0.76, b = 0.28, a = 1 },
	hasOpacity = true,
	getColor = function()
		local color = DB().accentColor or { r = 0.96, g = 0.76, b = 0.28, a = 1 }
		return color.r, color.g, color.b, color.a
	end,
	setColor = function(_, r, g, b, a)
		DB().accentColor = { r = r, g = g, b = b, a = a or 1 }
		addon.RefreshPreview()
	end,
	parentCheck = function() return DB().enabled == true and DB().visualsEnabled == true end,
	order = 200,
})

app:RegisterControl("visuals.theme", {
	id = "roleColors",
	key = "roleColors",
	groupID = "colors",
	groupTitle = "Colors",
	type = "coloroverrides",
	label = "Role Colors",
	description = "Multiple keyed color swatches in one setting row.",
	entries = {
		{ key = "tank", label = "Tank" },
		{ key = "healer", label = "Healer" },
		{ key = "damage", label = "Damage" },
	},
	default = {
		tank = { r = 0.35, g = 0.55, b = 1.00, a = 1 },
		healer = { r = 0.25, g = 0.90, b = 0.45, a = 1 },
		damage = { r = 1.00, g = 0.35, b = 0.25, a = 1 },
	},
	getColor = function(key)
		local color = DB().roleColors and DB().roleColors[key] or { r = 1, g = 1, b = 1, a = 1 }
		return color.r, color.g, color.b, color.a
	end,
	setColor = function(key, r, g, b, a)
		DB().roleColors = DB().roleColors or {}
		DB().roleColors[key] = { r = r, g = g, b = b, a = a or 1 }
		addon.RefreshPreview()
	end,
	colorizeLabel = true,
	parentCheck = function() return DB().enabled == true and DB().visualsEnabled == true end,
	order = 210,
})

app:RegisterPage({
	id = "advanced.shortcuts",
	category = "advanced",
	title = "Shortcuts",
	description = "A larger row type for editable ordered entries.",
	iconKey = "movementinput",
	mainToggleID = "shortcutsEnabled",
	newTagID = "shortcuts",
	order = 100,
})

app:RegisterControl("advanced.shortcuts", {
	id = "shortcutsEnabled",
	key = "shortcutsEnabled",
	type = "toggle",
	label = "Enable Shortcuts",
	description = "Makes this page appear in the dashboard enabled-feature panel.",
	default = true,
	parentCheck = function() return DB().enabled == true end,
	order = 90,
	refreshOnChange = true,
})

app:RegisterControl("advanced.shortcuts", {
	id = "shortcuts",
	type = "reorderlist",
	label = "Shortcut Order",
	description = "Add, remove, move, drag, and format controls.",
	newTagID = "shortcuts",
	rowHeight = 250,
	addButtonText = ADD or "Add",
	addPopupTitle = "Add Shortcut",
	addPopupText = "Enter a shortcut label.",
	emptyText = "No shortcuts configured.",
	maxChars = 24,
	formatOptions = { slash = "Slash Command", macro = "Macro", button = "Button" },
	formatOrder = { "slash", "macro", "button" },
	getEntries = function() return DB().shortcuts or {} end,
	addEntry = function(text)
		text = strtrim(text or "")
		if text == "" then return end
		DB().shortcuts = DB().shortcuts or {}
		DB().shortcuts[#DB().shortcuts + 1] = { id = tostring(time()) .. tostring(#DB().shortcuts + 1), label = text, icon = 134400, formatKey = "slash" }
	end,
	removeEntry = function(entryID)
		for index, entry in ipairs(DB().shortcuts or {}) do
			if entry.id == entryID then table.remove(DB().shortcuts, index) return end
		end
	end,
	moveEntry = function(fromIndex, toIndex) moveEntry(DB().shortcuts or {}, fromIndex, toIndex) end,
	setEntryFormat = function(entryID, formatKey)
		for _, entry in ipairs(DB().shortcuts or {}) do
			if entry.id == entryID then entry.formatKey = formatKey return end
		end
	end,
	parentCheck = function() return DB().enabled == true and DB().shortcutsEnabled == true end,
	order = 100,
})

app:RegisterControl("advanced.shortcuts", {
	id = "refreshPreview",
	type = "button",
	label = "Refresh Preview",
	description = "Plain action row.",
	buttonText = "Refresh",
	onClick = function() addon.RefreshPreview() end,
	parentCheck = function() return DB().enabled == true and DB().shortcutsEnabled == true end,
	order = 200,
})

app:RegisterPage({
	id = "help.dashboard-showcase",
	category = "help",
	title = "Dashboard Showcase",
	description = "What the dashboard can display and how users interact with it.",
	layout = "info",
	iconKey = "dashboard",
	newTagID = "dashboard.showcase",
	order = 80,
	content = {
		{
			title = "Dashboard Blocks",
			entries = {
				{ type = "text", text = "Hero blocks introduce the settings center and can use any app icon key." },
				{ type = "text", text = "Cards open important pages directly. This sample links to behavior, visuals, version notes, and this showcase." },
				{ type = "text", text = "Status tiles can show live values, badges, and click actions. Try the Version, New, and Shortcuts tiles on the dashboard." },
				{ type = "text", text = "Feature and new-entry panels are generated from page main toggles, customized values, and newTagID metadata." },
			},
		},
		{
			title = "Host Addon Pattern",
			entries = {
				{ type = "text", text = "Use dashboard cards for help, support, changelog, or the most common feature pages." },
				{ type = "text", text = "Use the version tile to open a changelog page, and use a new-entry tile with searchQuery = \"tag:new\"." },
			},
		},
	},
})

app:RegisterPage({
	id = "help.changelog",
	category = "help",
	title = "Version Notes",
	description = "A changelog-style info page opened from the dashboard version tile.",
	layout = "info",
	iconKey = "help",
	order = 90,
	content = {
		{
			title = "1.0.0",
			entries = {
				{ type = "text", text = "Added dashboard cards for direct navigation." },
				{ type = "text", text = "Added clickable status tiles for customized counts, new settings, version notes, and shortcut count." },
				{ type = "text", text = "Added generated enabled-feature and new-in-version panels." },
			},
		},
		{
			title = "Dashboard Click Targets",
			entries = {
				{ type = "text", text = "Version opens this page." },
				{ type = "text", text = "New applies a tag:new search query." },
				{ type = "text", text = "Shortcuts opens the editable shortcut list page." },
			},
		},
	},
})

app:RegisterPage({
	id = "help.quick-reference",
	category = "help",
	title = "Quick Reference",
	description = "Commands and notes for testing this sample.",
	layout = "info",
	iconAtlas = "QuestNormal",
	order = 100,
	content = {
		{
			title = "Slash Commands",
			entries = {
				{ type = "command", commands = { "/lsdsample" }, desc = "Toggle the settings window." },
				{ type = "command", commands = { "/lsdsample behavior" }, desc = "Open the behavior page." },
				{ type = "command", commands = { "/lsdsample visuals" }, desc = "Open the visuals page." },
				{ type = "command", commands = { "/lsdsample dashboard" }, desc = "Open the dashboard." },
				{ type = "command", commands = { "/lsdsample changelog" }, desc = "Open version notes." },
				{ type = "command", commands = { "/lsdsample reset" }, desc = "Reset the sample profile and reopen settings." },
			},
		},
		{
			title = "What to Inspect",
			entries = {
				{ type = "text", text = "Use the search field for scale, role, color, sound, or shortcut." },
				{ type = "text", text = "Change values and watch customized counters update in the sidebar, groups, and dashboard." },
			},
		},
	},
})

SLASH_LIBSETTINGSDESIGNERSAMPLE1 = "/lsdsample"
SlashCmdList.LIBSETTINGSDESIGNERSAMPLE = function(input)
	input = strtrim(input or ""):lower()
	if input == "behavior" then
		ConfigUI:Open(app, "general.behavior")
	elseif input == "visuals" then
		ConfigUI:Open(app, "visuals.theme")
	elseif input == "shortcuts" then
		ConfigUI:Open(app, "advanced.shortcuts")
	elseif input == "dashboard" then
		ConfigUI:Open(app, "dashboard")
	elseif input == "changelog" then
		ConfigUI:Open(app, "help.changelog")
	elseif input == "help" then
		ConfigUI:Open(app, "help.quick-reference")
	elseif input == "reset" then
		addon.ResetProfile()
		addon.Print("Profile reset.")
		ConfigUI:Open(app)
	else
		ConfigUI:Toggle(app)
	end
end
