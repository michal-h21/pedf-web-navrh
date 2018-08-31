local function load_opening(lines)
  local rooms = {}
  local seq = {} -- chceme zachovat pořadí, v jakém byly pobočky v CSV souboru
  for line in lines do
    local entries = {}
    for entry in line:gmatch("([^|]+)") do
      entries[#entries+1] = entry
    end
    local room, days, from, to, comment = table.unpack(entries)
    if not rooms[room] then table.insert(seq, room) end
    local current = rooms[room] or {name=room, data = {}}
    local time = table.concat({from,  to}, " – ")
    table.insert(current.data, {day = days, time = time})
    rooms[room] = current
    -- print("*****************",room, days, from, to, comment)
  end
  local opening = {children = {}}
  for _, room in ipairs(seq) do
    table.insert(opening.children, rooms[room])
  end
  return opening
  -- return room
end

-- local csv_file = io.open("data/opening.csv")
return function(filename)
  return load_opening(io.lines(filename))
end

