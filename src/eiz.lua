local csv = require "csv"

local raw = io.read("*all")
local data = csv.openstring(raw)
-- local data = csv.open("data/eiz.csv")
-- local data = csv.use(nil, {separator="[,]"})


local function print_header(head)
  if head ~= "" then
    print("<h2>".. head .. "</h2>")
  end
end

local function print_source(name, link)
  local name = name:gsub("^%s*", ""):gsub("%s*$", "")
  local link = link:gsub("^%s*", ""):gsub("%s*$", "")
  if name ~="" then
    print(string.format('<div><a href="%s">%s</a></div>', link, name))
  end
end

print [[
---
title: "Elektronické informační zdroje (databáze)  dostupné v r. 2018 na PedF UK"
---
<h1>Elektronické informační zdroje (databáze)  dostupné v r. 2018 na PedF UK</h1>
]]

for  rec in data:lines() do
  print_header(rec[1])
  print_source(rec[2], rec[3])
end

-- for k, x in pairs(data) do
  -- print(k,x)
-- end
--
print [[
<h2>Databáze s ukončeným přístupem</h2>
<div><a href="">V roce 2018 skončil na UK přístup k databázi ProQuest Central. Přehled knihoven, ve kterých je nadále dostupný, najdete <a href="https://www.proquest.cz/">zde</a></div>
<div><a href="">V roce 2019 skončí přístup k databázi ProQuest E-book Central, která bude nahrazena e-book Academic Collection (EBSCO).</a></div>
<h2>Další</h2>
<div><a href="https://ukaz.cuni.cz">Vyhledávání jednotlivých článků</a></div>
<div><a href="https://ckis.cuni.cz/">Vyhledávání on-line časopisů</a></div>
<div><a href="https://ckis.cuni.cz/">Vyhledávání tištěných časopisů</a>, <a href="http://knihovna.pedf.cuni.cz/periodika.htm">Seznam časopisů</a></div>
<div><a href="pez.cuni.cz">Vyhledávání celých databází</a></div>
]]
