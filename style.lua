local css = require "css"

local width = "80rem"

css.body{
  -- border = {"1px solid black"},
  ["max-width"] = width,
  margin = "0 auto"
}

print(tostring(css))
