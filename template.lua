local h5tk = require "h5tk"
local css = require "css"

local h = h5tk.init(true)

local menuitem = function(title, href)
  -- return h.menuitem{class="button", h.a{src=href, title}}
  return h.a{src=href, class="button", title}
end

local function ipsum()
  return h.p {[[ Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis semper tellus. Nulla mollis orci ante, eget pulvinar dolor semper ut. Nunc aliquam quis elit sed ultricies. Aenean vulputate commodo lobortis. Donec ac urna augue. Maecenas a nunc a risus commodo tincidunt a a dui. Pellentesque pellentesque leo in arcu placerat vulputate. Nulla lobortis velit metus.]]},
  h.p {[[Duis eu pulvinar lectus. Phasellus congue ipsum vitae molestie tincidunt. Nam ante velit, tincidunt sit amet enim id, tempor ultricies libero. Donec eget nisi vel metus maximus accumsan sit amet id lacus. In hac habitasse platea dictumst. Donec enim sem, tincidunt quis magna et, consectetur faucibus justo. Donec laoreet nunc vel mi hendrerit elementum. Suspendisse fringilla metus tempor, eleifend dui sed, rutrum sapien. Fusce at aliquam magna, et laoreet turpis. Nulla ullamcorper ex vitae placerat suscipit. In lobortis eget est ac malesuada. Aenean mattis ante quam, nec ornare mi porta non. Pellentesque sed neque non ligula aliquam congue. Donec viverra efficitur velit at suscipit. Quisque maximus odio id bibendum vehicula. ]]}
end

local function template(title, body)
  print(h.emit(
  h.html{
    h.head{
      h.meta{charset="utf-8"},
      h.title{(title)},
      -- tohle změnit, použít lokální verzi
      h.link{rel="stylesheet", type="text/css",
        href="https://gitcdn.link/repo/Chalarangelo/mini.css/master/dist/mini-default.min.css"},
      h.link{rel="stylesheet", type="text/css", href="style.css"}
    },
    h.body{
      h.header {class="row",
        h.a{class="logo",{"Ústřední knihovna PedF UK"}},
      },
      h.header {class="row",
        -- h.a{class="logo",h.div{"Ústřední knihovna PedF UK"}},
      -- h.menu{
        menuitem("Služby knihovny","sluzby.html"),
        menuitem("Závěrečné práce a citace", "katalogy.html"),
        menuitem("Poprvé v knihovně", "bibliografie.html"),
        menuitem("Návrh na doplnění fondu","dokumenty.html"),
        menuitem("Napiště nám", "knihovna.html"),
      -- }},
      },
      h.div{class="row", h.div {class="col-sm-12 col-md-10 col-md-offset-1",
    (body)
    }},
    h.footer{class="row"}
      }
  }
  ))
end


print "<!DOCTYPE html>"
template("Úvodní stránka - ÚK PedF UK", {
  h.h1 {"Úvodní stránka"},
  ipsum,ipsum, ipsum,ipsum,ipsum,ipsum,ipsum,
})
