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
    local alt = item.alt
    local src = item.img
    if not src then
      src = "/img/default.jpg"
      alt = "Foto: Kimberly Farmer/Unsplash"
    end
    local img = h.img {src = src, class="aktual-img",alt = alt,  title = alt}
   table.insert(t, building_blocks.row {
    building_blocks.medium(2, img),
    building_blocks.medium(10, h.div{h.h3{item.date  .. " – " ..akt_title},item.contents}
    )
  })
   -- table.insert(t, h.p{h.small {item.date}})
   -- table.insert(t, item.contents)
   if i < #items then table.insert(t, h.hr{}) end
  end
  return t
end

function building_blocks.provozni_doba(data, T)
  local t = {}
  local function tbl(jednotka)
      -- local tbl = h.tr{h.th{colspan=2,  T (jednotka.name)}}--h.table {}
      local tbl = h.caption{ T (jednotka.name)}--h.table {}
      local tble = {}


      for _, obdobi in ipairs(jednotka.data) do
        local curr_row = h.tr { h.td { T(obdobi.day)}, h.td {T(obdobi.time)}}
        -- h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        table.insert(tble, curr_row)
      end
      -- return {h.table{class="prov_doba",h.thead{tbl}, h.tbody{tble}}}
      return {h.table{class="prov_doba small",tbl, tble}}
  end
  local function jednotky(idata)
    for _, jednotka in ipairs(idata.children) do
      -- table.insert(t, h.h3 {jednotka.name})
      -- h.h3 {jednotka.name}
      -- table.insert(jednotka.data, 1, h.caption {jednotka.name})
      table.insert(t, tbl(jednotka))
      -- table.insert(t, tble)
    end
    return t
  end
  return jednotky(data)
end

function building_blocks.uzavreni(data, T)
   local t = {}
   local function get_closing(days)
     if type(days) == "string" then return days end
     local t = {}
     local function add(day, separator)
       t[#t+1] = day
       t[#t+1] = separator
     end
     for k,v in ipairs(days) do
       local separator = v.modifier
       if separator == "," then
         separator = ", "
       elseif separator == "-" then
         separator = " – "
       end
       if not v.year then
         add(string.format(T "%d. %d", v.day, v.month),  separator)
       else
         add(string.format(T "%d. %d. %d", v.day, v.month, v.year), separator)
       end
     end
     return table.concat(t)
   end
   for _, v in ipairs(data) do
     local name = T (v.comment)
     local closing = get_closing(v.closing)
     t[#t+1] = h.tr { h.td {name}, h.td{closing}}
   end
   return h.table{class="small", t}
 end

 return building_blocks
