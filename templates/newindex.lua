local h5tk = require "h5tk"
-- local css = require "css"
local base_template = require "templates.base"
local building_blocks = require "lib.building_blocks"

local h = h5tk.init(true)

local a, p, div, header, section = h.a, h.p, h.div, h.header, h.section


local row = building_blocks.row

-- local class = building_blocks.class

local column = building_blocks.column

local medium = building_blocks.medium

local card = building_blocks.card

local tab = building_blocks.tab
local boxik = building_blocks.boxik
local translator = require "lib.translator"

local print_actual = building_blocks.print_actual
local provozni_doba = building_blocks.provozni_doba


local function obalky(filename, isbn)
  -- return h.div {a{target="_blank", href="https://ckis.cuni.cz/F?func=find-a&amp;local_base=CKS&amp;find_code=ISN&amp;request=".. isbn, h.img{style = "height:9rem;display:inline;",alt=isbn, src='/img/obalky/' .. filename }}}
  -- odkazovat do UKAŽ místo katalogu. v UKAŽ můžou být odkazy na Bookport :(
  return h.div {a{target="_blank", href="https://search.ebscohost.com/login.aspx?direct=true&amp;site=eds-live&amp;scope=site&amp;type=0&amp;custid=s1240919&amp;groupid=pedf&amp;profid=eds&amp;mode=bool&amp;lang=cs&amp;authtype=ip,guest&amp;bquery=IB+".. isbn, h.img{style = "height:9rem;display:inline;",alt=isbn, src='/img/obalky/' .. filename }}}
end

local function progress(percent)
  return h.progress{value = percent, max=1000}
end

local function print_obalky(obalky_tbl)
  local t = {}
  for _, obalka in ipairs(obalky_tbl or {}) do
    table.insert(t, obalky(obalka.file, obalka.isbn))
  end
  return t
  -- return {p{"obalek: " .. #obalky_tbl}}
end


local function data_links(T,data)
  local t = {}
  for i, v in ipairs(data) do
    local separator = ""
    if i < #data then separator = ", " end
    table.insert(t, "<a href='" ..T(v[2]).. "'>".. T(v[1]).."</a>"..separator)
  end
  return t
end

local function print_updates(T, data)
  local t = {}

  for i=1, 5 do
    local x = data[i] or {}
    t[#t+1] = string.format("<a href='%s'>%s</a>", x.relative_filepath, x.title)
  end
  return " (" ..data[1].date .."): " .. table.concat(t , ", ")
end

-- function column
local function template(doc )
  local title = doc.title
  local strings = doc.strings
  local T = translator.get_translator(strings)
  -- handle closed days
  local today = os.date("%Y-%m-%d", os.time())
  local closing = doc.calendar
  local close_comment = closing[today]
  local close_element = div {class="closed", id="closed"}
  if close_comment then
    close_element = div{class="closed", id="closed", div{h.b {T "Dnes má knihovna zavřeno: "}}, div{T(close_comment)}}
    -- close_element = div{class="closed", h.strong {T "Dnes má knihovna zavřeno: "}, T(close_comment)}
  end
  local contents = {
    row{
      medium(9,{
        medium(12, card(row{
          -- card {
            h.h2{ T "Aktuality" },
            print_actual(doc.items), div {class="archiv-link", T ' (<a href="archiv.html">Další aktuality zde</a>)' }
            -- actuality("Provozní doba v průběhu letních prázdnin", "26. 6. 2017", p {"Aktualizovanou provozní dobu knihovny v průběhu letních prázdnin a v září naleznete zde"}),
            -- actuality("Uzavření SAJL v Celetné", "23.06.2017", "Upozorňujeme <b>všechny</b> uživatele služeb ve Studovně anglického jazyka a literatury PedF v Celetné 13, aby si veškerou literaturu, kterou budou potřebovat ke zkouškám v září, vypůjčili do konce června. V srpnu bude studovna z důvodu stěhování knihovního fondu uzavřena.")
          }
          )),--},
          -- row {
            -- medium(9, {card {p{"Vyhledávací boxy"}}}),
            -- medium(9, card{ div{class="tabs", 
  -- },
  -- row{
  --   boxik("Studenti se specifickými potřebami"),
  --   boxik("EIZ pro PedF"),
  --   k
  --   boxik("Oborové EIZ"),
  --   boxik("Periodika"), 
  --   boxik("Návody"),
  --   boxik("Řády a ceníky"),
  --   boxik("Kontakty"),
  --   boxik("Facebook"),
  --   boxik("Galerie knihovny"),
  --   boxik("Formuláře")
  -- },
})
,
medium(3,
{ 
  card{ 
    provozni_doba( doc.prov_doba, T),
    
  -- {
  --   name = "Výpůjční protokol",
  --   data = {
  --     {day="Po", time = "8.00–16.00"},
  --     {day = "Út–Pá", time = "8.00–17.00"}
  --   }
  -- },
  -- {
  --   name = "Studovna",
  --   data = {
  --     {day = "Po–Čt", time = "8.00–18.00"},
  --     {day = "Pá", time = "8.00–16.00"}
  --   }
  -- }
  -- ), 
  -- [[
           -- <table class="prov_doba small">
                            -- <caption>]] ..T "Letní prázdniny" ..[[</caption>
                            -- <tr>
                                -- <td>]] .. T "Studovna" .. [[</td>
                                -- <td>]] .. T"Zavřeno do odvolání" ..[[</td>
                            -- </tr>
                            -- <tr>
                                -- <td>]] .. T"Půjčovna" ..[[</td>
                                -- <td>]] .. T "Zavřeno červenec + srpen" .. [[</td>
                            -- </tr>
                            -- <tr>
                                -- <td></td>
                                -- <td>]] .. T "Otevřeno každé úterý v srpnu, 9.00 — 15.00" ..[[</td>
                            -- </tr>
                        -- </table>
  -- ]],
  
  close_element,
  div{ a {href=T "provozni_doba.htm", T "Plánované uzavření knihovny"}}},
  {card {row { 
    div{ '<img src="img/phone.svg" style="width:0.9em" alt="" /> <a href="tel:+420221900148" aria-label="telephone 4 2 0 2 2 1 9 0 0 1 4 8">+420 221 900 148</a>'},
    div {'<img src="img/envelope.svg" style="width:0.9em" alt="e-mail" /> ', a{href="mailto:knihovna@pedf.cuni.cz","knihovna@pedf.cuni.cz"}},
    -- },
    -- row{
    div {
      '<a href="https://www.facebook.com/knihovnapedfpraha"><img src="img/facebook.svg" style="width:0.9em" alt="facebook" /></a>',
      '<a href="https://www.instagram.com/KnihovnaPedFPraha/"><img src="img/instagram.svg" style="width:0.9em" alt="instagram" /></a>',
      a{href="https://www.facebook.com/knihovnapedfpraha", ["aria-label"]="facebook knihovnapedfpraha",'knihovnapedfpraha'}},
    -- div {'<a href="https://www.instagram.com/KnihovnaPedFPraha/"><i class="fab fa-instagram" aria-hidden="true"></i></a>',a{href="https://www.instagram.com/KnihovnaPedFPraha/",'knihovnapedfpraha'}}
  }} 
},
-- {card {h.h2{ a{href="/nove_knihy/index.html", T "Nové knihy"}},
-- -- row( div{ class="my-slider",  print_obalky(doc.obalky)}
-- -- -- obalky "978-80-7422-500-0",
-- -- -- obalky "80-85368-18-8", 
-- -- -- obalky "978-80-7294-458-3"
-- -- ),
-- h.h2 {a{href= T "https://ezdroje.cuni.cz/prehled/freetrials.php?lang=cs", T "Zkušební přístupy EIZ"}},
--     }},
    -- card {
    --   h.h2 {"Ankety"}, 
    --   p {"Nějaká otázka. Trochu delší text"},
    --   h.ol{
    --     h.li{"první možnost", progress(300)},
    --     h.li{"druhá možnost", progress(400)}, 
    --     h.li {"třetí možnost",progress(300)}
    --   }
    -- }
  })
},
{
            medium(12, 
            card{ div{class="tabs", 
        tab("ukaz", T "Ukaž (vyhledávání <abbr title='informační zdroje'>IZ</abbr>)", 
        h.form{ id="ebscohostCustomSearchBox", action="&nbsp;", onsubmit="return ebscoHostSearchGo(this);", method="post",
        h.input {id="ebscohostwindow",name="ebscohostwindow",type="hidden",value="1"},
-- http://search.ebscohost.com/login.aspx?direct=true&scope=site&type=0&site=eds-live&custid=s1240919&groupid=pedf&profid=eds&lang=cs
        h.input {id="ebscohosturl",name="ebscohosturl",type="hidden",value="https://search.ebscohost.com/login.aspx?direct=true&amp;site=eds-live&amp;scope=site&amp;type=0&amp;custid=s1240919&amp;groupid=pedf&amp;profid=eds&amp;profile=eds&amp;mode=bool&amp;lang=".. T "cs" .. "&amp;authtype=ip,guest"},
        h.input {id="ebscohostsearchsrc",name="ebscohostsearchsrc",type="hidden",value="db"},
        h.input {id="ebscohostsearchmode", name="ebscohostsearchmode", type="hidden", value="+"},
        h.input {id="ebscohostkeywords", name="ebscohostkeywords", type="hidden", value="" },
        -- h.label{T "Klíčová slova:", 
        h.input{id="ebscohostsearchtext",class="",name="ebscohostsearchtext",type="search",size="28"},
        h.input{type="submit", value=T "hledat"},
          h.div{class="bottom", T "<a href='https://knihovna.cuni.cz/rozcestnik/ukaz/'>Více informací</a> o vyhledávací službě Ukaž.", T "<a href='eiz.htm#upozorneni'>Podmínky pro užití el. zdrojů</a>."},
      },"checked"
      ),
            tab("aleph", T "Katalog",  h.form{action=T "https://ckis.cuni.cz/F/", method="get", target="_blank", 
            h.input{  name="local_base", value="pedfr", type="hidden"},
            h.input {name="func", value="find-e" ,type="hidden"},
            row{
              -- h.label {T "Klíčová slova:", 
              h.input {name="request", type="search"},
              h.label {T "Vyhledat v: ", h.select {
                name="find_scan_code",
                h.option{value="FIND_WRD", selected="selected", T "Všechna pole"},
                h.option {value="FIND_WTI", T "Název"},
                -- h.option {value="SCAN_TIT", T "První slovo z názvu"},
                h.option {value="FIND_WAU", T "Autor"},
                h.option {value="SCAN_AUT", T "Autorský rejstřík"},
                h.option {value="FIND_WKW", T "Předmět"},
                h.option {value="SCAN_SUB", T "Předmětový rejstřík"},
                h.option {value="FIND_ISN", T "ISBN/ISSN"},
              },
            },
            h.input{type="submit", value=T "hledat"},
          },
          h.div{class="bottom", T "Pokud požadovanou publikaci nemáme, můžete nám dát návrh na její <a href='objednavani_liter.htm'>nákup</a>."}
        }),
      tab("e-casopisy", T "E-časopisy", [[
      <form method="get" action="https://sfx.is.cuni.cz/sfxlcl3/az/ukall" target="_blank">

      <input name="param_perform_value" value="searchTitle" type="hidden">
      <input name="param_jumpToPage_value" value="" type="hidden">
      <input name="param_type_value" value="textSearch" type="hidden">
      <input name="param_chinese_checkbox_active" value="1" type="hidden">
      <input name="param_chinese_checkbox_value" id="param_chinese_checkbox_value1" value="0" type="hidden">

      <label class="i_text">
      <span>]] .. T "Slova z názvu" .. [[</span>
      <input name="param_pattern_value" id="param_pattern_value1" type="search">
      </label>
      <input class="i_btn" value="]] .. T "hledat" ..[[" type="submit">
      ]] .. '<p>' .. T("Přehled našich časopisů si můžete prohlédnout <a href='periodika.htm'>zde</a>.") .. "</p> </form>"
      ),
      tab("e-knihy", T "E-knihy", [[
      <form method="get" action="http://sfx.is.cuni.cz/sfxlcl3/azbook/ukall" target="_blank">

      <input name="param_perform_value" value="searchTitle" type="hidden">
      <input name="param_jumpToPage_value" value="" type="hidden">
      <input name="param_type_value" value="textSearch" type="hidden">
      <input name="param_chinese_checkbox_active" value="1" type="hidden">
      <input name="param_chinese_checkbox_value" id="param_chinese_checkbox_value2" value="0" type="hidden">

      <label class="i_text">
      <span>]] .. T "Slova z názvu" .. [[</span>
      <input name="param_pattern_value" id="param_pattern_value2" type="search">
      </label>
      <input class="i_btn" value="]] .. T "hledat" ..[[" type="submit">
      ]] ..  "</p> </form>"
      ),
      tab("web-knihovny", T "Web knihovny", 
        h.form{role="search", method="get", id="duckduckgo-search", action="https://duckduckgo.com/", 
          h.input{type="hidden", name="sites" , value="knihovna.pedf.cuni.cz"},
          h.input{type="hidden", name="k8" , value="#444444"},
          h.input{type="hidden", name="k9" , value="#D51920"},
          h.input{type="hidden", name="kt" , value="h"},
          h.input{type="search", name="q" , maxlength="255", style="width:12rem", placeholder=T "Hledat na tomto webu"},
          h.input{type="submit",class="small", value=T "hledat"} --style="visibility: hidden;"}
        }
        )
    }}),
    -- row{
    medium(12, card(
          h.div{ h.b {T "Další nástroje:"}, data_links(T,{
            {"UKAŽ (UK)", "https://ukaz.cuni.cz"},
            {"Katalog (UK)", "https://ckis.cuni.cz/F/"},
            {"PEZ", "https://ezdroje.cuni.cz/"},
            {"NK", "https://aleph.nkp.cz/F/?func=file&amp;file_name=base-list"},
            {"NDK", "https://ndk.cz/"},
            {"Scopus", "https://www.scopus.com/"},
            {"DOAJ", "https://doaj.org/"},
            {"ERIH", "https://dbh.nsd.uib.no/publiseringskanaler/erihplus/"},
            {"Ulrichsweb", "https://ezdroje.cuni.cz/prehled/zdroj.php?lang=cs&id=214"},
            {"JCR", "https://jcr.clarivate.com/"},
            {"WoS", "https://webofknowledge.com/"},
            {"Google Scholar", "https://scholar.google.cz/"},
            {"Repozitář UK", "https://dspace.cuni.cz/?locale-attribute=cs"}
          })})),--}
    medium(12, card(
          h.div{ h.b {T "Nejnovější aktualizace"}, print_updates(T,doc.updates), "/",  h.a{href= T "aktualizace.html",  T "Starší"}}))
},

-- h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
-- h.div{class="card", h.section {class="section ",
-- (body)
-- }},
-- h.script{type="text/javascript", 'var nav = responsiveNav(".nav-collapse");'}
h.script{src="https://support.ebsco.com/eit/scripts/ebscohostsearch.js", type="text/javascript", defer="defer"},
h.script{src="js/opening.js", type="text/javascript", defer="defer"},
h.script{ "window.onload = function(){ opening('".. T "/js/calendar.js" .."', '".. T("Dnes má knihovna zavřeno: ") .. "')};"},
  -- [[<script src="https://cdnjs.cloudflare.com/ajax/libs/tiny-slider/2.5.0/min/tiny-slider.js"></script>
  -- <!--[if (lt IE 9)]><script src="https://cdnjs.cloudflare.com/ajax/libs/tiny-slider/2.5.0/min/tiny-slider.helper.ie8.js"></script><![endif]-->
  -- ]]
  -- ,h.script{type="text/javascript", [[
  -- var slider = tns({
  --   container: '.my-slider',
  --   items: 1,
  --   slideBy: 'page',
  --   controls:false,
  --   nav: false,
  --   speed: 7330,
  --   autoplay: true,
  --   autoplayHoverPause: true,
  --   autoplayTimeout: 1500,
  --   autoplayButtonOutput: false,
  --   mouseDrag: true,
  -- });
  -- ]]}
}
-- local doc = {}
doc.contents = contents
doc.title = title
print("menuitems", doc.menuitems)


return base_template(doc)

end


return {template = template}--("Úvodní stránka - Knihvna PedF UK", {
-- h.h1 {"Úvodní stránka"},
-- ipsum,ipsum, ipsum,ipsum,ipsum,ipsum,ipsum,
-- })
