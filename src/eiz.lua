local csv = require "csv"

local raw = io.read("*all")
local data = csv.openstring(raw)
-- local data = csv.open("data/eiz.csv")
-- local data = csv.use(nil, {separator="[,]"})


local ul = "<ul>"
local endul = ""
local function print_header(head)
  if head ~= "" then
    print(endul)
    print("<h2>".. head .. "</h2>")
    print(ul)
    endul="</ul>"
  end
end

local function print_source(name, link)
  local name = name:gsub("^%s*", ""):gsub("%s*$", "")
  local link = link:gsub("^%s*", ""):gsub("%s*$", "")
  if name ~="" then
    print(string.format('<li><a href="%s">%s</a></li>', link, name))
  end
end

print [[
---
title: "Elektronické informační zdroje (databáze)  dostupné v r. 2018 na PedF UK"
---
<h1>Elektronické informační zdroje (databáze)  dostupné v r. 2018 na PedF UK</h1>
]]


local first = true
for  rec in data:lines() do
  if not first then
    print_header(rec[1])
    print_source(rec[2], rec[3])
  end
  first = false
end


print(endul)
-- for k, x in pairs(data) do
  -- print(k,x)
-- end
--
print [[
<h2>Databáze s ukončeným přístupem</h2>
<ul>
<li>V roce 2018 skončil na UK přístup k databázi ProQuest Central. Přehled knihoven, ve kterých je nadále dostupný, najdete <a href="https://www.proquest.cz/">zde</a>.</li>
<li>V roce 2019 skončí přístup k databázi ProQuest E-book Central, která bude nahrazena e-book Academic Collection (EBSCO).</li>
</ul>
<h2>Další</h2>
<ul>
<li><a href="https://ukaz.cuni.cz">Vyhledávání jednotlivých článků</a></li>
<li><a href="https://ckis.cuni.cz/">Vyhledávání on-line časopisů</a></li>
<li><a href="http://sfx.is.cuni.cz/sfxlcl3/az/ukall">Vyhledávání tištěných časopisů</a></li> 
<li><a href="https://pez.cuni.cz">Vyhledávání celých databází</a></li>
</ul>
]]
