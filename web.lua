package.path = "?.lua;lib/?.lua;"..package.path
local lettersmith = require("lettersmith")
local transducers = require "lettersmith.transducers"
local lazy = require "lettersmith.lazy"
local merge = require("lettersmith.table_utils").merge
local wrap_in_iter = require("lettersmith.plugin_utils").wrap_in_iter
local docs = require("lettersmith.docs_utils")

local render_mustache = require("lettersmith.mustache").choose_mustache

local rss = require "atom"
local sitemap = require "sitemap"
local discount = require "discount"
local archiv = require "archivaktual".index
local newindex_template = require "newindex".template
local prov_doba = require "prov_doba"
local templates = require("templates")
local base_template = require "templates.base"

-- lettersmith utils
local map = transducers.map
local reduce = transducers.reduce
local filter  = transducers.filter
local take = transducers.take
local into = transducers.into
local comp = transducers.comp
local transform = lazy.transform
local transformer = lazy.transformer
-- local index = require("index").index
-- local archiv = require("archivaktual").index
local derive_date = docs.derive_date


local building_blocks = require "building_blocks"
local card = building_blocks.card

local menuitem = function(title, href) return {title = title, href= href} end

local mainmenu = {
  menuitem("Domů","index.html"),
  menuitem("Služby","sluzby.htm"),
  menuitem("Publikační činnost", "biblio.html"),
  menuitem("Časopisy", "periodika.htm"),
  menuitem("Elektronické zdroje", "eiz.htm"),
  menuitem("Závěrečné práce", "kvalifikacni_prace.htm"),
  -- menuitem("Průvodce", "pruvodce.html"),
  menuitem("Nákup publikací","objednavani_liter.htm"),
  menuitem("O knihovně", "informace.htm"),
}






-- Get paths from "raw" folder
local paths = lettersmith.paths("html")
local aktuality = lettersmith.paths("html/aktuality")
-- local diplomka_path = lettersmith.paths("diplomky")

local make_transformer = function(fn)
  return transformer(map(fn))
end

local make_filter = function(reg)
  return transformer(filter(function(doc)
    local fn = doc.relative_filepath
    return fn:match(reg)
  end
  ))
end

local html_filter = make_filter("htm[l]?$")

local css_filter =  make_filter("css$")

local not_diplomky =   transformer(filter(function(doc)
  local fn = doc.relative_filepath
  return not fn:match("diplomky/")
end))


local add_defaults = make_transformer(function(doc)
  print("Zpracovavam", doc.relative_filepath)
  doc.template = doc.template or "blog.tpl"
  doc.styles = doc.styles or {}
  if doc.design ~=false then
    table.insert(doc.styles,"css/scale.css")
    table.insert(doc.styles,"css/design.css")
  end
  doc.sitemap = sitemap
  doc.menuitems = mainmenu
  doc.prov_doba = prov_doba
  return doc
end)

-- aplikovat h5tk templates
local apply_template = make_transformer(function(doc)
  doc.contents = card {doc.contents}
  local rendered = base_template(doc)
  return merge(doc, {contents = rendered})
end)

local apply_newindex = make_transformer(function(doc)
  doc.menuitems = mainmenu
  local rendered = newindex_template(doc)
  return merge(doc, {contents = rendered})
end)

local add_sitemap = make_transformer(function(doc)
  doc.sitemap=sitemap
  doc.prov_doba = prov_doba
  return doc
end)

local sitemap_to_portal = function(name)
  local function match(doc)
    if doc.name == name then
      local filepath =  doc.url
      doc.relative_filepath = filepath
      doc.template = "portal.tpl"
      doc.styles =  {"css/scale.css","css/design.css"}
      print("Make portal", name, filepath)
      doc.portal = doc
      doc.sitemap = sitemap
      return doc
    else
      return false
    end
  end
  return transform(filter(match), ipairs(sitemap))
end

local builder = comp(
lettersmith.docs
)

-- use templates on html files
local html_builder = comp(
apply_template,
-- render_mustache("tpl/",templates),
add_defaults,
html_filter,
not_diplomky,
lettersmith.docs
)

-- don't use templates and anything fancy on css files
local css_builder = comp(
css_filter,
lettersmith.docs
)

local rss_gen = comp(
rss.generate_rss("feed.rss","http://knihovna.pedf.cuni.cz", "Knihovna PedF UK", ""),
lettersmith.docs
)


-- local wrap_in_iter = require("lettersmith.plugin_utils").wrap_in_iter
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

local newindex = function(filepath)
  local take_news = comp(take(3), map(get_news_item))
  return function(iter, ...)
    local items = into(take_news, iter, ...)
    -- local items = {}
    -- local date = items[1].date
    local title = "Knihovna PedF UK"
    print("mainmenu", mainmenu)
    return wrap_in_iter { title=title, menuitems =mainmenu, date = date, items = items, relative_filepath = filepath}
  end
end
local index_gen = comp(
-- apply_template,
-- render_mustache("tpl/",templates),
-- render_page,
-- add_sitemap,
apply_newindex,
newindex("index.html"),
add_defaults,
lettersmith.docs
)

local archive_gen = comp(
-- render_mustache("tpl/", templates),
apply_template,
add_defaults,
add_sitemap,
archiv("archiv.html"),
lettersmith.docs
)

-- local katalog_portal = comp(
-- render_mustache("tpl/",templates),
-- sitemap_to_portal)

-- -- Build files, writing them to "www" folder
-- local dipl_builder = comp(
-- render_mustache("tpl/",templates),
-- add_defaults,
-- html_filter,
-- lettersmith.docs
-- )


local commands = {
  diplomky = function()
    print "Tak co?"
    lettersmith.build(
    "www/diplomky",
    dipl_builder(diplomka_path))
  end
}

local argument = arg[1]
if commands[argument] == nil then
  print "budujeme"
  lettersmith.build(
  "www", 
  builder(paths), 
  html_builder(paths),
  css_builder(paths),
  -- index_gen(paths),
  index_gen(aktuality),
  rss_gen(aktuality),
  archive_gen(aktuality)
  -- index_gen(aktuality),
  -- katalog_portal("Katalogy a databáze"),
  -- katalog_portal("Služby")
  )
  print "Použili jsme defaultní nastavení"
  print "Použij texlua web.lua prikaz pro alternativní nastavení"
  print "Dostupné příkazy"
  for k,_ in pairs(commands) do print("",k) end
else
  print("Používám příkaz " ..argument)
  -- for k,v in lettersmith.docs(paths) do print(k,v) end
  local prikaz = commands[argument] or function() print("Neznámý příkaz " .. argument) end
  prikaz()
end
