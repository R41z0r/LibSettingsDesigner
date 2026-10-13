-- Search navigation must retain focus with synchronous and deferred text events.
local path = arg[1] or "runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua"
local file = assert(io.open(path))
local source = file:read("*a")
file:close()

for _, highlightControl in ipairs({ false, true }) do
	for _, deferred in ipairs({ false, true }) do
		local queue = {}
		local lib = {
			_Internal = {
				hideSearchPreview = function() end,
				showSearchPreview = function() end,
				storeCategoryTabPage = function() end,
			},
		}
		local StateMixin = {}
		local env = setmetatable({
			lib = lib,
			StateMixin = StateMixin,
			getScrollBar = function() return nil end,
		}, { __index = _G })
		env._G = { C_Timer = { After = function(_, fn) queue[#queue + 1] = fn end } }

		-- Exercise production navigation and notification code with both event orders.
		local code = assert(source:match("(function lib.ScrollToControlRow.-)local function clearContent"))
		assert(load(code, "focus", "t", env))()
		code = assert(source:match("(function StateMixin:SetPage%(.-)function StateMixin:SetDensity"))
		assert(load(code, "page", "t", env))()

		local box = { text = "test", scripts = {} }
		function box:GetText() return self.text end
		function box:SetScript(key, fn) self.scripts[key] = fn end
		function box:SetText(text)
			self.text = text
			if deferred then
				queue[#queue + 1] = self.scripts.OnTextChanged
			else
				self.scripts.OnTextChanged()
			end
		end
		local frame = {
			Scroll = {
				GetVerticalScrollRange = function() return 1000 end,
				SetVerticalScroll = function(self, value) self.value = value end,
			},
			SearchBox = box,
			IsShown = function() return true end,
		}
		local state = setmetatable({
			frame = frame,
			app = { GetPage = function() return { id = "page" } end },
		}, { __index = StateMixin })
		function state:SaveCurrentContentScroll() end
		function state:ResolveFocusControlID() return "target" end
		local rendered, flashed = 0, 0
		function state:RenderContent()
			rendered = rendered + 1
			self.controlFocusGeneration = (self.controlFocusGeneration or 0) + 1
			self.controlRows = { { control = { id = "target" }, row = { _LibSettingsDesignerContentY = -200 } } }
			lib.FocusPendingControl(self)
		end
		function lib.FlashControlRow() flashed = flashed + 1 end

		code = assert(source:match('(frame.SearchBox:SetScript%("OnTextChanged".-)frame.SearchBox:SetScript%("OnEscapePressed"'))
		assert(load("return function(frame, state) " .. code .. " end", "handler", "t", env))()(frame, state)
		state:SetPage("page", "target", highlightControl)
		while #queue > 0 do
			local fn = table.remove(queue, 1)
			fn()
		end
		assert(frame.Scroll.value == 184, "Both direct links and search must scroll to the control")
		assert(rendered == 1, "Programmatic search clear must not rebuild the target page")
		assert(flashed == (highlightControl and 1 or 0), "Only search navigation must highlight the target")
		print(deferred and "deferred" or "synchronous", "search=" .. tostring(highlightControl), "flashes=" .. flashed)
	end
end
