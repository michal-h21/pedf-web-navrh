-- sitemap se již nepoužívá, místo toho je pole mainmenu v web.lua

local result = {}
for line in io.lines("sitemap.tsv") do
  local x = string.explode(line, " ")
  local parts = {}
  local status = "init"
  local depth = 0
  local first = {}
  local second = {}
  for _,v in ipairs(x) do
    if v == "" and status == "init" then
      depth = depth + 1
    elseif v == "" and status == "start" then 
      status = "second"
    elseif v == "" then
    else
      v = v:gsub("[%s]","")
      if v == "" then v = nil end
      if status=="init" then status = "start" end
      if status == "start" then
        table.insert(first, v)
      else
        table.insert(second,v)
      end
    end
  end
  result[#result+1]  =  {depth, first, second}
  -- print(depth,":"..table.concat(first," ")..":"..table.concat(second," ")..":")
end
local new = {}
local depth = 0
local stack = {new}
local current = new

for _, v in ipairs(result) do
  local d = v[1]
  if d == depth then
  elseif d > depth then
    local x = {}
    if d == 2 then
      current[#current].children = x
    elseif d == 4 then
      current[#current].subchildren = x
    else
      current[#current].subsubchildren = x
    end
    table.insert(stack, x)
    current = x
  else
    for i=depth, d+1, -2 do
      table.remove(stack)
    end
    current = stack[#stack]
  end
  table.insert(current,{name=table.concat(v[2]," "),url=table.concat(v[3]," "), chidlren={}})
  depth = d
end

-- function print_r ( t ) 
--     local print_r_cache={}
--     local function sub_print_r(t,indent)
--         if (print_r_cache[tostring(t)]) then
--             print(indent.."*"..tostring(t))
--         else
--             print_r_cache[tostring(t)]=true
--             if (type(t)=="table") then
--                 for pos,val in pairs(t) do
--                     if (type(val)=="table") then
--                         print(indent.."["..pos.."] => "..tostring(t).." {")
--                         sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
--                         print(indent..string.rep(" ",string.len(pos)+6).."}")
--                     else
--                         print(indent.."["..pos.."] => "..tostring(val))
--                     end
--                 end
--             else
--                 print(indent..tostring(t))
--             end
--         end
--     end
--     sub_print_r(t,"  ")
-- end

-- print_r(new)
--
return new
