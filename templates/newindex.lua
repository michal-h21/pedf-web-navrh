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


local function obalky(filename, isbn)
  return h.div {a{target="_blank", href="https://ckis.cuni.cz/F?func=find-a&amp;&local_base=CKS&amp;find_code=ISN&amp;request=".. isbn, h.img{style = "height:9rem;display:inline;", src='/img/obalky/' .. filename }}}
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


local function provozni_doba(data, T)
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
      return {h.table{class="prov_doba",tbl, tble}}
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





-- function column
local function template(doc )
  local title = doc.title
  local strings = doc.strings
  local T = translator.get_translator(strings)
  local contents = {
    row{
      medium(9,{
        row{
          card {
            h.h2{ T "Aktuality" },
            print_actual(doc.items), div {class="archiv-link", T ' (<a href="archiv.html">archiv</a>)' }
            -- actuality("Provozní doba v průběhu letních prázdnin", "26. 6. 2017", p {"Aktualizovanou provozní dobu knihovny v průběhu letních prázdnin a v září naleznete zde"}),
            -- actuality("Uzavření SAJL v Celetné", "23.06.2017", "Upozorňujeme <b>všechny</b> uživatele služeb ve Studovně anglického jazyka a literatury PedF v Celetné 13, aby si veškerou literaturu, kterou budou potřebovat ke zkouškám v září, vypůjčili do konce června. V srpnu bude studovna z důvodu stěhování knihovního fondu uzavřena.")
          }},
          row {
            -- medium(9, {card {p{"Vyhledávací boxy"}}}),
            -- medium(9, card{ div{class="tabs", 
            medium(12, card{ div{class="tabs", 
            tab("aleph", T "Katalog",  h.form{action=T "https://ckis.cuni.cz/F/", method="get", target="_blank", 
            h.input{  name="local_base", value="pedfr", type="hidden"},
            h.input {name="func", value="find-e" ,type="hidden"},
            row{
              h.label {T "Klíčová slova:", h.input {name="request", type="search"}},
              h.label {T "Vyhledat v: ", h.select {
                name="find_scan_code",
                h.option{value="FIND_WRD", selected="selected", T "Všechna pole"},
                h.option {value="FIND_WTI", T "Název"},
                h.option {value="SCAN_TIT", T "První slovo z názvu"},
                h.option {value="FIND_WAU", T "Autor"},
                h.option {value="SCAN_AUT", T "Autorský rejstřík"},
                h.option {value="FIND_WKW", T "Předmět"},
                h.option {value="SCAN_SUB", T "Předmětový rejstřík"},
                h.option {value="FIND_ISN", T "ISBN/ISSN"},
              },
              h.input{type="submit", value=T "hledat"}
            }},
            h.div{class="bottom", T "Pokud požadovanou publikaci nemáme, můžete nám dát návrh na její <a href='bjednavani_liter.htm'>nákup</a>."}
          },"selected"),
          tab("ukaz", T "Ukaž (vyhledávání <acronym title='Elektronické informační zdroje'>EIZ</acronym>)", 
          h.form{ id="ebscohostCustomSearchBox", action="", onsubmit="return ebscoHostSearchGo(this);", method="post",
          h.input {id="ebscohostwindow",name="ebscohostwindow",type="hidden",value="1"},
          h.input {id="ebscohosturl",name="ebscohosturl",type="hidden",value="https://search.ebscohost.com/login.aspx?direct=true&site=eds-live&scope=site&type=0&custid=s1240919&groupid=main&profid=eds&mode=bool&lang=cs&authtype=ip,guest"},
          h.input {id="ebscohostsearchsrc",name="ebscohostsearchsrc",type="hidden",value="db"},
          h.input {id="ebscohostsearchmode", name="ebscohostsearchmode", type="hidden", value="+"},
          h.input {id="ebscohostkeywords", name="ebscohostkeywords", type="hidden", value="" },
          h.label{"Klíčová slova:", h.input{id="ebscohostsearchtext",class="",name="ebscohostsearchtext",type="search",size="23"}},
          h.input{type="submit", value=T "hledat"}
        }
        ),
        tab("e-casopisy", T "E-časopisy", [[
  <form method="get" action="http://sfx.is.cuni.cz/sfxlcl3/az/ukall" target="_blank">

    <input name="param_perform_value" value="searchTitle" type="hidden">
    <input name="param_jumpToPage_value" value="" type="hidden">
    <input name="param_type_value" value="textSearch" type="hidden">
    <input name="param_chinese_checkbox_active" value="1" type="hidden">
    <input name="param_chinese_checkbox_value" id="param_chinese_checkbox_value1" value="0" type="hidden">

      <label class="i_text">
        <span>Slova z názvu</span>
        <input name="param_pattern_value" id="param_pattern_value1" type="search">
      </label>
      <input class="i_btn" value="]] .. T "hledat" ..[[" type="submit">
        ]] .. '<p>' .. T("Přehled našich časopisů si můžete prohlédnout <a href='periodika.htm'>zde</a>.") .. "</p> </form>"
        )
      }}),
    },
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
    card{ provozni_doba( doc.prov_doba, T
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
    ), div{ a {href=T "provozni_doba.htm", T "Plánované uzavření knihovny"}}},
    {card {row { 
      div{ '<i class="fa fa-phone-square" aria-hidden="true"></i> <a href="tel:221900148">221 900 148</a>'},
      div {'<i class="fa fa-envelope" aria-hidden="true"></i> ', a{href="mailto:knihovna@pedf.cuni.cz","knihovna@pedf.cuni.cz"}},
    -- },
    -- row{
      div {'<a href="https://www.facebook.com/knihovnapedfpraha"><i class="fab fa-facebook-square" aria-hidden="true"></i></a>',a{href="https://www.facebook.com/knihovnapedfpraha",'knihovnapedfpraha'}}
    }} 
    },
      {card {h.h2{ a{href="/nove_knihy/index.html", T "Nové knihy"}},
      row( div{ class="my-slider",  print_obalky(doc.obalky)}
      -- obalky "978-80-7422-500-0",
      -- obalky "80-85368-18-8", 
      -- obalky "978-80-7294-458-3"
      ),
    }},
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


-- h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
-- h.div{class="card", h.section {class="section ",
-- (body)
-- }},
-- h.script{type="text/javascript", 'var nav = responsiveNav(".nav-collapse");'}
h.script{src="https://support.ebsco.com/eit/scripts/ebscohostsearch.js", type="text/javascript", defer=true} 
,h.script{type="text/javascript", [[
  var slider = tns({
    container: '.my-slider',
    items: 3,
    slideBy: 'page',
    controls:false,
    nav: false,
    speed: 10,
    autoplay: true,
    autoplayHoverPause: true,
    autoplayTimeout: 1500,
    autoplayButtonOutput: false,
    mouseDrag: true,
  });
  ]]}
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
