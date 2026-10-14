local f=assert(io.open('runtime/LibSettingsDesigner/LibSettingsDesignerUI.lua'));local source=f:read('*a');f:close()
local function noop() end
local frames,rows={},{}
local function frame()
 local obj=setmetatable({}, {__index=function(_,k) if k=='CreateFontString' or k=='CreateTexture' then return frame end;return noop end})
 function obj:SetShown(value) self.shown=value end
 frames[#frames+1]=obj;return obj
end
local lib={_Internal={}}
lib._Internal.shouldUseMatrixRows=function(s)return s.matrix end
lib.GetGroupCustomizedCount=function()return 2 end
lib._Internal.getGroupControlLayout=function()return {controlsHeight=52,columnWidth=300,columnGap=10,entries={{control={},y=-46,column=1}}}end
local env=setmetatable({lib=lib,CreateFrame=frame,createPageLeftFrame=function(_,height)local f=frame();f.height=height;return f end,trackFrame=function(_,f)return f end,snapPoint=noop,snapSize=noop,applyBackdrop=noop,createPixelBorder=noop,setTextColor=noop,addStatusChip=frame,createCollapseArrow=frame,preparePixelTexture=noop,getPixelSize=function()return 1 end,addSettingRow=function(_,_,_,_,y)rows[#rows+1]=y;return {} end,DETAIL_COLORS={},TEXT={},ROW_SEPARATOR={1,1,1}}, {__index=_G})
local code=assert(source:match('(function lib%._Internal%.addGroupSection.-)function lib%._Internal%.getPageGroupColumnCount'))
assert(load(code,'group headers','t',env))()
for _,matrix in ipairs({true,false}) do
 for _,tabbed in ipairs({true,false}) do
  for _,collapsed in ipairs({true,false}) do
   frames,rows={},{}
   local state={matrix=matrix,tabbedGroupID=tabbed and 'test',collapsedGroups={test=collapsed},y=0}
   local _,height=lib._Internal.addGroupSection(state,{id='test'},'path')
   assert(frames[2].shown==not tabbed)
   local isCollapsed=not matrix and not tabbed and collapsed
   assert(height==(isCollapsed and 40 or (tabbed and 72 or 112)))
   assert(#rows==(isCollapsed and 0 or 1))
   if not isCollapsed then assert(rows[1]==(tabbed and -6 or -46)) end
  end
 end
end
assert(source:find('self.tabbedGroupID = nil',1,true))
print('PASS tab headers: no redundant header/gap, no hidden collapsed content, untabbed headers retained in both layouts')
