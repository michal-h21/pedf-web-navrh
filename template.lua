local h5tk = require "h5tk"
local css = require "css"

local h = h5tk.init(true)

local menuitem = function(title, href)
  return h.menuitem{h.a{src=href, title}}
end

function template(title, body)
  print(h.emit(
  h.html{
    h.head{
      h.meta{charset="utf-8"},
      h.title{(title)},
      h.link{rel="stylesheet", type="text/css", href="scale.css"},
      h.link{rel="stylesheet", type="text/css", href="style.css"}
    },
    h.body{
      h.header { h.div{class="logo"}},
      h.menu{
        menuitem("Katalogy a databáze", "katalogy.html"),
        menuitem("Služby","sluzby.html"),
        menuitem("Bibliografie", "bibliografie.html"),
        menuitem("Dokumenty","dokumenty.html"),
        menuitem("O knihovně", "knihovna.html"),
      },
      (body)}
  }
  ))
end


template("Úvodní stránka - ÚK PedF UK", {
  h.h1 {"Úvodní stránka"},
  h.p {"vítejte"}
})
