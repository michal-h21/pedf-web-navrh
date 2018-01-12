package.path = "?.lua;lib/?.lua;"..package.path
local lettersmith = require("lettersmith")
local transducers = require "lettersmith.transducers"
local lazy = require "lettersmith.lazy"
local merge = require("lettersmith.table_utils").merge
local wrap_in_iter = require("lettersmith.plugin_utils").wrap_in_iter
local docs = require("lettersmith.docs_utils")

-- local render_mustache = require("lettersmith.mustache").choose_mustache

local rss = require "atom"
local sitemap = require "sitemap"
local discount = require "discount"
local archiv = require "archivaktual".index
local newindex_template = require "templates.newindex".template
local prov_doba = require "prov_doba"
-- local templates = require("templates")
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
local print_actual = building_blocks.print_actual

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



-- english version
local engmenu = {
  menuitem("Home", "index-en.html"),
  menuitem("Services", "services.html"),
  menuitem("Contact us", "contact-en.html")
}

local engstrings = require "trans.eng"


-- Get paths from "raw" folder
local paths = lettersmith.paths("html")
local en_path = lettersmith.paths("html/en")
local aktuality = lettersmith.paths("html/aktuality")
local en_aktuality = lettersmith.paths("html/en/aktuality")
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

local only_root =   transformer(filter(function(doc)
  local fn = doc.relative_filepath
  return not fn:match("^diplomky/") and not fn:match("^en/")
end))


local add_defaults = make_transformer(function(doc)
  print("Zpracovavam", doc.relative_filepath)
  doc.template = doc.template or "blog.tpl"
  doc.styles = doc.styles or {}
  if doc.design ~=false then
    table.insert(doc.styles,"css/scale.css")
    table.insert(doc.styles,"css/design.css")
  end
  if doc.lang == "eng" then
    doc.menuitems = engmenu
    doc.strings = engstrings
  else
    doc.menuitems = mainmenu
  end
  doc.sitemap = sitemap
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
  -- doc.menuitems = mainmenu
  local rendered = newindex_template(doc)
  return merge(doc, {contents = rendered})
end)

local add_sitemap = make_transformer(function(doc)
  doc.sitemap=sitemap
  doc.prov_doba = prov_doba
  return doc
end)

local set_english = make_transformer(function(doc)
  doc.lang = "eng"
  return doc
end)

local function get_lang_func(lang)
  local lang_func = make_transformer(function(doc) return doc end)
  if lang == "eng" then 
    lang_func = set_english
  end
  return lang_func
end


local builder = comp(
  lettersmith.docs
)

-- builder for common html pages
local function html_builder(lang)
  local lang_func = get_lang_func(lang)
  return comp(
    apply_template,
    add_defaults,
    lang_func,
    html_filter,
    only_root,
    lettersmith.docs
  )
end


-- don't use templates and anything fancy on css files
local css_builder = comp(
css_filter,
lettersmith.docs
)

-- local rss_gen = comp(
local function rss_gen(page, title)
  return comp(
  rss.generate_rss(page,"http://knihovna.pedf.cuni.cz",title, ""),
  lettersmith.docs
  )
end


-- local wrap_in_iter = require("lettersmith.plugin_utils").wrap_in_iter
local get_news_item = function(doc)
  local title = doc.title
  local img = doc.img
  local alt = doc.alt or ""
  local contents = discount(doc.contents)
  local date = derive_date(doc)
  local date_table = {}
  date:gsub("(....)-(..)-(..)", function(year, month, day)
    date_table = {year = tonumber(year), month = tonumber(month), day=tonumber(day)}
  end)
  date = os.time(date_table)
  date = os.date("%d.%m.%Y", date)
  return {akt_title = title, contents = contents, date = date, img = img, alt = alt}
end

local newindex = function(filepath,menu, languagestrings)
  local take_news = comp(take(3), map(get_news_item))
  return function(iter, ...)
    local items = into(take_news, iter, ...)
    -- local items = {}
    -- local date = items[1].date
    local title = "Knihovna PedF UK"
    print("mainmenu", menu)
    -- local languagestrings = languagestrings or {}
    return wrap_in_iter { title=title, menuitems =menu, date = date, items = items, relative_filepath = filepath, strings = languagestrings or {}}
  end
end

-- create index page for given language
local function index_gen(page, lang)
  local lang_func = get_lang_func(lang)
  local menu = mainmenu
  local strings = {} -- don't use translation strings by default
  if lang == "eng" then
    menu = engmenu
    strings = engstrings
  end
  return comp(
    apply_newindex,
    newindex(page,menu, strings),
    add_defaults,
    lang_func,
    lettersmith.docs
  )
end


local archiv_items = make_transformer(function(doc)
  doc.contents = print_actual(doc.items)
  return doc
end)


local archive_gen = function(page, lang)
  local lang_func = get_lang_func(lang)
  return comp(
  apply_template,
  archiv_items,
  add_defaults,
  lang_func,
  add_sitemap,
  archiv(page),
  lettersmith.docs
)
end


local commands = {
}

local argument = arg[1]
if commands[argument] == nil then
  print "budujeme"
  lettersmith.build(
  "www", 
  builder(paths), 
  html_builder()(paths),
  html_builder("eng")(en_path),
  css_builder(paths),
  index_gen("index-en.html", "eng")(en_aktuality),
  rss_gen("feed-en.rss",  "Library of Faculty of Education")(en_aktuality),
  archive_gen("archive-en.html","eng")(en_aktuality),
  index_gen("index.html")(aktuality),
  rss_gen("feed.rss",  "Knihovna PedF UK")(aktuality),
  archive_gen("archiv.html")(aktuality)
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
