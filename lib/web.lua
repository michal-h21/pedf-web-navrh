package.path = "?.lua;"..package.path
local lettersmith = require("lettersmith")
local transducers = require "lettersmith.transducers"
local rss = require "atom"
local map = transducers.map
local reduce = transducers.reduce
local filter  = transducers.filter
local lazy = require "lettersmith.lazy"
local transform = lazy.transform
local transformer = lazy.transformer
local index = require("index").index
local archiv = require("archivaktual").index
local merge = require("lettersmith.table_utils").merge
local sitemap = require "sitemap"
local prov_doba = require "prov_doba"
local templates = require("templates")




-- Get paths from "raw" folder
local paths = lettersmith.paths("src")
local aktuality = lettersmith.paths("src/aktuality")
local diplomka_path = lettersmith.paths("diplomky")
local comp = require("lettersmith.transducers").comp

local render_mustache = require("lettersmith.mustache").choose_mustache

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
  doc.prov_doba = prov_doba
  return doc
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
  render_mustache("tpl/",templates),
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


local index_gen = comp(
  render_mustache("tpl/",templates),
  -- render_page,
  add_sitemap,
  index("index.html"),
  lettersmith.docs
)

local archive_gen = comp(
  render_mustache("tpl/", templates),
  add_sitemap,
  archiv("archiv.html"),
  lettersmith.docs
)

local katalog_portal = comp(
  render_mustache("tpl/",templates),
  sitemap_to_portal)

-- Build files, writing them to "www" folder
local dipl_builder = comp(
  render_mustache("tpl/",templates),
  add_defaults,
  html_filter,
  lettersmith.docs
)


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
  rss_gen(aktuality),
  archive_gen(aktuality),
  index_gen(aktuality),
  katalog_portal("Katalogy a databáze"),
  katalog_portal("Služby")
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
