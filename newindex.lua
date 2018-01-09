local h5tk = require "h5tk"
-- local css = require "css"
local base_template = require "templates.base"
local building_blocks = require "lib.building_blocks"

local h = h5tk.init(true)

local a, p, div, header, section = h.a, h.p, h.div, h.header, h.section


local row = building_blocks.row

-- local class = building_blocks.class

-- local column = building_blocks.column

local medium = building_blocks.medium

local card = building_blocks.card

local tab = building_blocks.tab
local boxik = building_blocks.boxik



local function print_actual(items)
  local t = {}
  for i, item in ipairs(items) do
   table.insert(t, h.h3{item.date  .. " – " ..item.akt_title})
   -- table.insert(t, h.p{h.small {item.date}})
   table.insert(t, item.contents)
   if i < #items then table.insert(t, h.hr{}) end
  end
  return t
end

local function obalky(isbn)
  return h.img{style = "height:9rem;display:inline;", src='https://www.obalkyknih.cz/api/cover?isbn=' .. isbn}
end

local function progress(percent)
  return h.progress{value = percent, max=1000}
end

local function provozni_doba(data)
  local t = {}
  local function tbl(jednotka)
      local tble = {h.caption{jednotka.name}}--h.table {}
      for _, obdobi in ipairs(jednotka.data) do
        local curr_row = h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        -- h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        table.insert(tble, curr_row)
      end
      return tble
  end
  local function jednotky(idata)
    for _, jednotka in ipairs(idata) do
      -- table.insert(t, h.h3 {jednotka.name})
      -- h.h3 {jednotka.name}
      -- table.insert(jednotka.data, 1, h.caption {jednotka.name})
      table.insert(t, h.table {tbl(jednotka)})
      -- table.insert(t, tble)
    end
    return t
  end
  return jednotky(data)
end





-- function column
local function template(doc )
  local title = doc.title
  local contents = {
    row{
      medium(9,{
        row{
          card {
            h.h2{ "Aktuality", " (", h.a {href="archiv.html", "archiv"}, ")"  },
            print_actual(doc.items),
            -- actuality("Provozní doba v průběhu letních prázdnin", "26. 6. 2017", p {"Aktualizovanou provozní dobu knihovny v průběhu letních prázdnin a v září naleznete zde"}),
            -- actuality("Uzavření SAJL v Celetné", "23.06.2017", "Upozorňujeme <b>všechny</b> uživatele služeb ve Studovně anglického jazyka a literatury PedF v Celetné 13, aby si veškerou literaturu, kterou budou potřebovat ke zkouškám v září, vypůjčili do konce června. V srpnu bude studovna z důvodu stěhování knihovního fondu uzavřena.")
          }},
          row {
            -- medium(9, {card {p{"Vyhledávací boxy"}}}),
            medium(9, card{ div{class="tabs", 
            tab("aleph", "Katalog",  h.form{action="https://ckis.cuni.cz/F/", method="get", target="_blank", 
            h.input{  name="local_base", value="pedfr", type="hidden"},
            h.input {name="func", value="find-e" ,type="hidden"},
            row{
              h.label {"Klíčová slova:", h.input {name="request", type="search"}},
              h.label {"Vyhledat v: ", h.select {
                name="find_scan_code",
                h.option{value="FIND_WRD", selected="selected", "Všechna pole"},
                h.option {value="FIND_WTI", "Název"},
                h.option {value="SCAN_TIT", "První slovo z názvu"},
                h.option {value="FIND_WAU", "Autor"},
                h.option {value="SCAN_AUT", "Autorský rejstřík"},
                h.option {value="FIND_WKW", "Předmět"},
                h.option {value="SCAN_SUB", "Předmětový rejstřík"},
                h.option {value="FIND_ISN", "ISBN/ISSN"},
              }
            }}
          },"selected"),
          tab("ukaz", "Ukaž", 
          h.form{ id="ebscohostCustomSearchBox", action="", onsubmit="return ebscoHostSearchGo(this);", method="post",
          h.input {id="ebscohostwindow",name="ebscohostwindow",type="hidden",value="1"},
          h.input {id="ebscohosturl",name="ebscohosturl",type="hidden",value="https://search.ebscohost.com/login.aspx?direct=true&site=eds-live&scope=site&type=0&custid=s1240919&groupid=main&profid=eds&mode=bool&lang=cs&authtype=ip,guest"},
          h.input {id="ebscohostsearchsrc",name="ebscohostsearchsrc",type="hidden",value="db"},
          h.input {id="ebscohostsearchmode", name="ebscohostsearchmode", type="hidden", value="+"},
          h.input {id="ebscohostkeywords", name="ebscohostkeywords", type="hidden", value="" },
          h.label{"Klíčová slova:", h.input{id="ebscohostsearchtext",class="",name="ebscohostsearchtext",type="search",size="23"}}
        }
        ),
        tab("e-casopisy", "E-časopisy", p{"Elektronické časopisy"})
      }}),
      medium(3, {card {h.h2{"Obálky knih"},
      row{
        obalky "978-80-7422-500-0",
        -- obalky "80-85368-18-8", 
        -- obalky "978-80-7294-458-3"
      },
      div{a{href="/nove_knihy/index.html", "Nové knihy"}}
    }})
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
    card{h.h2{"Provozní doba"}, provozni_doba{
      {
        name = "Výpůjční protokol",
        data = {
          {day="Po", time = "8.00–16.00"},
          {day = "Út–Pá", time = "8.00–17.00"}
        }
      },
      {
        name = "Studovna",
        data = {
          {day = "Po–Čt", time = "8.00–18.00"},
          {day = "Pá", time = "8.00–16.00"}
        }
      }
    }},
    card {
      h.h2 {"Ankety"}, 
      p {"Nějaká otázka. Trochu delší text"},
      h.ol{
        h.li{"první možnost", progress(300)},
        h.li{"druhá možnost", progress(400)}, 
        h.li {"třetí možnost",progress(300)}
      }
    }
  })
},


-- h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
-- h.div{class="card", h.section {class="section ",
-- (body)
-- }},
-- h.script{type="text/javascript", 'var nav = responsiveNav(".nav-collapse");'}
h.script{src="https://support.ebsco.com/eit/scripts/ebscohostsearch.js", type="text/javascript", defer=true}
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
