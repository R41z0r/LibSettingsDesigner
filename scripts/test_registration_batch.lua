-- Registration batches must preserve ordered metadata and sorted reads while reducing sorting.
local configPath = arg[1] or "runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua"
local addon = {}
local runtimeTable = {}
for key, value in pairs(table) do runtimeTable[key] = value end
local libraryEnv = setmetatable({ table = runtimeTable }, { __index = _G })
assert(loadfile(configPath, "t", libraryEnv))("BatchTest", addon)
local Config = addon.LibSettingsDesigner.Config
local serial = 0
local function newApp()
	serial = serial + 1
	return Config:RegisterAddOn("batch-test-" .. serial, {})
end
local function ids(entries)
	local result = {}
	for _, entry in ipairs(entries) do result[#result + 1] = entry.id or entry.text end
	return table.concat(result, ",")
end
local realSort = table.sort
local sorts, comparisons = 0, 0
local function countSort(list, comparator)
	sorts = sorts + 1
	return realSort(list, function(a, b)
		comparisons = comparisons + 1
		return comparator(a, b)
	end)
end
local function populate(app)
	app:RegisterCategory({ id = "later", title = "Later", order = 20 })
	app:RegisterCategory({ id = "first", title = "First", order = "10" })
	app:RegisterPage({ id = "later", category = "later", title = "Later", order = 20 })
	app:RegisterPage({ id = "first", category = "first", title = "First", order = 10 })
	app:RegisterGroup("first", { id = "b", title = "B", order = 20 })
	app:RegisterGroup("first", { id = "a", title = "A", order = 10 })
	app:RegisterPageNote("first", { text = "later note", order = 20 })
	app:RegisterPageNote("first", { text = "first note", order = 10 })
	app:RegisterControl("first", { id = "b", label = "Find beta", title = "Beta", order = 20, groupID = "b", default = false })
	app:RegisterControl("first", { id = "a", label = "Find alpha", title = "Alpha", order = 10, groupID = "a", default = true })
	app:RegisterControl("first", { id = "hidden", label = "Hidden", order = 1, hidden = true })
	app:RegisterControlNote("b", { text = "later control note", order = 20 })
	app:RegisterControlNote("b", { text = "first control note", order = 10 })
	app:RegisterControl("first", { id = "b", title = "Beta updated", order = 5 })
	app:RegisterPage("not a table") -- Invalid registration must retain existing behavior.
	app:RegisterCategory({ id = "later", title = "Now first", order = 1 })
	app:RegisterPage({ id = "later", order = 1 })
	app:RegisterGroup("first", { id = "b", title = "B", order = 1 })
end
local plain, batched = newApp(), newApp()
populate(plain)
batched:BeginRegistrationBatch()
runtimeTable.sort = countSort
populate(batched)
assert(sorts == 0, "Registration must defer sorting")
assert(batched:GetPage("first") == batched.pagesByID.first, "ID lookup must stay immediate")
assert(sorts == 0, "ID lookups during wrapper registration must not trigger sorting")
batched:EndRegistrationBatch()
assert(sorts == 6, "Each changed collection must be sorted once")
runtimeTable.sort = realSort
for _, pair in ipairs({
	{ plain.categories, batched.categories }, { plain.pages, batched.pages },
	{ plain.pagesByID.first.groups, batched.pagesByID.first.groups },
	{ plain.pagesByID.first.controls, batched.pagesByID.first.controls },
	{ plain.pagesByID.first.aboutNotes, batched.pagesByID.first.aboutNotes },
	{ plain.controlsByID.b.notes, batched.controlsByID.b.notes },
}) do assert(ids(pair[1]) == ids(pair[2]), "Batch must preserve existing array order") end
assert(ids(plain:GetPageControls("first")) == ids(batched:GetPageControls("first")), "Visibility filtering must agree")
assert(ids(plain:GetSearchResults("find", 20)) == ids(batched:GetSearchResults("find", 20)), "Search results must agree")
assert(batched:GetControlValue(batched.controlsByID.a) == true, "Values must remain available")

-- Nested batches and explicit flushes cannot close the outer batch or lose later writes.
local app = newApp()
app:BeginRegistrationBatch()
app:BeginRegistrationBatch()
app:RegisterPage({ id = "z", title = "Z", order = 20 })
app:RegisterPage({ id = "a", title = "A", order = 10 })
sorts = 0; runtimeTable.sort = countSort
app:EndRegistrationBatch()
assert(sorts == 0, "Inner end must not sort")
assert(app:GetDefaultPageID() == "a", "Default selection must use sorted pages during a batch")
assert(sorts == 1)
app:RegisterPage({ id = "b", title = "B", order = 5 })
app:FlushRegistrationSorts()
assert(ids(app.pages) == "b,a,z", "Explicit flush must order pending pages")
app:RegisterPage({ id = "z", order = 1 })
local beforeEnd = sorts
app:EndRegistrationBatch()
assert(sorts == beforeEnd + 1 and ids(app.pages) == "z,b,a", "Changes after an early flush must be sorted at outer end")
app:EndRegistrationBatch()
assert(sorts == beforeEnd + 1, "Unmatched end must be harmless")
app:RegisterPage({ id = "c", order = 0 })
assert(sorts == beforeEnd + 2 and app.pages[1].id == "c", "Late registration must keep immediate sorting")
runtimeTable.sort = realSort

-- Every ordered getter must expose pending mutations while the batch remains open.
for _, getter in ipairs({ "GetCategories", "GetPages", "GetPageControls" }) do
	app = newApp()
	app:BeginRegistrationBatch()
	populate(app)
	local entries = getter == "GetPageControls" and app:GetPageControls("first") or app[getter](app)
	assert(#entries > 0 and app._registrationSortLists == nil, getter .. " must flush pending order")
	app:RegisterControl("first", { id = "new", title = "New", order = -1 })
	app:EndRegistrationBatch()
	assert(app.pagesByID.first.controls[1].id == "new", "Getter must leave the batch open")
end

-- Rendering during an open batch must order raw page arrays before consuming them.
local uiPath = arg[2] or configPath:gsub("Config%.lua$", "UI.lua")
local uiFile = assert(io.open(uiPath))
local uiSource = uiFile:read("*a")
uiFile:close()
local renderCode = assert(uiSource:match("(function StateMixin:RenderContent%(.-)\nfunction StateMixin:"))
local renderApp = newApp()
renderApp:BeginRegistrationBatch()
populate(renderApp)
local StateMixin = {}
local sentinel = {}
local env = {
	StateMixin = StateMixin,
	getScrollBar = function()
		assert(renderApp._registrationSortLists == nil, "Rendering must flush pending arrays first")
		assert(ids(renderApp.pagesByID.first.controls) == ids(plain.pagesByID.first.controls))
		error(sentinel)
	end,
}
assert(load(renderCode, "RenderContent", "t", env))()
local ok, err = pcall(StateMixin.RenderContent, { app = renderApp, frame = { Scroll = {} } })
assert(not ok and err == sentinel, "Rendering must reach the first layout operation with sorted metadata")
renderApp:EndRegistrationBatch()

-- Representative large page: measure comparator work with identical final controls.
local function largePage(batch)
	local model = newApp()
	model:RegisterPage({ id = "sounds", title = "Sounds" })
	sorts, comparisons = 0, 0
	runtimeTable.sort = countSort
	if batch then model:BeginRegistrationBatch() end
	for i = 1, 600 do
		model:RegisterControl("sounds", { id = "sound-" .. i, title = "Sound " .. i, order = i, type = "toggle", default = false })
	end
	if batch then model:EndRegistrationBatch() end
	runtimeTable.sort = realSort
	return model, sorts, comparisons
end
local before, beforeSorts, beforeComparisons = largePage(false)
local after, afterSorts, afterComparisons = largePage(true)
assert(ids(before.pagesByID.sounds.controls) == ids(after.pagesByID.sounds.controls))
assert(afterSorts == 1 and beforeSorts == 600, "600 insertions must become one sort")
assert(afterComparisons < beforeComparisons / 50, "Comparator work must drop substantially")
print(("PASS: ordering, updates, notes, visibility, search, nested batches, early reads and late registration; sorts %d -> %d; comparisons %d -> %d (%.2f%% reduction)"):format(beforeSorts, afterSorts, beforeComparisons, afterComparisons, 100 * (1 - afterComparisons / beforeComparisons)))
