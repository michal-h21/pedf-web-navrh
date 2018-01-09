-- další pokus
--
local lettersmith = require("lettersmith")

local render_markdown = require("lettersmith.markdown")

-- Get paths from "raw" folder
local paths = lettersmith.paths("src")

-- Render markdown
local docs = lettersmith.docs(paths)
docs = render_markdown(docs)

-- Build files, writing them to "www" folder
lettersmith.build("www", docs)
