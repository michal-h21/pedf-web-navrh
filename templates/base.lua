
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

local function tab(name, label, content, checked)
  return {h.input{type="radio", name="tab-group", id=name,checked=checked, ["aria-hidden"] = true},
  h.label {["for"] = name, ["aria-hidden"]=true, label},
  div{content}
  }
end



local function actuality(title, date, content)
  return section{ 
    class="section dark",
    h.h3 { date .. "  – "..title},
    content
  }
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
        local row = h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        -- h.tr { h.td { obdobi.day}, h.td {obdobi.time}}
        table.insert(tble, row)
      end
      return tble
  end
  local function jednotky(data) 
    for _, jednotka in ipairs(data) do
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
  return medium(3, h.a {href=href, title})
end

-- function column
local function template(data)
  
  return "<!DOCTYPE html>\n" .. (h.emit(
  h.html{
    h.head{
      h.meta{charset="utf-8"},
      h.meta{name="viewport", content="width=device-width, initial-scale=1"},
      h.title{(data.title)},
      -- tohle změnit, použít lokální verzi
      -- h.link{rel="stylesheet", type="text/css", href="https://gitcdn.link/repo/Chalarangelo/mini.css/master/dist/mini-default.min.css"},
      h.link{rel="stylesheet", type="text/css", href="mini-knihovna.css"},
      h.link{rel="stylesheet", type="text/css", href="style.css"},
      h.link{rel="stylesheet", type="text/css", href="media.css"},
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
          h.input{type="search", name="q" , maxlength="255", placeholder="Hledat na webu knihovny"},
          h.input{type="submit",class="small", value="&#x2315;"} --style="visibility: hidden;"}
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
        mainmenu(data.menuitems),
        h.span{ a{href="en/index.html",h.img{src="img/gb.svg", alt="en", style="width:1em;"}}} -- odkaz na anglickou verzi stránek
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
        boxik("EIZ pro PedF", "eiz.htm"),
        boxik('Časopisy', "periodika.htm")
    }
    },
    -- h.script{type="text/javascript", 'var nav = responsiveNav(".nav-collapse");'}
    -- h.script{src="https://support.ebsco.com/eit/scripts/ebscohostsearch.js", type="text/javascript", defer=true}
  },
}
))
end

return template
