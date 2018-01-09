local h5tk = require "h5tk"
local M = {}

local h = h5tk.init(true)

local k = {ahoj = "hello world"}
local xxx = function(doc)
  for k,v in pairs(doc) do
    print("doccc")
    h.div{class="news"}
  end
end

local var = function(a) return string.format("{{%s}}",a) end

local page = function(doc)
  return h.emit(
  h.html{
    h.head{
      h.meta{charset="utf-8"},
      h.title{(doc.title)}
    },
    h.body{
      (xxx(doc)),
      (k.ahoj),
      var("contents")
    }
  } 
  )
end

M.footer = h.emit(h.footer{
var "footer", 
h.span{"&nbsp;"}
})

M.header = h.emit(h.header{
-- h.div{class="vystavba", "Stránky jsou ve výstavbě, děkujeme za pochopení"},
h.a{href="/index.html", h.h1{ "Knihovna PedF UK"}},
h.menu{
  (var("#sitemap")),
  h.menuitem{
  h.a{href="/"..var("url"), var("name")}},
  (var("/sitemap")),
  h.a{style="float:right;margin-right:.5em;",href="library.html", "en"}
},
-- h.a{href="/index.html", h.img{src="img/tamara-buckova-ende.jpg", css="width:100%"}}
})
M.page = page
 return M
