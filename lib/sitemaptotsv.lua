local sitemap = require "sitemap"
local function print_entry (t, indent)
  local t = t or {}
  local indent = indent or 0
  local indent_string = string.rep("\t", indent)
  for _, v in ipairs(t) do
    local name = v.name
    local url = v.url or ""
    local comment = v.comment or ""
    print(string.format("%s%s\t%s\t%s", indent_string, name, url, comment))
    print_entry(v.children, indent+1)
  end
end

print_entry(sitemap)
