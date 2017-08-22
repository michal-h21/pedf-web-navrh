local h5tk = require "h5tk"
local css = require "css"

local h = h5tk.init(true)

local a, p, div, header, section = h.a, h.p, h.div, h.header, h.section

local menuitem = function(title, href)
  -- return h.menuitem{class="button", h.a{src=href, title}}
  return h.a{href=href, class="button", title}
end

local function ipsum()
  return h.p {[[ Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis semper tellus. Nulla mollis orci ante, eget pulvinar dolor semper ut. Nunc aliquam quis elit sed ultricies. Aenean vulputate commodo lobortis. Donec ac urna augue. Maecenas a nunc a risus commodo tincidunt a a dui. Pellentesque pellentesque leo in arcu placerat vulputate. Nulla lobortis velit metus.]]},
  h.p {[[Duis eu pulvinar lectus. Phasellus congue ipsum vitae molestie tincidunt. Nam ante velit, tincidunt sit amet enim id, tempor ultricies libero. Donec eget nisi vel metus maximus accumsan sit amet id lacus. In hac habitasse platea dictumst. Donec enim sem, tincidunt quis magna et, consectetur faucibus justo. Donec laoreet nunc vel mi hendrerit elementum. Suspendisse fringilla metus tempor, eleifend dui sed, rutrum sapien. Fusce at aliquam magna, et laoreet turpis. Nulla ullamcorper ex vitae placerat suscipit. In lobortis eget est ac malesuada. Aenean mattis ante quam, nec ornare mi porta non. Pellentesque sed neque non ligula aliquam congue. Donec viverra efficitur velit at suscipit. Quisque maximus odio id bibendum vehicula. ]]}
end


local function row(content)
  return h.div{class="row", content}
end

local class = function(tab)
  if type(tab) == "table" then
    return table.concat(tab, " ")
  end
  return tab
end

-- don't use column directly
local function column(typ, content)
  local typ = typ or "col-med"
  return div{ class=class{"col-sm-12", typ}, content }
end

-- use
local function medium(width, content)
  local width = width or 6
  return column("col-md-" .. width, content)
end

local function card(content)
  return div {class="card fluid", section {class = "section", content}}
end


local function actuality(title, date, content)
  return section{ 
    class="section dark",
    h.h3 { date .. "  – "..title},
    content
  }
end
   
local function provozni_doba(data) 
  local t = {}
  local function tbl(data)
      local tble = {}--h.table {}
      for _, obdobi in ipairs(data) do
        local row = h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        -- h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        table.insert(tble, row)
      end
      return tble
  end
  local function jednotky(data) 
    for _, jednotka in ipairs(data) do
      table.insert(t, h.h3 {jednotka.name})
      -- h.h3 {jednotka.name}
      table.insert(t, h.table {tbl(jednotka.data)})
      -- table.insert(t, tble)
    end
    return t
  end
  return jednotky(data)
end



-- function column
local function template(title, body)
  print(h.emit(
  h.html{
    h.head{
      h.meta{charset="utf-8"},
      h.meta{name="viewport", content="width=device-width, initial-scale=1"},
      h.title{(title)},
      -- tohle změnit, použít lokální verzi
      -- h.link{rel="stylesheet", type="text/css", href="media.css"},
      h.link{rel="stylesheet", type="text/css",
      href="https://gitcdn.link/repo/Chalarangelo/mini.css/master/dist/mini-default.min.css"},
      h.link{rel="stylesheet", type="text/css", href="style.css"},
      -- h.link{rel="stylesheet", type="text/css", href="src/responsive-nav.css"},
      -- h.script{type="text/javascript", src="responsive-nav.js",},
    },
    h.body{
      class="container",
      row{-- nepoužívat row class="row",
      medium(8, 
      {
        h.a{href="http://pedf.cuni.cz", h.img{src="img/logo_pedf_small.jpg"}},
        h.a{
          class="logo",
          href="/",
          h.div{"Ústřední"},
          h.div{"KNIHOVNA"},
          h.div{"PedF UK"}
        }
      }),
      medium(4,{
        h.form{method="get", id="duckduckgo-search", action="http://duckduckgo.com/", 
          h.input{type="hidden", name="sites" , value="knihovna.pedf.cuni.cz"},
          h.input{type="hidden", name="k8" , value="#444444"},
          h.input{type="hidden", name="k9" , value="#D51920"},
          h.input{type="hidden", name="kt" , value="h"},
          h.input{type="text", name="q" , maxlength="255", placeholder="Hledat na webu knihovny"},
          h.input{type="submit", style="visibility: hidden;"}
        }

        -- h.iframe{src="https://duckduckgo.com/search.html?site=knihovna.pedf.cuni.cz&prefill=Search DuckDuckGo&kl=cs-cz&kae=t&ks=s",
        -- style="overflow:hidden;margin:0;padding:0;width:408px;height:40px;"}
      })
    },
      h.header {
        -- h.a{class="logo",h.div{"Ústřední knihovna PedF UK"}},
        -- h.menu{
        -- h.nav{class="nav-collapse",
        -- h.ul{
        -- class="row",
        h.span {class="logo", "{Logo}"},
        menuitem("Služby knihovny","sluzby.html"),
        menuitem("Evidence publikací", "biblio"),
        menuitem("Závěrečné práce a citace", "katalogy.html"),
        menuitem("Poprvé v knihovně", "bibliografie.html"),
        menuitem("Návrh na doplnění fondu","dokumenty.html"),
        menuitem("Napiště nám", "knihovna.html"),
        -- }},
      },
      row{
        medium(9,{
        card {
          h.h2{ "Aktuality"},
          actuality("Provozní doba v průběhu letních prázdnin", "26. 6. 2017", p {"Aktualizovanou provozní dobu knihovny v průběhu letních prázdnin a v září naleznete zde"}),
          actuality("Uzavření SAJL v Celetné", "23.06.2017", "Upozorňujeme všechny uživatele služeb ve Studovně anglického jazyka a literatury PedF v Celetné 13, aby si veškerou literaturu, kterou budou potřebovat ke zkouškám v září, vypůjčili do konce června. V srpnu bude studovna z důvodu stěhování knihovního fondu uzavřena.")
        },
        row {
           medium(9, {card {p{"Vyhledávací boxy"}}}),
           medium(3, {card {p{"Obálky knih"}}})
         }
      })
        ,
      medium(3,{ 
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
      card {div {"Ankety"}}
    })
    },


    -- h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
    -- h.div{class="card", h.section {class="section ",
    -- (body)
    -- }},
    h.footer{},
    -- h.script{type="text/javascript", 'var nav = responsiveNav(".nav-collapse");'}
  },
}
))
end


print "<!DOCTYPE html>"
template("Úvodní stránka - ÚK PedF UK", {
  h.h1 {"Úvodní stránka"},
  ipsum,ipsum, ipsum,ipsum,ipsum,ipsum,ipsum,
})
