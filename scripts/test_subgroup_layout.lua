-- Run from the library root: lua scripts/test_subgroup_layout.lua
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

for _, matrix in ipairs({ false, true }) do
 for _, width in ipairs({ 400, 800 }) do
  local state = { app = {}, density = 'compact', matrix = matrix }
  local controls = {
   { type = 'toggle' },
   { type = 'sectionheader', headerStyle = 'subtle', indent = 16 },
   { type = 'toggle', indent = 16 }, { type = 'toggle', indent = 16 },
   { type = 'sectionheader' }, { type = 'toggle' },
  }
  local layout = lib._Internal.getGroupControlLayout(state, { columns = 2, controls = controls }, width)
  local e = layout.entries
  local inset = matrix and 8 or 12
  assert(e[2].column == 1 and e[2].xOffset == inset + 16)
  assert(e[2].width == width - inset * 2 - 16 and e[2].height == 30)
  assert(-e[2].y >= -e[1].y + e[1].height)
  for i = 3, 4 do
   assert(-e[i].y >= -e[2].y + e[2].height)
   assert(-e[5].y >= -e[i].y + e[i].height)
  end
  assert(e[5].xOffset == inset and e[5].height == 38)
  assert(e[6].xOffset == inset and e[6].width == nil)
  if layout.columnCount == 2 then
   local leftEnd = e[3].xOffset + e[3].width
   local rightStart = e[4].xOffset + layout.columnWidth + layout.columnGap
   assert(rightStart - leftEnd == layout.columnGap)
   assert(rightStart + e[4].width == inset + 2 * layout.columnWidth + layout.columnGap)
  else
   assert(e[3].width == layout.columnWidth - 16)
  end
 end
end
print('Subgroup indentation, gutters, right edge and header flow passed in narrow/wide and matrix/standard layouts.')
