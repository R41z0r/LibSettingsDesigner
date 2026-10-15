-- Registration search caching must preserve results and release temporary strings.
local count=0
local env=setmetatable({CaseAccentInsensitiveParse=function(text)count=count+1;return text:lower():gsub('É','e'):gsub('é','e') end},{__index=_G})
local addon={}
assert(loadfile('runtime/LibSettingsDesigner/LibSettingsDesignerConfig.lua','t',env))('Test',addon)
local config=addon.LibSettingsDesigner.Config
local function populate(app)
 app:RegisterCategory({id='category',title='Shared category'})
 app:RegisterPage({id='page',category='category',title='Shared page'})
 app:RegisterGroup('page',{id='group',title='Shared group'})
 for i=1,300 do
  app:RegisterControl('page',{id='control'..i,label='|cffffffffÉnergy|r',description='Shared description',groupID='group',keywords={'repeat',{'nested','repeat'}}})
 end
 app:RegisterControl('page',{id='control1',label='Changed label',description='Changed description'})
 app:RegisterControlNote('control1',{text='Note text',title='Note title'})
end
local plain=config:RegisterAddOn('plain',{})
count=0;populate(plain);local plainCalls=count
local cached=config:RegisterAddOn('cached',{})
cached:BeginRegistrationBatch();cached:BeginRegistrationBatch()
count=0;populate(cached);local cachedCalls=count
cached:EndRegistrationBatch();assert(cached._registrationSearchCache~=nil,'nested batch must retain cache')
for id,c in pairs(plain.controlsByID) do assert(c.searchBlob==cached.controlsByID[id].searchBlob,id) end
for _,term in ipairs({'energy','shared','nested','changed','note','no-match'}) do
 local a,b=plain:GetSearchResults(term,500),cached:GetSearchResults(term,500)
 assert(#a==#b,'search result count')
 for i=1,#a do assert(a[i].id==b[i].id,'search result order') end
end
cached:EndRegistrationBatch();assert(cached._registrationSearchCache==nil,'outer batch must release cache')
cached:RegisterControl('page',{id='late',label='Late label'})
assert(cached.controlsByID.late.searchBlob:find('late label',1,true))
cached:BeginRegistrationBatch();assert(next(cached._registrationSearchCache)==nil,'new batch starts empty');cached:EndRegistrationBatch()
assert(cachedCalls<plainCalls/4,'normalization work must drop')
print(string.format('Search metadata/results/updates/nested lifecycle passed; normalizations %d -> %d',plainCalls,cachedCalls))
