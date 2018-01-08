
local transducers = require("lettersmith.transducers")
local into = transducers.into
local map = transducers.map
local take = transducers.take
local comp = transducers.comp
local docs = require("lettersmith.docs_utils")
local derive_date = docs.derive_date
local render_markdown = require("lettersmith.markdown")
local discount = require "discount"

local wrap_in_iter = require("lettersmith.plugin_utils").wrap_in_iter
local get_news_item = function(doc)
  local title = doc.title
  local contents = discount(doc.contents)
  local date = derive_date(doc)
  local date_table = {}
  date:gsub("(....)-(..)-(..)", function(year, month, day)
    date_table = {year = tonumber(year), month = tonumber(month), day=tonumber(day)}
  end)
  date = os.time(date_table)
  date = os.date("%d.%m.%Y", date)
  return {akt_title = title, contents = contents, date = date}
end

local index = function(filepath)
  local take_news = comp(take(5000), map(get_news_item))
  return function(iter, ...)
    local items = into(take_news, iter, ...)
    local date = items[1].date
    local title = "Knihovna PedF UK"
    return wrap_in_iter {template = "index.tpl", title=title, date = date, items = items, relative_filepath = filepath}
  end
end

return {index = index}
