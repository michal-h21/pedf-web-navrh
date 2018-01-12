
local h5tk = require "h5tk"
local css = require "css"
local building_blocks = require "lib.building_blocks"
local translator = require "lib.translator"

local h = h5tk.init(true)

local a, p, div, header, section = h.a, h.p, h.div, h.header, h.section

local menuitem = function(title, href)
  -- return h.menuitem{class="button", h.a{src=href, title}}
  return h.a{href=href, class="button", title}
end


local row = building_blocks.row

-- local class = building_blocks.class

-- local column = building_blocks.column

local medium = building_blocks.medium

-- local card = building_blocks.card

-- local tab = building_blocks.tab
-- local boxik = building_blocks.boxik


local function mainmenu(menuitems)
  local t = {}
  local menuitems = menuitems or {}
  for _, item in ipairs(menuitems) do
    table.insert(t, menuitem(item.title, item.href))
  end
  return t
end



local function boxik(title, href)
  -- return medium(3,card {h.h3 {title}, {content} })
  return medium(2, h.a {href=href, title})
end

-- function column
local function template(data)
  local strings = data.strings
  local T = translator.get_translator(strings)
  
  return "<!DOCTYPE html>\n" .. (h.emit(
  h.html{
    h.head{
      h.meta{charset="utf-8"},
      h.meta{name="viewport", content="width=device-width, initial-scale=1"},
      h.title{(data.title)},
      -- tohle změnit, použít lokální verzi
      -- h.link{rel="stylesheet", type="text/css", href="https://gitcdn.link/repo/Chalarangelo/mini.css/master/dist/mini-default.min.css"},
      '<link rel="stylesheet" href="https://code.cdn.mozilla.net/fonts/fira.css">',
     h.link {rel="alternate",  type="application/rss+xml", href= T "feed.rss"},
      h.link{rel="stylesheet", type="text/css", href="mini-knihovna.css"},
      h.link{rel="stylesheet", type="text/css", href="style.css"},
      h.link{rel="stylesheet", type="text/css", href="media.css"},
      [[
      <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
      <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
      <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
      <link rel="manifest" href="/manifest.json">
      <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
      <meta name="theme-color" content="#ffffff">
      <link rel="stylesheet" type="text/css" href="/css/fa-svg-with-js.css" />
      <script defer src="/js/fontawesome-all.min.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/webfont/1.6.28/webfontloader.js"></script>
      <script>
        WebFont.load({
          custom: {
            families: ['Fira Sans']
          }
        });
        </script>
      ]]

      -- h.link{rel="stylesheet", type="text/css", href="src/responsive-nav.css"},
      -- h.script{type="text/javascript", src="responsive-nav.js",},
    },
    h.body{
      class="container",
      row{-- nepoužívat row class="row",
      medium(9, 
      {
        -- h.a{href="http://pedf.cuni.cz", h.img{src="img/logo_pedf_small.jpg"}},
        h.a{href="index.html", h.img{style="height:90%;",src="img/logo.svg"}},
        -- h.a{
        --   class="logo",
        --   href="/",
        --   h.div{"Ústřední"},
        --   h.div{"KNIHOVNA"},
        --   h.div{"PedF UK"}
        -- }
      }),
      medium(3,{
        h.form{method="get", id="duckduckgo-search", action="http://duckduckgo.com/", 
          h.input{type="hidden", name="sites" , value="knihovna.pedf.cuni.cz"},
          h.input{type="hidden", name="k8" , value="#444444"},
          h.input{type="hidden", name="k9" , value="#D51920"},
          h.input{type="hidden", name="kt" , value="h"},
          h.input{type="search", name="q" , maxlength="255", placeholder=T "Hledat na webu knihovny"},
          h.input{type="submit",class="small", value=T "hledat"} --style="visibility: hidden;"}
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
        h.span {class="logo", "&nbsp;"},
        mainmenu(data.menuitems),
        h.span{ a{href="index-en.html",h.img{src="img/gb.svg", alt="English version", style="width:1em;"}}} -- odkaz na anglickou verzi stránek
        -- }},
      },
      -- row{
        data.contents,
    -- },


    -- h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
    -- h.div{class="card", h.section {class="section ",
    -- (body)
    -- }},
    h.footer{
      row{
        medium(4, div{
          p{"Knihovna PedF UK, Magdaleny Rettigové 4, 116&#8239;39&nbsp;Praha&nbsp;1"},
          p{"© Univerzita Karlova"},

        }),
        medium(4, div {
          div{a {href="https://www.facebook.com/knihovnapedfpraha", "Facebook"}}
          ,div{a {href=T "feed.rss", "RSS"}}

        }),
        medium(4, div {
          p{"<a href='mailto:michal.hoftich@pedf.cuni.cz'>Webmaster</a>"}
        })
        -- boxik("EIZ pro PedF", "eiz.htm"),
        -- boxik('Časopisy', "periodika.htm"),
        -- boxik("Studenti se speciálními potřebami", "handi.htm"),
        -- boxik("Návody", "navody.html"),
        -- boxik("O knihovně", "informace.htm"),
        -- -- boxik("Řády a ceníky", 
        -- boxik("Facebook", "http://www.facebook.com/pages/%C3%9Ast%C5%99edn%C3%AD-knihovna-Pedagogick%C3%A9-fakulty-Univerzity-Karlovy/119305204810664"),
        -- boxik("Pracoviště a zaměstnanci", "adresar.htm"),
        -- boxik("Formuláře", "e-formulare.htm")

    }
    },
    -- h.script{type="text/javascript", 'var nav = responsiveNav(".nav-collapse");'}
    -- h.script{src="https://support.ebsco.com/eit/scripts/ebscohostsearch.js", type="text/javascript", defer=true}
  },
}
))
end

return template
