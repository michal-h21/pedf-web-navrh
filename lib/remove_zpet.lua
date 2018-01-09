local filename = arg[1]
local f = io.open(filename,"r")
local body = f:read("*all")
f:close()
body = body:gsub("<p><a href=\"index.html\" target=\"_blanc\"><span class=\"zz\">Zpět na[%s]*Aktuality</span></a><br />","")
body = body:gsub("<img src=\"zpet1.gif\" align=[%s]*\"center\" width=\"24\" height=\"24\" />","")
local f = io.open(filename,"w") 
f:write(body)

print(filename, type(body))
f:close()
