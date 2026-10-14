-- Run from the library root: lua scripts/test_inline_hint_layout.lua
local file = assert(io.open('runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua'))
local source = file:read('*a')
file:close()
local lib = { _Internal = {} }
local env = setmetatable({
	lib = lib,
	getControlType = function(control) return control.type end,
	getControlLayoutType = function() return 'boolean' end,
	BOOLEAN_ROW_HEIGHT = 52,
}, { __index = _G })
lib.IsCompactDensity = function(state) return state.density == 'compact' end
lib._Internal.shouldUseMatrixRows = function(state) return state.matrix end
lib._Internal.resolveOptionValue = function(value) return value end
local code = assert(source:match('(function lib%._Internal%.getInlineHintHeight.-)local function getFieldControlWidth'))
code = code .. assert(source:match('(function lib%._Internal%.resolveLayoutNumber.-)function lib%._Internal%.addGroupSection'))
assert(load(code, 'inline hint layout', 't', env))()
local created = 0
local frame = {}
function frame:CreateFontString()
	created = created + 1
	return {
		Hide = function() end,
		SetWidth = function(self, value) self.width = value end,
		SetWordWrap = function() end,
		SetHeight = function(_, value) assert(value == 0) end,
		SetMaxLines = function(_, value) assert(value == 0) end,
		SetNonSpaceWrap = function(_, value) assert(value == true) end,
		SetText = function(self, value) self.text = value end,
		GetStringHeight = function(self) return math.ceil(#self.text * 7 / self.width) * 14 end,
	}
end
for _, density in ipairs({ 'compact', 'comfortable' }) do
	for _, matrix in ipairs({ false, true }) do
		local state = { frame = frame, app = {}, density = density, matrix = matrix }
		local hint = { type = 'inlinehint', label = string.rep('Long localized hint ', 15) }
		local group = { columns = 2, controls = {
			{ type = 'toggle' }, { type = 'toggle' }, { type = 'toggle' },
			hint, { type = 'toggle' }, { type = 'toggle' },
		} }
		local narrowHeight
		for _, width in ipairs({ 400, 800 }) do
			local layout = lib._Internal.getGroupControlLayout(state, group, width)
			local entry = layout.entries[4]
			assert(entry.width == width - (matrix and 16 or 24))
			assert(entry.height == lib._Internal.getInlineHintHeight(hint, state, entry.width))
			for i = 1, 3 do
				local previous = layout.entries[i]
				assert(-entry.y >= -previous.y + previous.height)
			end
			for i = 5, 6 do assert(-layout.entries[i].y >= -entry.y + entry.height) end
			if width == 400 then narrowHeight = entry.height else assert(narrowHeight > entry.height) end
		end
	end
end
assert(created == 4, 'measurement font must be reused per state')
print('Inline hint wrapping and full-width flow passed in both densities and layout modes.')
