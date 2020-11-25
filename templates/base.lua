
local h5tk = require "h5tk"
local css = require "css"
local building_blocks = require "lib.building_blocks"
local translator = require "lib.translator"
local os = require "os"

local h = h5tk.init(true)

local a, p, div, header, section = h.a, h.p, h.div, h.header, h.section

local menuitem = function(title, href)
  -- return h.menuitem{class="button", h.a{src=href, title}}
  return h.a{href="/" .. href, class="button", title}
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
    table.insert(t, menuitem(item.title,  item.href))
  end
  return t
end



local function boxik(title, href)
  -- return medium(3,card {h.h3 {title}, {content} })
  return medium(2, h.a {href=href, title})
end

local function metaifexitst(key, value, name)
  local property = name and "name" or "property"
  if value then return h.meta{[property] = key, content=value } end
end

local function make_url(doc)
  return doc.siteurl .. doc.relative_filepath
end

local function get_base_url(url)
  return url:match("(https?%://[^/]+)")
end

local function default_img(doc)
  local imgpath = doc.img or "img/informace.jpg"
  local base_url = get_base_url(doc.siteurl)
  return base_url ..  imgpath
end

local function custom_styles(data)
  local styles = data.styles
  local t = {}
  if styles then
    for _, v in ipairs(styles) do
      t[#t+1] = h.link{rel="stylesheet", type="text/css", href=v}
    end
  end
  return t
end

local function obsolete(data)
  -- 
  if data.obsolete then
    return [[<div class="row"><div class="card fluid warning"><mark class="secondary">Upozornění</mark>Tato stránka není aktuální.
      Nachází se zde pouze proto, že mohou existovat stránky, které na ní odkazují.
      Použijte prosím navigaci v hlavním menu stránky k nalezení aktuálních
      informací.</div></div>]]
  end
end

-- function column
local function template(data)
  local strings = data.strings
  local T = translator.get_translator(strings)
  
  return "<!DOCTYPE html>\n" .. (h.emit(
  h.html{lang=T "cs", prefix="og: http://ogp.me/ns#",
    h.head{
      h.meta{charset="utf-8"},
      h.meta{name="viewport", content="width=device-width, initial-scale=1"},
      h.title{(T (data.title))},
      metaifexitst("og:type", "website"),
      metaifexitst("og:title", data.title),
      metaifexitst("og:description", data.description),
      metaifexitst("og:url", make_url(data)),
      metaifexitst("og:site_name", "Knihovna PedF UK"),
      metaifexitst("og:image", default_img(data)),
      metaifexitst( "twitter:card", "summary_large_image" , "name"),
      -- tohle změnit, použít lokální verzi
      -- h.link{rel="stylesheet", type="text/css", href="https://gitcdn.link/repo/Chalarangelo/mini.css/master/dist/mini-default.min.css"},
      -- '<link rel="stylesheet" href="https://code.cdn.mozilla.net/fonts/fira.css">',
     h.link {rel="alternate",  type="application/rss+xml", href= T "feed.rss"},
      h.link{rel="stylesheet", type="text/css", href="/mini-knihovna.css"},
      h.link{rel="stylesheet", type="text/css", href="/style.css"},
      h.link{rel="stylesheet", type="text/css", href="/media.css"},
      custom_styles(data),
      [[
      <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
      <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
      <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
      <link rel="manifest" href="/manifest.json">
      <link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
      <meta name="theme-color" content="#ffffff">
      <link rel="stylesheet" type="text/css" href="/css/fa-svg-with-js.css" />
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tiny-slider/2.5.0/tiny-slider.css">
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
      div{role="navigation",h.header {
        -- h.a{class="logo",h.div{"Ústřední knihovna PedF UK"}},
        -- h.menu{
        -- h.nav{class="nav-collapse",
        -- h.ul{
        -- class="row",
        h.span {class="logo", "&nbsp;"},
        mainmenu(data.menuitems),
        h.span{ a{href=(data.altlang or T "/index-en.html"),h.img{src=T "/img/gb.svg", alt=T "English version", style="width:1em;"}}} -- odkaz na anglickou verzi stránek
        -- }},
      }},
      -- row {h.p {}},
      h.div {class="logo-container", row{-- nepoužívat row class="row",
      medium(12, 
      {
        -- h.a{href="http://pedf.cuni.cz", h.img{src="img/logo_pedf_small.jpg"}},
        h.a{ href= T "/index.html", h.img{role="banner",style="height:90%;",alt=T "Logo knihovny", src=T "/img/logo.svg"}},
        -- h.a{
        --   class="logo",
        --   href="/",
        --   h.div{"Ústřední"},
        --   h.div{"KNIHOVNA"},
        --   h.div{"PedF UK"}
        -- }
      }),
      -- medium(3,{
      --   h.form{role="search", method="get", id="duckduckgo-search", action="https://duckduckgo.com/", 
      --     h.input{type="hidden", name="sites" , value="knihovna.pedf.cuni.cz"},
      --     h.input{type="hidden", name="k8" , value="#444444"},
      --     h.input{type="hidden", name="k9" , value="#D51920"},
      --     h.input{type="hidden", name="kt" , value="h"},
      --     h.input{type="search", name="q" , maxlength="255", style="width:12rem", placeholder=T "Hledat na tomto webu"},
      --     h.input{type="submit",class="small", value=T "hledat"} --style="visibility: hidden;"}
      --   }

      --   -- h.iframe{src="https://duckduckgo.com/search.html?site=knihovna.pedf.cuni.cz&prefill=Search DuckDuckGo&kl=cs-cz&kae=t&ks=s",
      --   -- style="overflow:hidden;margin:0;padding:0;width:408px;height:40px;"}
      -- })
    }},
      -- row{
        obsolete(data), -- upozornění na zastaralé stránky
        data.contents,
    -- },


    -- h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
    -- h.div{class="card", h.section {class="section ",
    -- (body)
    -- }},
    h.footer{role="contentinfo",
      row{
        medium(4, div{
          p{"Knihovna PedF UK, Magdaleny Rettigové 4, 116&#8239;39&nbsp;Praha&nbsp;1"},
          p{"Aktualizováno: " .. os.date("%Y-%m-%d")},
          p{"© Univerzita Karlova",},

        }),
        medium(4, div {
          div{a {href="https://www.facebook.com/knihovnapedfpraha", "Facebook"}}
          ,div{a {href="https://www.instagram.com/KnihovnaPedFPraha/", "Instagram"}}
          ,div{a {href=T "/feed.rss", "RSS"}}

        }),
        medium(4, div {
          p{"Webmaster: <a href='mailto:michal.hoftich@pedf.cuni.cz'>michal.hoftich@pedf.cuni.cz</a>"}
          ,p{a {href="prohlaseni.html", "Prohlášení o přístupnosti stránek"}}
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
