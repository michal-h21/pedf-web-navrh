package.path = "?.lua;lib/?.lua;"..package.path
local lettersmith = require("lettersmith")
local transducers = require "lettersmith.transducers"
local lazy = require "lettersmith.lazy"
local merge = require("lettersmith.table_utils").merge
local wrap_in_iter = require("lettersmith.plugin_utils").wrap_in_iter
local docs = require("lettersmith.docs_utils")
local translator = require "lib.translator"
local lfs = require "lfs"
local attributes = lfs.attributes

-- local render_mustache = require("lettersmith.mustache").choose_mustache
local html_dir = os.getenv("HTML_DIR") or "html"
local www_dir = os.getenv("WWW_DIR") or "www"
local data_dir = os.getenv("DATA_DIR") or "data"
local html_dir_en = html_dir .. "/en"
print("Data dir" , data_dir)

local siteurl =  "http://knihovna.pedf.cuni.cz/"
local rss = require "atom"
-- local sitemap = require "sitemap"
local discount = require "discount"
local archiv = require "archivaktual".index
local newindex_template = require "templates.newindex".template
local opening_template = require "templates.opening".template
local updates_template = require "templates.updates".template
local prov_doba_fn = require "prov_doba"
local prov_doba = prov_doba_fn(data_dir .. "/opening.csv")
local load_closing = require "closing"
local zaviraci_dny,kalendar  = load_closing(io.lines( data_dir .. "/closing.csv"))
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



local file_utils = require "lettersmith.file_utils"
local walk_file_paths = file_utils.walk_file_paths
-- local index = require("index").index
-- local archiv = require("archivaktual").index
local derive_date = docs.derive_date


local h5tk = require "h5tk"
local h = h5tk.init()

local building_blocks = require "building_blocks"
local card = building_blocks.card
local medium = building_blocks.medium
local row = building_blocks.row
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
  menuitem("Catalogues and databases", "catalogues.html"),
  menuitem("About library", "about.html")
}

local engstrings = require "trans.eng"




-- Get paths from "raw" folder
local paths = lettersmith.paths(html_dir)

local en_path = lettersmith.paths(html_dir_en)
local aktuality = lettersmith.paths(html_dir .. "/aktuality")
local en_aktuality = lettersmith.paths(html_dir .. "/en/aktuality")
local nove_knihy = lettersmith.paths(html_dir .. "/nove_knihy")
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


local nk_defaults = make_transformer(function(doc)
 doc.relative_filepath = "/nove_knihy/index.html"
 print("Nové knihy", doc.relative_filepath)
 doc.title = "Nové knihy"
 doc.styles = {"/css/nove_knihy.css"}
 return doc
end)

