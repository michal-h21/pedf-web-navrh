local h5tk = require "h5tk"
-- local css = require "css"
local base_template = require "templates.base"
local building_blocks = require "lib.building_blocks"

local h = h5tk.init(true)
local card = building_blocks.card
local row = building_blocks.row
local medium = building_blocks.medium
local provozni_doba = building_blocks.provozni_doba
local uzavreni = building_blocks.uzavreni

local translator = require "lib.translator"

local M = {}

local function print_updates(doc)
  local t = {}
  for _, item in ipairs(doc.items) do
    table.insert(t, h.tr {h.td {item.date}, h.td{h.a{href=item.relative_filepath, item.title}}})
  end
  return t
end

function M.template(doc)
  local strings = doc.strings
  local T = translator.get_translator(strings)
  doc.contents = {
    h.h1{ T "Aktualizace webu"},
    h.table{
      h.tr{h.th{T "Datum aktualizace"}, h.th {T "Odkaz"}},
      print_updates(doc)
    }
  }
  -- add page image
  doc.contents = card{ row {
    medium(7, h.article{role="main", doc.contents}),
    medium(5, h.div{ class="page-img", h.img{src = doc.img, alt=doc.alt, title=doc.alt}})
  }}
  return base_template(doc)
end
return M
