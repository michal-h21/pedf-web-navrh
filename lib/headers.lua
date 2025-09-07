-- find all headers in HTML files
--
local function find_tags(text, tags_to_be_found, position)
  local start, stop, tag = string.find(text, "<(%w+)", position)
  if start and tags_to_be_found[tag] then
    return start, tag
  else
    if start then
      return find_tags(text, tags_to_be_found, stop + 1)
    else
      return nil
    end
  end
end

local function read_tag(text, position, tag)
  local _, end_pos = string.find(text, "</" .. tag .. ">", position)
  if end_pos then
    return string.sub(text, position, end_pos)
  else
    return nil
  end

end

local function array_to_hash(tbl)
  -- convert array to hash table
  local newtbl = {}
  for _, v in ipairs(tbl) do
    newtbl[v] = true
  end
  return newtbl
end

local function remove_comments(text)
  -- remove HTML comments
  local newtext = text
  local start, stop = string.find(newtext, "<!%-%-")
  while start do
    local end_start, end_stop = string.find(newtext, "%-%->", stop + 1)
    if end_start then
      newtext = string.sub(newtext, 1, start - 1) .. string.sub(newtext, end_stop + 1)
      start, stop = string.find(newtext, "<!%-%-")
    else
      break
    end
  end
  return newtext
end

local function find_id(header)
  local id = string.match(header, 'id="(.-)"')
  if id then
    return id
  else
    return nil
  end
end

local function strip_tags(header)
  local text = string.gsub(header, "<.->", "")
  return text
end

local function find_headers(origtext)
  local headers = {}
  local text = remove_comments(origtext)
  local tags_to_be_found = array_to_hash {"h1", "h2", "h3", "h4", "h5", "h6"}
  local position, tag = find_tags(text, tags_to_be_found, 1)
  while position do
    local header = read_tag(text, position, tag)
    -- this shouldn't happen, but it can, in the case of tag mismatch
    if header then
      local id = find_id(header)
      local header_text = strip_tags(header)
      if not id then
        -- if there is no id in the section tag, we will create a new one, based on the section title
        id = header_text:gsub("%s+", "-"):gsub("[^%w%-]", ""):lower()
        -- then we will add the id to the original text
        local newheader = header:gsub("<" .. tag, '<' .. tag .. ' id="' .. id .. '"', 1)
        origtext = origtext:gsub(header, newheader, 1)
      end
      table.insert(headers, {element = header, id = id, text = header_text})
    end
    position, tag = find_tags(text, tags_to_be_found, position + 1)
  end
  return headers, origtext
end

local text = io.read("*all")
local headers, text = find_headers(text)
for k, v in ipairs(headers) do
  print(v.id, v.text)
end
print(text)