local add_defaults = make_transformer(function(doc)
  print("Zpracovavam", doc.relative_filepath)
  doc.template = doc.template or "blog.tpl"
  -- don't use old styles in the documents
  doc.styles = doc.styles or {}
  doc.siteurl = siteurl
  doc.obalky_dir = data_dir .. "/obalky/"
  if doc.file_path then
    -- this doesn't work in Github actions
    doc.modified = attributes(doc.file_path, "modification")
  end
  if not doc.description then
    if doc.lang == "eng" then
      doc.description = "Faculty library in the center of Prague. Rich book collection, many electronic resources, and magazines. We look forward to you!"
    else
      doc.description = "Fakultní knihovna v centru Prahy. Bohatý knižní fond, množství elektronických zdrojů, pravidelné výstavy, denní tisk a časopisy. Těšíme se na vás!"
    end
  end
  -- if doc.design ~=false then
    -- table.insert(doc.styles,"css/scale.css")
    -- table.insert(doc.styles,"css/design.css")
  -- end
  if doc.lang == "eng" then
    doc.menuitems = engmenu
    doc.strings = engstrings
  else
    doc.menuitems = mainmenu
  end
  -- doc.sitemap = sitemap
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

-- aplikovat h5tk templates
local apply_template = make_transformer(function(doc)
  local doc_card =card {h.article{role="main",doc.contents}}
  -- přidat obrázek pokud ho stránka má nastavený
  if doc.img then
    doc.contents = card{ row {
      medium(7, h.article{role="main", doc.contents}),
      medium(5, h.div{ class="page-img", h.img{src = doc.img, alt=doc.alt, title=doc.alt}})
    }}
  else
    doc.contents = doc_card
  end
  local rendered = base_template(doc)
  return merge(doc, {contents = rendered})
end)

local apply_opening_template = make_transformer(function(doc)
  doc.prov_doba = prov_doba
  doc.calendar = calendar
  doc.closing = zaviraci_dny
  local rendered = opening_template(doc)
  return merge(doc, {contents = rendered})
end)

-- this is not used anymore
local function save_calendar(filename, calendar, T)
  local buffer = {}
  local f = io.open(filename, "w")
  f:write("{")
  -- write localized calendar as a JSON file
  for k,v in pairs(calendar) do buffer[#buffer+1] = string.format('"%s":"%s"', T(k),T(v)) end
  f:write(table.concat(buffer, ","))
  f:write( "}")
  f:close()
end


-- make calendar JS
local function make_calendar(calendar, T)
  local buffer = {}
  -- buffer[#buffer+1] = "{"
  -- write localized calendar as a JSON file
  for k,v in pairs(calendar) do 
    buffer[#buffer+1] = string.format('"%s":"%s"', T(k),T(v)) 
  end
  -- buffer[#buffer+1] = "}"
  return "{\n" .. table.concat(buffer, ",") .. "\n}"
end

-- save calendar JS
local function calendar_builder(path, lang) 
  local lang_func = get_lang_func(lang)
  local calendar_render = make_transformer(function(doc)
    doc.relative_filepath = path
    local T = translator.get_translator(doc.strings)
    -- global variable
    local contents = make_calendar(kalendar, T)
    return merge(doc, {contents = contents})
  end)
  return comp(
  calendar_render,
  add_defaults,
  lang_func,
  html_filter,
  only_root,
  lettersmith.docs
  )
end

local apply_newindex = make_transformer(function(doc)
  -- doc.menuitems = mainmenu
  local rendered = newindex_template(doc)
  local strings = doc.strings
  -- local T = translator.get_translator(doc.strings)
  -- local calendar_name = "js/calendar.js" 
  -- save_calendar(T(calendar_name), doc.calendar, T)
  return merge(doc, {contents = rendered})
end)

-- local add_sitemap = make_transformer(function(doc)
--   doc.sitemap=sitemap
--   doc.prov_doba = prov_doba
--   return doc
-- end)


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

local page_actualizations = {}

-- we need to get the modified date from Git :/
local iopopen = io.popen
-- path should point to the Git directory of HTML pages
local function get_git_modified(doc, path)
  -- keep just the filename without path
  local file_path = doc.file_path:match("/([^/]+)$")
  local cmd = "git -C " .. path .. " log -1 --format='%at' HEAD " ..  file_path
  local time = iopopen(cmd, "r")
  local result = time:read("*all")
  time:close()
  return tonumber(result)
end

-- make table with modified pages
local function newest_pages_builder(path, lang)
  local lang = lang or ""
  local lang_func = get_lang_func(lang)
  -- don't process obsolete pages
  local obsolete_filter =  transformer(filter(function(doc)
    return not doc.obsolete
  end))
  local apply_update_template = make_transformer(function(doc) return merge(doc, {contents = updates_template(doc) }) end)
  local menu = mainmenu
  local strings = {} -- don't use translation strings by default
  local altlang = "updates.html"
  -- ignore english pages
  local pages_filter = transformer(filter(function(doc)  return not string.match(doc.relative_filepath,"^%/.-%/") end))
  -- path to git repo with html source files
  local repo_path = html_dir
  if lang == "eng" then
    menu = engmenu
    strings = engstrings
    altlang = "aktualizace.html"
    repo_path = html_dir_en
    pages_filter = transformer(filter(function(doc)  return true end))
    -- pages_filter = transformer(filter(function(doc) return string.match(doc.relative_filepath or "///","^%/en%/[^%/]+$") end))
  end
  -- convert documents to table
  local get_newest_pages = function(doc) 
    local modified = get_git_modified(doc, repo_path)
    return {modified = modified, relative_filepath = doc.relative_filepath, title = doc.title, obsolete = doc.obsolete, date = os.date("%Y-%m-%d", modified) } end
  local take_news = comp(take(5000), map(get_newest_pages))
  local newest_pages = function(iter, ...)
    local items = into(take_news, iter, ...)
    table.sort(items, function(a,b) return a.modified > b.modified end)
    -- save table somewhere it will be available for other pages
    page_actualizations[lang] = items
    -- os.exit()
    return wrap_in_iter { title= "Aktualizace stránek", menuitems =menu, date = date, items =
    items, relative_filepath = path, strings = strings, 
    items = items,
    siteurl = siteurl,
    altlang = altlang,
    img = "/img/informace.jpg",
    alt = "Foto: Martina Růžičková" 
  }
  end
  return comp(
    apply_update_template,
    -- apply_template,
    newest_pages,
    add_defaults,
    lang_func,
    pages_filter,
    obsolete_filter,
    html_filter,
    only_root,
    lettersmith.docs
  )
end

local function nove_knihy_builder(lang)
  local lang_func = get_lang_func(lang)
  return comp(
    apply_template,
    nk_defaults,
    add_defaults,
    lang_func,
    html_filter,
    only_root,
    lettersmith.docs
  )
end


local function opening_builder(name, lang)
  local lang_func = get_lang_func(lang)
  local filter = make_filter(name)
  return comp(
  apply_opening_template,
  add_defaults,
  lang_func,
  filter,
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

local function get_new_books(path, number)
  local t = {}
  for image in walk_file_paths(path) do
    table.insert(t,image)
  end
  -- seřadit soubory od nejnovějších
  table.sort(t, function(a,b) return a > b end)
  -- stačí nanejvýš 10 obálek
  local obalky = {}
  for i=1,number do
    local current = t[i]
    if not current then break end
    current = current:match("([^%/]+)$")
    local isbn = current:match("%d+%-%d+%-%d+%-(.+)%.jpg")
    table.insert(obalky, {file = current, isbn = isbn})
  end
  return obalky
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

local newindex = function(filepath,menu, languagestrings, lang)
  local take_news = comp(take(2), map(get_news_item))
  return function(iter, ...)
    local items = into(take_news, iter, ...)
    -- local items = {}
    -- local date = items[1].date
    local title = "Knihovna PedF UK"
    print("mainmenu", menu)
    -- get updated pages
    local newest = page_actualizations[lang or ""]
    local obalky = get_new_books(data_dir .. "/obalky", 9)
    -- local languagestrings = languagestrings or {}
    return wrap_in_iter { title=title, menuitems =menu, date = date, items =
    items, relative_filepath = filepath, prov_doba = prov_doba, obalky =
    obalky, strings = languagestrings or {}, closing = zaviraci_dny, calendar = kalendar,
    siteurl = siteurl, updates = newest
  }
  end
end

-- filtrovat aktuality a skrýt ty, které mají nastavené hide datum
-- to by mělo být ve tvaru rok-měsíc-den
local filter_aktual =   transformer(filter(function(doc)
  local today = os.time()
  -- nastavit dost vysoké výchozí datum, abysme neskrývali novinky, co skrýt nechceme
  local hide_date = doc.hide or "2099-12-31"
  -- print(hide_date)
  local year, month, day = hide_date:match("(%d+)%-(%d+)%-(%d+)")
  local hide = os.time{year = year, month=month, day=day}
  return hide > today
end))

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
  newindex(page,menu, strings,lang),
  add_defaults,
  lang_func,
  filter_aktual,
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
  -- add_sitemap,
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
  www_dir, 
  builder(paths), 
  html_builder()(paths),
  nove_knihy_builder()(nove_knihy),
  html_builder("eng")(en_path),
  opening_builder("opening.html","eng")(en_path),
  opening_builder("provozni_doba.htm")(paths),
  css_builder(paths),
  calendar_builder("js/calendar.js")(paths),
  calendar_builder("js/calendar-en.js", "eng")(paths),
  newest_pages_builder("aktualizace.html")(paths),
  newest_pages_builder("updates.html", "eng")(en_path),
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
