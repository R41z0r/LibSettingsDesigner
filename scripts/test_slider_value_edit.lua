-- Run from the library root: lua scripts/test_slider_value_edit.lua
local file = assert(io.open("runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua"))
local source = file:read("*a")
file:close()
local widget = assert(source:match("(local function addSliderWidget.-)function lib%._Internal%.useThemedDropdown"))

-- Model horizontal anchors so the test checks occupied space, including the
-- InputBoxTemplate left border, rather than requiring a particular anchor pair.
local function frame()
 local f = { points = {}, scripts = {}, width = 0, height = 0, shown = true }
 function f:SetSize(w, h) self.width, self.height = w, h end
 function f:SetHeight(h) self.height = h end
 function f:SetWidth(w) self.width = w end
 function f:SetPoint(point, relative, relativePoint, x)
  self.points[point] = { relative, relativePoint, x or 0 }
 end
 local function anchor(p)
  local relative, point, x = p[1], p[2], p[3]
  return (point == "LEFT" and relative:GetLeft() or point == "RIGHT" and relative:GetRight() or (relative:GetLeft() + relative:GetRight()) / 2) + x
 end
 function f:GetWidth()
  if self.points.LEFT and self.points.RIGHT then return anchor(self.points.RIGHT) - anchor(self.points.LEFT) end
  return self.width
 end
 function f:GetLeft()
  if self.points.LEFT then return anchor(self.points.LEFT) end
  if self.points.CENTER then return anchor(self.points.CENTER) - self.width / 2 end
  return 0
 end
 function f:GetRight() return self:GetLeft() + self:GetWidth() end
 function f:SetScript(event, fn) self.scripts[event] = fn end
 function f:Hide() self.shown = false end
 function f:Show() self.shown = true end
 function f:IsShown() return self.shown end
 function f:SetText(text) self.text = text end
 function f:GetText() return self.text end
 function f:SetFontObject(font) self.font = font end
 function f:GetFontObject() return self.font end
 function f:SetFocus() self.focus = true end
 function f:SetValue(value) self.value = value end
 function f:CreateTexture() return frame() end
 for _, method in ipairs({ "SetOrientation", "SetMinMaxValues", "SetValueStep", "SetObeyStepOnDrag", "SetColorTexture", "SetAutoFocus", "SetJustifyH", "SetTextInsets", "HighlightText", "EnableMouse" }) do
  f[method] = function() end
 end
 return f
end
local lib = {
 FormatControlValue = function(_, value) return tostring(value) end,
 RefreshVisibleRows = function() end,
}
local env = setmetatable({
 lib = lib, TEXT = { gold = {1, 1, 1} }, CreateFrame = frame,
}, { __index = _G })
local addSliderWidget = assert(load(widget .. "return addSliderWidget", "slider editor", "t", env))()

for _, width in ipairs({ 58, 62, 96 }) do
 local valueText = frame()
 valueText:SetSize(width, 20)
 valueText.Text = frame()
 valueText.Text.font = {} -- Distinct from InputBoxTemplate's inherited chat font.
 local row = frame()
 local value, enabled = -6, true
 local app = {
  GetControlValue = function() return value end,
  SetControlValue = function(_, _, newValue) value = newValue end,
  IsControlEnabled = function() return enabled end,
 }
 addSliderWidget(row, app, {min = -100, max = 100, step = 1}, {valueText = valueText, stepButtons = false})
 local edit = row.sliderValueEdit
 valueText.scripts.OnMouseUp()
 assert(edit:IsShown() and edit.focus and not valueText:IsShown())
 assert(edit:GetLeft() - 5 >= valueText:GetLeft(), "left border overlaps slider")
 assert(edit:GetRight() <= valueText:GetRight(), "editor spills into adjacent column")
 assert(edit:GetFontObject() == valueText.Text:GetFontObject(), "editor inherits chat font")
 -- Anchors must remain valid when the reserved value area changes width.
 valueText:SetWidth(width + 20)
 assert(edit:GetRight() <= valueText:GetRight())
 edit:SetText("-8")
 edit.scripts.OnEnterPressed()
 assert(value == -8 and row.slider.value == -8 and not edit:IsShown() and valueText:IsShown())
 valueText.scripts.OnMouseUp()
 edit:SetText("50")
 edit.scripts.OnEscapePressed()
 assert(value == -8 and not edit:IsShown() and valueText:IsShown())
 valueText.scripts.OnMouseUp()
 edit:SetText("500")
 edit.scripts.OnEditFocusLost(edit)
 assert(value == 100 and not edit:IsShown())
 enabled = false
 valueText.scripts.OnMouseUp()
 assert(not edit:IsShown(), "disabled control opened editor")
end
print("Slider editor geometry, font, resize, commit, cancel, clamp and disabled-state checks passed.")
