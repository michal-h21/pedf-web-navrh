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
return building_blocks
