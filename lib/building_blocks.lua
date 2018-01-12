local building_blocks = {}
local h5tk = require "h5tk"
-- local css = require "css"

local h = h5tk.init(true)

local a, p, div, header, section = h.a, h.p, h.div, h.header, h.section


function building_blocks.row(content)
  return h.div{class="row", content}
end

function building_blocks.class(tab)
  if type(tab) == "table" then
    return table.concat(tab, " ")
  end
  return tab
end

-- don't use column directly
function building_blocks.column(typ, content)
  local typ = typ or "col-med"
  return div{ class=building_blocks.class{"col-sm-12", typ}, content }
end

-- use
function building_blocks.medium(width, content)
  local width = width or 6
  return building_blocks.column("col-md-" .. width, content)
end

function building_blocks.card(content)
  return div {class="card fluid", section {class = "section", content}}
end

function building_blocks.tab(name, label, content, checked)
  return {h.input{type="radio", name="tab-group", id=name,checked=checked, ["aria-hidden"] = true},
  h.label {["for"] = name, ["aria-hidden"]=true, label},
  div{content}
  }
end

function building_blocks.boxik(title, content)
  return building_blocks.medium(3,card {h.h3 {title}, {content} })
end

function building_blocks.print_actual(items)
  local t = {}
  for i, item in ipairs(items) do
    local akt_title = item.akt_title or ""
   table.insert(t, h.h3{item.date  .. " – " ..akt_title})
   -- table.insert(t, h.p{h.small {item.date}})
   table.insert(t, item.contents)
   if i < #items then table.insert(t, h.hr{}) end
  end
  return t
end
return building_blocks
